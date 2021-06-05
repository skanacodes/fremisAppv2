import 'dart:convert';
import 'dart:io';
import 'package:fremisAppV2/screens/verification/afterverification.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fremisAppV2/services/constants.dart';
import 'package:fremisAppV2/services/size_config.dart';
import 'package:fremisAppV2/services/tpdataModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RejectedTp extends StatefulWidget {
  @override
  _RejectedTpState createState() => _RejectedTpState();
}

class _RejectedTpState extends State<RejectedTp> {
  bool isLoading = false;
  String plateno = '';
  bool isInfo = false;
  var tpdata = {};
  bool isVerified = false;
  bool isNotFound = false;

  Future<void> getVerifiedTp() async {
    // print(tpNumber);
    setState(() {
      isLoading = true;
    });
    String tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));

    try {
      setState(() {});
      var headers = {"Authorization": "Bearer " + tokens};

      final response = await http.get(
          'http://41.59.227.103:9092/api/v1/vehicle-transit-pass/$plateno',
          headers: headers);
      var res;

      print(response.statusCode);
      switch (response.statusCode) {
        case 201:
          var res = json.decode(response.body);

          setState(() {
            //print(tp);
            if (res['message'] == 'Transit pass not found') {
              isNotFound = true;
            } else {
              tpdata = res;
            }

            print(res);

            isLoading = false;
          });

          break;
        case 404:
          setState(() {
            res = json.decode(response.body);
            isLoading = false;
            isNotFound = true;
            print(res);
          });
          break;

        case 401:
          setState(() {
            res = json.decode(response.body);
            isLoading = false;
            print(res);
          });
          break;
        default:
          setState(() {
            //  res = json.decode(response.body);
            isLoading = false;
            print(res);
          });
          break;
      }
    } on SocketException {
      setState(() {
        var res = 'Server Error';
        isLoading = false;
        print(res);
      });
    }
  }

  @override
  void initState() {
    // getVerifiedTp().then((value) {
    //   setState(() {
    //     _tpData.addAll(value);
    //     _tpDataDisplay = _tpData;
    //   });
    // });

    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String arguments = ModalRoute.of(context).settings.arguments;
    print(arguments);
    return isVerified
        ? AfterVerification(
            dealerName: tpdata['data']['dealer'],
            dealerType: tpdata['data']['dealer_type'],
            dfmNumber: tpdata['data']['dfm_phone'],
            receiptDate: tpdata['data']['receipt_date'],
            receiptNumber: tpdata['data']['receipt_no'],
            status: tpdata['validity'] == 'false' ? false : true,
            tpNumber: tpdata['data']['tp_number'],
            trailerNumber: tpdata['data']['trailer_no'],
            transportMode: tpdata['data']['transport_mode'],
            tpId: tpdata['data']['id'],
            role: arguments,
            isScanned: false,
            validDays: tpdata['data']['valid_days'].toString(),
            //vehicleCategory: tpdata['data']['vehicle_no'],
            vehicleNumber: tpdata['data']['vehicle_no'].toString(),
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 5),
                child: Card(
                  elevation: 10,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.pink,
                      child: Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                    ),
                    title: Text('Search For Any Vehicle By Plate Number'),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 10,
                ),
                child: Container(
                  height: getProportionateScreenHeight(70),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                  child: searchBar(),
                ),
              ),
              isInfo
                  ? Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 5, bottom: 5),
                      child: Card(
                        elevation: 10,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.pink,
                            child: Icon(
                              Icons.info_outline,
                              color: Colors.black,
                            ),
                          ),
                          title: Text(
                              'Please Enter Vehicle Number Before You Search'),
                        ),
                      ),
                    )
                  : Container(),
              isNotFound
                  ? Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 5, bottom: 5),
                      child: Card(
                        elevation: 10,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.pink,
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: Colors.black,
                            ),
                          ),
                          title: Text('Vehicle Is Not Found'),
                        ),
                      ),
                    )
                  : Container(),
              tpdata.isEmpty
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 25, bottom: 5),
                      child: Card(
                        elevation: 10,
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              isVerified = true;
                            });
                          },
                          leading: CircleAvatar(
                            backgroundColor: kPrimaryColor,
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.black,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_outlined,
                            color: Colors.pink,
                          ),
                          subtitle: Text('Dealer: ' + tpdata['data']['dealer']),
                          title:
                              Text('TP-Number: ' + tpdata['data']['tp_number']),
                        ),
                      ),
                    ),
              isLoading
                  ? SpinKitWave(
                      color: kPrimaryColor,
                    )
                  : Container()
            ],
          );
  }

  searchBar() {
    OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(color: Colors.black54),
      gapPadding: 10,
    );

    return Padding(
        padding: EdgeInsets.only(
          left: 10,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: TextField(
                cursorColor: kPrimaryColor,
                enabled: true,
                onChanged: (value) {
                  // value = value.toLowerCase();
                  setState(() {
                    plateno = value;
                    isInfo = false;
                    isNotFound = false;
                  });
                },
                showCursor: true,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.cyan,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.brown,
                      width: 1.0,
                    ),
                  ),
                  fillColor: Color(0xfff3f3f4),
                  filled: true,
                  labelText: "Enter Vehicle Number",
                  border: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(5)),
                    width: getProportionateScreenWidth(80),
                    height: getProportionateScreenHeight(60),
                    child: IconButton(
                      color: Colors.black,
                      icon: Icon(Icons.search),
                      onPressed: () async {
                        setState(() {
                          tpdata = {};
                        });
                        plateno.isEmpty
                            ? setState(() {
                                isInfo = true;
                              })
                            : await getVerifiedTp();
                      },
                    ),
                  ),
                ))
          ],
        ));
  }
}
