import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fremisAppV2/screens/dashboard/dashboarduicomponents.dart';
import 'package:fremisAppV2/screens/dashboard/drawer.dart';
import 'package:fremisAppV2/services/constants.dart';
import 'package:fremisAppV2/services/size_config.dart';
import 'package:fremisAppV2/services/usermodel.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pie_chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  static String routeName = "/dashboard";
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalVerified;
  int totalUnVerified;
  int totalExpired;
  String stationName;
  int totalCreatedTp;
  Map<String, double> dataMap;
  bool isLoading = false;
  String email;
  String roles;
  String checkpointName;
  int sum;
  Future dataStatus() async {
    setState(() {
      isLoading = true;
    });
    // print(tpNumber);
    String em = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('email'));
    String rolename = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('role'));
    String stationame = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('station_name'));
    String tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    checkpointName = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('checkpointname'));
    print(checkpointName);
    // int checkpointId = await SharedPreferences.getInstance()
    //     .then((prefs) => prefs.getInt('checkpointId'));
    // int stationId = await SharedPreferences.getInstance()
    //     .then((prefs) => prefs.getInt('station_id'));
    // int zoneId = await SharedPreferences.getInstance()
    //     .then((prefs) => prefs.getInt('zoneId'));
    //
    print(tokens);

    try {
      setState(() {});
      var headers = {"Authorization": "Bearer " + tokens.toString()};

      final response = await http.get(
          'http://41.59.227.103:9092/api/v1/tp-status/2020-08-12/2021-04-14',
          headers: headers);
      var res;

      print(response.statusCode);
      switch (response.statusCode) {
        case 201:
          res = json.decode(response.body);

          setState(() {
            print(res);
            print(stationame);
            email = em;
            stationName = stationame;
            roles = rolename;
            //  checkpointName = checkpointname;
            totalCreatedTp = res['data'][0]['totalCreatedTp'];
            totalUnVerified = res['data'][0]['totalUnVerified'];
            totalVerified = res['data'][0]['totalVerified'];
            totalExpired = res['data'][0]['totalExpired'];
            print(totalCreatedTp);
            print(totalUnVerified);
            print(totalExpired);
            print(totalVerified);
            int total =
                totalCreatedTp + totalUnVerified + totalExpired + totalVerified;
            sum = total;
            dataMap = {
              "Created TP [$totalCreatedTp]": totalCreatedTp.toDouble(),
              "Verified TP [$totalVerified]": totalVerified.toDouble(),
              "Expired TP [$totalExpired]": totalExpired.toDouble(),
              "Unverified TP [$totalUnVerified]": totalUnVerified.toDouble(),
              "Unchecked TP [0]": 0,
            };
            isLoading = false;
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
            // res = json.decode(response.body);
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

  Widget list(String title, String subtitle) {
    return Card(
      elevation: 10,
      shadowColor: kPrimaryColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kPrimaryColor,
          child: Icon(
            Icons.file_present,
            color: Colors.black,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios_outlined),
      ),
    );
  }

  @override
  void initState() {
    dataStatus();

    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final User arguments = ModalRoute.of(context).settings.arguments;
    String fname = arguments.fname.toString();
    String lname = arguments.lname.toString();
    return Scaffold(
        drawer: CustomDrawer(),
        appBar: AppBar(
          title: Text(
            'FremisApp Dashboard',
            style: TextStyle(color: Colors.black, fontFamily: 'Ubuntu'),
          ),
          backgroundColor: kPrimaryColor,
          actions: [popBar()],
        ),
        body: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            isLoading
                ? Center(
                    child: CupertinoActivityIndicator(
                    animating: true,
                    radius: 20,
                  ))
                : Container(
                    height: roles == 'FSUHQ' || roles == 'FSUZone'
                        ? getProportionateScreenHeight(300)
                        : getProportionateScreenHeight(400),
                    child: Stack(
                      children: [
                        Container(
                          height: getProportionateScreenHeight(200),
                          width: double.infinity,
                          color: kPrimaryColor,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(15, 20, 10, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Logged In As: $fname $lname',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 15),
                                ),
                                Text(
                                  'CP: $checkpointName',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                            alignment: roles == 'FSUHQ' || roles == 'FSUZone'
                                ? Alignment.center
                                : Alignment.bottomCenter,
                            child: DashboardUiComponents(
                              role: roles,
                            ))
                      ],
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                //  height: getProportionateScreenHeight(400),
                child: dataMap == null
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 10,
                          shadowColor: kPrimaryColor,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 10, bottom: 0),
                                child: Text(
                                  'Summary Of The TP Verifications Operations: Between  2020-08-12 and  2021-04-14     ',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Center(
                                  child: Text(
                                    'Total TP: $sum',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              isLoading
                                  ? CupertinoActivityIndicator(
                                      radius: 20,
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 10,
                                          left: 8,
                                          right: 8,
                                          top: 2),
                                      child: Card(
                                        elevation: 10,
                                        child: PieChart(
                                          dataMap: dataMap,
                                          animationDuration:
                                              Duration(milliseconds: 3800),
                                          chartLegendSpacing: 32,
                                          chartRadius: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3.2,
                                          colorList: [
                                            Colors.blue,
                                            kPrimaryColor,
                                            Colors.pink,
                                            Colors.redAccent,
                                            Colors.cyan,
                                          ],
                                          initialAngleInDegree: 50,
                                          chartType: ChartType.ring,
                                          ringStrokeWidth: 50,
                                          centerText: "stats",
                                          legendOptions: LegendOptions(
                                            showLegendsInRow: false,
                                            legendPosition:
                                                LegendPosition.right,
                                            showLegends: true,
                                            legendShape: BoxShape.circle,
                                            legendTextStyle: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black),
                                          ),
                                          chartValuesOptions:
                                              ChartValuesOptions(
                                            showChartValueBackground: true,
                                            showChartValues: true,
                                            showChartValuesInPercentage: true,
                                            showChartValuesOutside: true,
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ]),
        ));
  }

  popBar() {
    return Padding(
      padding: EdgeInsets.only(right: 10.0),
      child: PopupMenuButton(
        tooltip: 'Menu',
        child: Icon(
          Icons.more_vert,
          size: 28.0,
          color: Colors.black,
        ),
        offset: Offset(20, 40),
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Row(
              children: [
                Icon(
                  Icons.supervised_user_circle_rounded,
                  color: kPrimaryColor,
                  size: getProportionateScreenHeight(22),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    "Location: $stationName",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: kPrimaryColor,
                  size: getProportionateScreenHeight(22),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    'Checkpoint Name: $checkpointName',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
