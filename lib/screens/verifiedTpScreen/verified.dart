import 'dart:convert';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fremisAppV2/screens/verification/afterverification.dart';
import 'package:fremisAppV2/services/constants.dart';
import 'package:fremisAppV2/services/size_config.dart';
import 'package:fremisAppV2/services/tpdataModel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifiedTp extends StatefulWidget {
  @override
  _VerifiedTpState createState() => _VerifiedTpState();
}

class _VerifiedTpState extends State<VerifiedTp> {
  List<TpDataModel> _tpData = List<TpDataModel>();
  List<TpDataModel> _tpDataDisplay = List<TpDataModel>();
  bool isLoading = false;
  bool isVerified = false;
  var data;
  var tpDatas;
  Future<List<TpDataModel>> getVerifiedTp() async {
    // print(tpNumber);
    setState(() {
      isLoading = true;
    });
    String tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    int checkpointId = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getInt('checkpointId'));
    try {
      setState(() {});
      var headers = {"Authorization": "Bearer " + tokens};

      final response = await http.get(
          'http://41.59.227.103:9092/api/v1/tp-totalVerified/$checkpointId',
          headers: headers);
      var res;
      var tpData = List<TpDataModel>();
      print(response.statusCode);
      switch (response.statusCode) {
        case 201:
          var res = json.decode(response.body);
          var tp = res['data'];
          tpDatas = res['data'];

          for (var item in tp) {
            tpData.add(TpDataModel.fromJson(item));
          }
          setState(() {
            print(tp);
            print(tpData);
            isLoading = false;
          });
          return tpData;

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
            res = json.decode(response.body);
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
    getVerifiedTp().then((value) {
      setState(() {
        _tpData.addAll(value);
        _tpDataDisplay = _tpData;
      });
    });

    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isVerified
        ? SingleChildScrollView(
            child: AfterVerification(
              dealerName: data['dealer'].toString(),
              dealerType: data['dealer_type'].toString(),
              dfmNumber: data['dfm_phone'].toString(),
              receiptDate: data['receipt_date'].toString(),
              receiptNumber: data['receipt_no'].toString(),
              status: false,
              tpNumber: data['tp_number'],
              trailerNumber: data['trailer_no'],
              transportMode: data['transport_mode'],
              tpId: data['id'],
              isScanned: false,
              validDays: data['valid_days'].toString(),
              //vehicleCategory: data['vehicle_no'],
              vehicleNumber: data['vehicle_no'].toString(),
            ),
          )
        : Column(
            children: [
              Container(
                height: getProportionateScreenHeight(90),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                child: searchBar(),
              ),
              isLoading
                  ? SpinKitWave(
                      color: kPrimaryColor,
                    )
                  : Expanded(
                      child: ListView.builder(
                          itemCount: _tpDataDisplay.length,
                          itemBuilder: (context, index) {
                            return _lisItem(index);
                          }),
                    ),
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
      padding: const EdgeInsets.all(10.0),
      child: TextField(
          cursorColor: kPrimaryColor,
          enabled: true,
          onChanged: (value) {
            value = value.toLowerCase();
            setState(() {
              _tpDataDisplay = _tpData.where((tpdata) {
                var tpNo = tpdata.transitPass['tp_number'];
                return tpNo.contains(value);
              }).toList();
            });
          },
          showCursor: true,
          decoration: InputDecoration(
              enabled: true,
              hintText: 'Search For Any TP',
              // enabledBorder: outlineInputBorder,
              suffix: Icon(
                Icons.search_outlined,
                color: kPrimaryColor,
              ),
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true)),
    );
  }

  _lisItem(int index) {
    int no = index + 1;
    return Card(
      elevation: 5,
      shadowColor: kPrimaryColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          onTap: () {
            setState(() {
              data = tpDatas[index]['transit_pass'];

              isVerified = true;
            });
          },
          leading: CircleAvatar(child: Text(no.toString())),
          title:
              Text('TP No: ' + _tpDataDisplay[index].transitPass['tp_number']),
          subtitle: Text(
            'Dealer Name: ' + _tpDataDisplay[index].transitPass['dealer'],
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_outlined,
            color: kPrimaryColor,
          ),
        ),
      ),
    );
  }
}
