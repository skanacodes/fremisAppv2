import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:http/http.dart' as http;
import 'package:fremisAppV2/services/constants.dart';
import 'package:fremisAppV2/screens/verification/afterverification.dart';
import 'package:fremisAppV2/services/size_config.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class ScanQr extends StatefulWidget {
  final String role;
  ScanQr({this.role});
  @override
  _ScanQrState createState() => _ScanQrState();
}

class _ScanQrState extends State<ScanQr> {
  String result = "Hey there !";
  int tpId;
  bool iSscanned = false;
  String tpNumberPrompt;
  bool status;
  String tpNumber;
  String dealerName;
  String vehicleNumber;
  String trailerNumber;
  String receiptNumber;
  String vehicleCategory;
  String dealerType;
  String receiptDate;
  String transportMode;
  String dfmNumber;
  String validDays;
  bool isPosting = false;
  // String token;

  Future verifyTp(String tpNumbere, String token) async {
    print('////,,,,,,,,,,');
    setState(() {
      isPosting = true;
    });
    print(tpNumber);
    try {
      setState(() {});
      var headers = {"Authorization": "Bearer " + token};

      final response = await http.get(
          'http://41.59.227.103:9092/api/v1/transit-pass/$tpNumbere',
          headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 201:
          setState(() {
            res = json.decode(response.body);
            print(res);
            if (res['message'] == 'Invalid Checkpoint') {
              message('Invalid Checkpoint');
            } else if (res['message'] ==
                'Previous checkpoint [Mkumbara] not yet verified this TP') {
              message('Some Previous Checkpoints Have Not Verified This TP');
            } else {
              tpId = res['data']['id'];
              dealerName = res['data']['dealer'];
              tpNumber = res['data']['tp_number'];
              dealerType = res['data']['dealer_type'];
              status = res['validity'] == 'true' ? true : false;
              print(status);
              dfmNumber = res['data']['dfm_phone'];
              receiptDate = res['data']['receipt_date'];
              receiptNumber = res['data']['receipt_no'];
              trailerNumber = res['data']['trailer_no'];
              vehicleNumber = res['data']['vehicle_no'];
              vehicleCategory = res['data']['vehicle_cat'];
              transportMode = res['data']['transport_mode'];
              // validDays = res['data']['valid_days'];

              print(tpId);
              print(res);
              print(res['data']['id']);
              isPosting = false;
              iSscanned = true;
            }
          });
          break;
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            if (res['message'] == 'Already verified in this checkpoint!') {
              message('Transit Pass Already Verified In This Checkpoint');
            } else if (res['message'] == 'Invalid Checkpoint') {
              message('Invalid Checkpoint');
            } else {
              message('Some Previous Checkpoints Have Not Verified This TP');
            }
            isPosting = false;
          });
          break;
        case 401:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isPosting = false;
          });
          break;

        case 404:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isPosting = false;
            message('Transit Pass Not Found');
          });
          break;
        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isPosting = false;
            message('Ooohps! Something Went Wrong');
          });
          break;
      }
    } on SocketException {
      setState(() {
        var res = 'Server Error';
        message('Bad Connection Or  Server Error');
        isPosting = false;
        print(res);
      });
    }
  }

  enterTpNoPrompt(String tokens) {
    return Alert(
        context: context,
        title: "Failed Scanning Enter TP Number",
        content: Column(
          children: <Widget>[
            isPosting
                ? CupertinoActivityIndicator(
                    radius: 20,
                    animating: true,
                  )
                : TextField(
                    onChanged: (value) {
                      tpNumberPrompt = value;
                      print(tpNumberPrompt);
                    },
                    cursorColor: kPrimaryColor,
                    decoration: InputDecoration(
                      icon: Icon(Icons.folder_open),
                      labelText: 'Enter TP Number',
                    ),
                  ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () async {
              Navigator.pop(context);
              await verifyTp(tpNumberPrompt, tokens);
            },
            child: Text(
              "VERIFY",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          DialogButton(
            color: Colors.red,
            onPressed: () => Navigator.pop(context),
            child: Text(
              "CANCEL",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  message(String desc) {
    return Alert(
      context: context,
      type: AlertType.info,
      title: "Information",
      desc: desc,
      buttons: [
        DialogButton(
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  Future _scanQR() async {
    try {
      String barcodeScanRes = await scanner.scan();
      var x = barcodeScanRes == null ? null : barcodeScanRes.substring(11, 19);
      String tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      if (x != null) {
        await verifyTp(x, tokens);
      } else {
        enterTpNoPrompt(tokens);
      }

      setState(() {
        result = barcodeScanRes.toString();
      });
    } on PlatformException catch (ex) {
      if (ex.code == scanner.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
        });
        message(result);
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
        message(result);
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
      message(result);
    }
  }

  Widget _submitButton() {
    return isPosting
        ? CupertinoActivityIndicator(
            radius: 20,
          )
        : InkWell(
            onTap: () {
              _scanQR();
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(vertical: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.shade200,
                        offset: Offset(2, 4),
                        blurRadius: 5,
                        spreadRadius: 2)
                  ],
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [kPrimaryColor, Colors.green[200]])),
              child: Text(
                'Please Scan QR Code On TP',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return iSscanned == false
        ? Column(
            children: [
              Container(
                height: getProportionateScreenHeight(500),
                child: Stack(
                  children: [
                    Container(
                      height: getProportionateScreenHeight(500),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(400))),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          width: getProportionateScreenWidth(150),
                          height: getProportionateScreenHeight(150),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(300))),
                        ),
                      ),
                    ),
                    iSscanned
                        ? Container(
                            child: Text(result),
                          )
                        : Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: getProportionateScreenHeight(400),
                              width: getProportionateScreenWidth(200),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: getProportionateScreenHeight(200),
                                    width: getProportionateScreenWidth(200),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(0)),
                                    child: Card(
                                      elevation: 30,
                                      shadowColor: kPrimaryColor,
                                      color: kPrimaryColor,
                                      child: Column(
                                        children: [
                                          Container(
                                            height:
                                                getProportionateScreenHeight(
                                                    80),
                                            child: Text(
                                              'TP Verifications',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20),
                                            ),
                                          ),
                                          Container(
                                            height:
                                                getProportionateScreenHeight(
                                                    109),
                                            color: Colors.white,
                                            child: Text(
                                              'Please Scan The QR Code On The Transit Pass Form To Verify The Validity Of The TP',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: getProportionateScreenHeight(5),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(100)),
                                  ),
                                  Container(
                                    height: getProportionateScreenHeight(190),
                                    width: getProportionateScreenWidth(200),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(0)),
                                    child: Card(
                                        elevation: 20,
                                        shadowColor: kPrimaryColor,
                                        color: Colors.white,
                                        child: Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: SvgPicture.asset(
                                              'assets/icons/qr-code-scan.svg',
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                        )),
                                  )
                                ],
                              ),
                            ),
                          )
                  ],
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(20),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Container(
                    height: getProportionateScreenHeight(70),
                    child: _submitButton()),
              )
            ],
          )
        : AfterVerification(
            isScanned: true,
            role: widget.role,
            dealerName: dealerName,
            dealerType: dealerType,
            dfmNumber: dfmNumber,
            receiptDate: receiptDate,
            receiptNumber: receiptNumber,
            status: status,
            tpId: tpId,
            tpNumber: tpNumber,
            trailerNumber: trailerNumber,
            transportMode: transportMode,
            validDays: validDays,
            vehicleCategory: vehicleCategory,
            vehicleNumber: vehicleNumber,
          );
  }
}
