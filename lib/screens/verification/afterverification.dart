import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fremisAppV2/screens/ImageScreen/imagescreen.dart';
import 'package:fremisAppV2/screens/verification/utility.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fremisAppV2/services/constants.dart';
import 'package:fremisAppV2/services/size_config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AfterVerification extends StatefulWidget {
  final int tpId;
  final String role;
  final bool isScanned;
  final bool status;
  final String tpNumber;
  final String dealerName;
  final String vehicleNumber;
  final String trailerNumber;
  final String receiptNumber;
  final String vehicleCategory;
  final String dealerType;
  final String receiptDate;
  final String transportMode;
  final String dfmNumber;
  final String validDays;
  AfterVerification(
      {this.role,
      this.dealerName,
      this.dealerType,
      this.isScanned,
      this.dfmNumber,
      this.receiptDate,
      this.receiptNumber,
      this.status,
      this.tpId,
      this.tpNumber,
      this.trailerNumber,
      this.transportMode,
      this.validDays,
      this.vehicleCategory,
      this.vehicleNumber});
  @override
  _AfterVerificationState createState() => _AfterVerificationState();
}

class _AfterVerificationState extends State<AfterVerification> {
  bool isLoading = false;
  File image;
  String imagepath1;
  String imagepath2;
  final picker = ImagePicker();
  bool isClicked = false;
  bool showCheckPoints = false;
  bool showTpProduct = false;
  String checkPointName;
  List tpProductName = [];
  List quanties = [];
  List volumeAll = [];
  int i = 0;
  File imageVal1;
  File imageVal2;
  String verCode;
  String recoveryRate;
  bool isLoadCheckPoint = false;
  bool isLoadTpProduct = false;
  String imgString1;
  String imgString2;
  List checkpointlist = [];
  List verfyTime = [];
  List verificationCodelist = [];
  loading() {
    return Center(
      child: SpinKitFadingFour(
        color: kPrimaryColor,
      ),
    );
  }

  message(
    String desc,
    String type,
  ) {
    return Alert(
      context: context,
      type: type == 'success' ? AlertType.success : AlertType.error,
      title: widget.role == 'FSUHQ' || widget.role == 'FSUZone'
          ? 'Information'
          : "Code: $verCode",
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

  Widget _submitButton() {
    return isLoading
        ? CupertinoActivityIndicator(
            animating: true,
            radius: 20,
          )
        : InkWell(
            onTap: () async {
              await postVarifiedTp();
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
                widget.role == 'FSUHQ' || widget.role == 'FSUZone'
                    ? 'Report Inconvenience'
                    : 'Submit',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          );
  }

  Future<void> postVarifiedTp() async {
    setState(() {
      isLoading = true;
    });
    String tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    int checkpoint = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getInt('checkpointId'));
    print(checkpoint);
    var headers = {"Authorization": "Bearer " + tokens};
    try {
      String url = 'http://41.59.227.103:9092/api/v1/tp-verified';
      final response = await http.post(url,
          body: {
            "tp_id": widget.tpId.toString(),
            "honey_tp_id": '',
            "checkpoint_id": checkpoint.toString(),
            "station_id": '9',
            "zone_id": '',
            "ward_id": '',
            "verification_code": "9Q8L",
            "quantity_exceeded": '',
            "unit_id": '',
            "penalty_amount": '',
            "commitment_form": '',
            "payment_form": '',
            "verified_officer": '397',
            "remarks": '',
            "image_file": imgString1,
            "image_file2": imgString2,
            "image_file3": imgString1
          },
          headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            verCode = res['id'].toString();
          });
          isLoading = false;
          message(
            widget.role == 'FSUHQ' || widget.role == 'FSUZone'
                ? 'Report For Inconvinience Was Successfull Sent'
                : 'Transit Pass Was Successfull Verified',
            'success',
          );
          break;

        case 401:
          setState(() {
            res = json.decode(response.body);
            isLoading = false;
            print(res);
          });
          message('Error Has Occured', 'error');
          break;
        default:
          setState(() {
            res = json.decode(response.body);
            isLoading = false;
            print(res);
          });
          break;
      }
    } on SocketException {
      setState(() {
        String res = 'Server Error';
        print(res);
        isLoading = false;
        message('Network Connectivity Error', 'error');
      });
    }
  }

  Future previousCheckPoint() async {
    print('////,,,,,,,,,,');
    // print(tpNumber);
    String tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    try {
      setState(() {});
      var headers = {"Authorization": "Bearer " + tokens};
      final tpid = widget.tpId;
      final response = await http.get(
          'http://41.59.227.103:9092/api/v1/tp-checkpoint/$tpid',
          headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 201:
          res = json.decode(response.body);

          setState(() {
            print(res);
            checkPointName = res['data'][0]['db_checkpoint']['name'];
            print(checkPointName);
            int i = 0;
            List x = [];
            List y = [];
            List time = [];
            while (i <= res['data'].length - 1) {
              var checkpointz = res['data'][i]['db_checkpoint']['name'];
              var n = res['data'][i]['correct_verification_code'];
              var d = res['data'][i]['created_at'];
              print(checkpointz);
              x.add(checkpointz);
              y.add(n);
              time.add(d);
              print(x);
              print(y);
              print(time);
              checkpointlist = x;
              verificationCodelist = y;
              verfyTime = time;

              i++;
            }

            print(res['data'].length);
            isLoadCheckPoint = false;
          });
          break;

        case 401:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isLoadCheckPoint = false;
          });
          break;
        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isLoadCheckPoint = false;
          });
          break;
      }
    } on SocketException {
      setState(() {
        var res = 'Server Error';
        print(res);
        isLoadCheckPoint = false;
      });
    }
  }

  _openDetail(context, index, name) {
    print(name);
    final route = MaterialPageRoute(
      builder: (context) => ImageScreen(
        index: index,
        checkpointname: name,
      ),
    );
    Navigator.push(context, route);
  }

  checkpointsImage(int index, String name) {
    return Expanded(
      flex: 3,
      child: InkWell(
        onTap: () {
          _openDetail(context, index, name);
        },
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black38, width: 2),
              borderRadius: BorderRadius.circular(5)),
          child: CircleAvatar(
              maxRadius: 15,
              backgroundColor: Colors.pink,
              child: SvgPicture.asset(
                'assets/icons/addpic.svg',
                height: getProportionateScreenHeight(40),
                fit: BoxFit.contain,
              )),
        ),
      ),
    );
  }

  Future tpProductDetails() async {
    // print(tpNumber);
    String tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    try {
      setState(() {});
      var headers = {"Authorization": "Bearer " + tokens};
      final tpid = widget.tpId;
      final response = await http.get(
          'http://41.59.227.103:9092/api/v1/tp-product/$tpid',
          headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 201:
          setState(() {
            res = json.decode(response.body);

            print(res);
            int i = 0;
            List x = [];
            List y = [];
            List volumes = [];
            while (i <= res['data'].length - 1) {
              var productname = res['data'][i]['product']['product_name'];
              var quantity = res['data'][i]['quantity'];
              var volume = res['data'][i]['volume'];

              x.add(productname);
              y.add(quantity);
              volumes.add(volume);
              print(x);
              print(y);
              print(volumes);
              tpProductName = x;
              quanties = y;
              volumeAll = volumes;

              i++;
            }

            isLoadTpProduct = false;
          });
          break;

        case 401:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isLoadTpProduct = false;
          });
          break;
        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isLoadTpProduct = false;
          });
          break;
      }
    } on SocketException {
      setState(() {
        var res = 'Server Error';
        print(res);
        isLoadTpProduct = false;
      });
    }
  }

  checkPoints() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Container(
        // height: showCheckPoints
        //     ? getProportionateScreenHeight(
        //         150 * checkpointlist.length.toDouble())
        //     : getProportionateScreenHeight(60),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  blurRadius: 10,
                  color: Colors.grey,
                  spreadRadius: 3,
                  offset: Offset.zero)
            ],
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: kPrimaryColor,
                  ),
                  Text(
                    'Previous CheckPoints Details',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                      onTap: () async {
                        if (showCheckPoints) {
                          setState(() {
                            showCheckPoints = false;
                          });
                        } else {
                          setState(() {
                            showCheckPoints = true;
                            isLoadCheckPoint = true;
                          });
                          await previousCheckPoint();
                        }
                      },
                      child: showCheckPoints
                          ? Icon(
                              Icons.keyboard_arrow_up,
                              size: 30,
                            )
                          : Icon(
                              Icons.keyboard_arrow_down,
                              size: 30,
                            ))
                ],
              ),
            ),
            showCheckPoints
                ? Divider(
                    color: kPrimaryColor,
                    height: getProportionateScreenHeight(10),
                    thickness: 2,
                  )
                : Container(),
            for (var i = 0; i < checkpointlist.length; i++)
              isLoadCheckPoint
                  ? loading()
                  : showCheckPoints
                      ? Container(
                          child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Icon(
                                          Icons.emoji_transportation_outlined,
                                          color: Colors.purple,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 6,
                                        child: Text('CheckPoint - Name: ' +
                                            checkpointlist[i].toString()),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.code_outlined,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(
                                        width: getProportionateScreenWidth(10),
                                      ),
                                      Text('Verification-Code: ' +
                                          verificationCodelist[i].toString()),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Icon(
                                          Icons.time_to_leave_outlined,
                                          color: Colors.pink,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text('Verification-Time: '),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(verfyTime[i].toString()),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Center(
                                        child: Text(
                                          'List Of Images Taken At This Checkpoint',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          width: 20,
                                        ),
                                      ),
                                      checkpointsImage(
                                          i, checkpointlist[i].toString()),
                                      Expanded(
                                        child: SizedBox(
                                          width: 20,
                                        ),
                                      ),
                                      checkpointsImage(
                                          i, checkpointlist[i].toString()),
                                      SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                            '--------------------------------------------------------------'),
                                      )
                                    ],
                                  ),
                                ],
                              )),
                        )
                      : Container(),
          ],
        ),
      ),
    );
  }

  tpProduct() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Container(
        // height: showTpProduct
        //     ? getProportionateScreenHeight(245)
        //     : getProportionateScreenHeight(60),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  blurRadius: 10,
                  color: Colors.grey,
                  spreadRadius: 3,
                  offset: Offset.zero)
            ],
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: kPrimaryColor,
                  ),
                  Text(
                    'TP Product  Details',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                      onTap: () async {
                        if (showTpProduct) {
                          setState(() {
                            showTpProduct = false;
                          });
                        } else {
                          setState(() {
                            showTpProduct = true;
                            isLoadTpProduct = true;
                          });
                          await tpProductDetails();
                        }
                      },
                      child: showTpProduct
                          ? Icon(
                              Icons.keyboard_arrow_up,
                              size: 30,
                            )
                          : Icon(
                              Icons.keyboard_arrow_down,
                              size: 30,
                            ))
                ],
              ),
            ),
            showTpProduct
                ? Divider(
                    color: kPrimaryColor,
                    height: getProportionateScreenHeight(10),
                    thickness: 2,
                  )
                : Container(),
            for (var i = 0; i < tpProductName.length; i++)
              isLoadTpProduct
                  ? loading()
                  : showTpProduct
                      ? Container(
                          child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.add_shopping_cart,
                                        color: Colors.purple,
                                      ),
                                      SizedBox(
                                        width: getProportionateScreenWidth(10),
                                      ),
                                      Text('Product Name: ' +
                                          tpProductName[i].toString()),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.code_outlined,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(
                                        width: getProportionateScreenWidth(10),
                                      ),
                                      Text('Quantity: ' +
                                          quanties[i].toString()),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.assignment_outlined,
                                        color: Colors.pink,
                                      ),
                                      SizedBox(
                                        width: getProportionateScreenWidth(10),
                                      ),
                                      Text(
                                          'Volume: ' + volumeAll[i].toString()),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                          '-------------------**---------------')
                                    ],
                                  )
                                ],
                              )),
                        )
                      : Container(),
          ],
        ),
      ),
    );
  }

  Future getImage(String val) async {
    var _image;

    final pickedFile =
        await picker.getImage(source: ImageSource.camera, imageQuality: 40);

    if (pickedFile != null) {
      setState(() {
        val == 'img1'
            ? imageVal1 = File(pickedFile.path)
            : imageVal2 = File(pickedFile.path);
        val == 'img1'
            ? imgString1 = Utility.base64String(imageVal1.readAsBytesSync())
            : imgString2 = Utility.base64String(imageVal2.readAsBytesSync());
        imagepath1 = pickedFile.path;
        print(pickedFile.path);
        print(imgString1 ?? imgString2);
      });

      return _image;
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: getProportionateScreenHeight(120),
          decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(100),
                bottomRight: Radius.circular(100),
              )),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  // height: isClicked
                  //     ? getProportionateScreenHeight(630)
                  //     : getProportionateScreenHeight(300),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 10,
                            color: Colors.grey,
                            spreadRadius: 3,
                            offset: Offset.zero)
                      ],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: kPrimaryColor,
                            ),
                            SizedBox(
                              width: getProportionateScreenWidth(10),
                            ),
                            Text(
                              'Transit pass Informations',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: kPrimaryColor,
                        height: getProportionateScreenHeight(10),
                        thickness: 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            widget.status
                                ? Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.verified_outlined,
                                      color: kPrimaryColor,
                                    ),
                                  )
                                : Icon(
                                    Icons.wrap_text_outlined,
                                    color: Colors.red,
                                  ),
                            SizedBox(
                              width: getProportionateScreenWidth(10),
                            ),
                            widget.status
                                ? Text(
                                    'Validation Status: Valid',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  )
                                : Text('Validation Status: Expired',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.brightness_1_outlined,
                              color: Colors.orange,
                            ),
                            SizedBox(
                              width: getProportionateScreenWidth(10),
                            ),
                            Text('TP Number: ' + widget.tpNumber.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.supervised_user_circle_outlined,
                                color: Colors.blue,
                              ),
                            ),
                            Expanded(flex: 2, child: Text('Dealer:')),
                            Expanded(
                                flex: 6,
                                child: Text(widget.dealerName.toString())),
                          ],
                        ),
                      ),
                      isClicked
                          ? Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.car_repair,
                                    color: Colors.deepPurple,
                                  ),
                                  SizedBox(
                                    width: getProportionateScreenWidth(10),
                                  ),
                                  Text(
                                      'Vehicle Number: ' +
                                          widget.vehicleNumber.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          : Container(),
                      isClicked
                          ? Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.train,
                                    color: Colors.teal,
                                  ),
                                  SizedBox(
                                    width: getProportionateScreenWidth(10),
                                  ),
                                  Text('Trailer Number: ' +
                                      widget.trailerNumber.toString()),
                                ],
                              ),
                            )
                          : Container(),
                      isClicked
                          ? Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.calendar_view_day,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: getProportionateScreenWidth(10),
                                  ),
                                  Text('Receipt Date: ' +
                                      widget.receiptDate.toString()),
                                ],
                              ),
                            )
                          : Container(),
                      isClicked
                          ? Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.car_rental,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(
                                    width: getProportionateScreenWidth(10),
                                  ),
                                  Text('Vehicle Category: ' +
                                      widget.vehicleCategory.toString()),
                                ],
                              ),
                            )
                          : Container(),
                      isClicked
                          ? Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.details_rounded,
                                    color: Colors.indigo,
                                  ),
                                  SizedBox(
                                    width: getProportionateScreenWidth(10),
                                  ),
                                  Text(
                                      'dealer type: ' +
                                          widget.dealerType.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          : Container(),
                      isClicked
                          ? Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    color: Colors.lime,
                                  ),
                                  SizedBox(
                                    width: getProportionateScreenWidth(10),
                                  ),
                                  Text('Receipt Number: ' +
                                      widget.receiptNumber.toString()),
                                ],
                              ),
                            )
                          : Container(),
                      isClicked
                          ? Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.emoji_transportation_outlined,
                                    color: Colors.purple,
                                  ),
                                  SizedBox(
                                    width: getProportionateScreenWidth(10),
                                  ),
                                  Text(
                                      'Transport Mode: ' +
                                          widget.transportMode.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          : Container(),
                      isClicked
                          ? Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.supervised_user_circle_outlined,
                                    color: Colors.lime,
                                  ),
                                  SizedBox(
                                    width: getProportionateScreenWidth(10),
                                  ),
                                  Text(
                                      'Dfm Phone Number: ' +
                                          widget.dfmNumber.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          children: [
                            Divider(
                              color: Colors.black,
                            ),
                            Text(
                              isClicked
                                  ? 'Click An Arrow To See Fewer Details'
                                  : 'Click An Arrow To See Full Details',
                            ),
                            Divider(
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                          onTap: () {
                            setState(() {
                              isClicked ? isClicked = false : isClicked = true;
                            });
                          },
                          child: Icon(isClicked
                              ? Icons.arrow_circle_up_outlined
                              : Icons.arrow_drop_down_circle_outlined))
                    ],
                  ),
                ),
              ),
              checkPoints(),
              SizedBox(
                height: getProportionateScreenHeight(10),
              ),
              tpProduct(),
              SizedBox(
                height: getProportionateScreenHeight(10),
              ),
              widget.isScanned
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Stack(
                        children: [
                          Container(
                            height: getProportionateScreenHeight(60),
                            width: getProportionateScreenHeight(360),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      kPrimaryColor,
                                      Colors.green[100]
                                    ])),
                            child: Center(
                                child: Text(
                              'Take Pictures For Verification',
                              style: TextStyle(color: Colors.black),
                            )),
                          ),
                          getPics()
                        ],
                      ),
                    )
                  : Container(),
              widget.isScanned
                  ? SizedBox(
                      height: getProportionateScreenHeight(1),
                    )
                  : Container(),
              widget.isScanned
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            getImage('img1');
                          },
                          child: Container(
                            child: Column(
                              children: [
                                Container(
                                  height: getProportionateScreenHeight(300),
                                  width: getProportionateScreenHeight(220),
                                  decoration: BoxDecoration(
                                      color: Color(0xfff3f3f4),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.black12,
                                          style: BorderStyle.solid,
                                          width: 1)),
                                  child: imageVal1 == null
                                      ? Icon(
                                          Icons.add_a_photo_outlined,
                                          size: 100,
                                        )
                                      : Image.file(
                                          imageVal1,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            getImage('img2');
                          },
                          child: Container(
                            child: Column(
                              children: [
                                Container(
                                  height: getProportionateScreenHeight(300),
                                  width: getProportionateScreenHeight(220),
                                  decoration: BoxDecoration(
                                      color: Color(0xfff3f3f4),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.black12,
                                          style: BorderStyle.solid,
                                          width: 1)),
                                  child: imageVal2 == null
                                      ? Icon(
                                          Icons.add_a_photo_outlined,
                                          size: 100,
                                        )
                                      : Image.file(
                                          imageVal2,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(),
              widget.isScanned ? SizedBox(height: 20) : Container(),
              widget.isScanned
                  ? Padding(padding: EdgeInsets.all(10), child: _submitButton())
                  : Container(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  getPic() {
    return Row(
      children: [
        InkWell(
          // onTap: () => getImage('img2'),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: Colors.white, style: BorderStyle.solid, width: 5)),
              child: CircleAvatar(
                  radius: 25,
                  foregroundColor: Colors.black,
                  child: SvgPicture.asset(
                    'assets/icons/imageAdd.svg',
                    height: getProportionateScreenHeight(40),
                    fit: BoxFit.contain,
                  )),
            ),
          ),
        ),
      ],
    );
  }

  getPics() {
    return InkWell(
      onTap: () => null,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: Colors.white, style: BorderStyle.solid, width: 5)),
          child: CircleAvatar(
              radius: 25,
              foregroundColor: Colors.black,
              child: SvgPicture.asset(
                'assets/icons/addpic.svg',
                height: getProportionateScreenHeight(40),
                fit: BoxFit.contain,
              )),
        ),
      ),
    );
  }
}
