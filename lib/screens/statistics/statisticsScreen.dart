import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:fremisAppV2/services/constants.dart';
import 'package:fremisAppV2/services/size_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  static String routeName = "/statistics";
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int totalVerified;
  int totalUnVerified;
  int sum;
  int totalExpired;
  int totalCreatedTp;
  bool isLoading = false;
  String startDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String endDate = '2020-08-12';
  bool errorMessage = false;
  bool isCustom = false;
  bool show = false;
  Map<String, double> dataMap;

  Future<DateTime> _selectDate(BuildContext context, String date) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    return picked;
  }

  Future dataStatus(String startDate, String endDate) async {
    print(startDate);
    print(endDate);
    setState(() {
      dataMap = null;
      isLoading = true;
    });

    String tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    // int checkpointId = await SharedPreferences.getInstance()
    //     .then((prefs) => prefs.getInt('checkpointId'));
    try {
      var headers = {"Authorization": "Bearer " + tokens};

      final response = await http.get(
          'http://41.59.227.103:9092/api/v1/tp-status/$endDate/$startDate',
          headers: headers);
      var res;

      print(response.statusCode);
      switch (response.statusCode) {
        case 201:
          res = json.decode(response.body);

          setState(() {
            totalCreatedTp = res['data'][0]['totalCreatedTp'];
            totalUnVerified = res['data'][0]['totalUnVerified'];
            totalVerified = res['data'][0]['totalVerified'];
            totalExpired = res['data'][0]['totalExpired'];
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
        case 200:
          setState(() {
            res = json.decode(response.body);
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
            isLoading = false;
            //    res = json.decode(response.body);
            print(res);
          });
          break;
      }
    } on SocketException {
      setState(() {
        isLoading = false;
        var res = 'Server Error';
        print(res);
      });
    }
  }

  @override
  void initState() {
    dataStatus(startDate, endDate);

    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String prevMonth = DateFormat('yyyy-MM-dd')
        .format(new DateTime(now.year, now.month - 1, now.day));
    String prevWeek = DateFormat('yyyy-MM-dd')
        .format(new DateTime(now.year, now.month, now.day - 7));
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: Text(
            'Statistics Details',
            style: TextStyle(color: Colors.black, fontFamily: 'Ubuntu'),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Card(
                  elevation: 10,
                  child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          show ? show = false : show = true;
                        });
                      },
                      leading: CircleAvatar(
                          child: Icon(Icons.pie_chart_outline_outlined)),
                      tileColor: Colors.white,
                      title: Text('Filter Data'),
                      trailing: Icon(
                        show
                            ? Icons.arrow_drop_down
                            : Icons.arrow_drop_up_outlined,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              show
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Card(
                        elevation: 10,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: ListTile(
                                  onTap: () async {
                                    setState(() {
                                      startDate = formattedDate;
                                      endDate = formattedDate;
                                    });

                                    await dataStatus(startDate, endDate);
                                  },
                                  leading: CircleAvatar(
                                      backgroundColor: Color(0xfff3f3f4),
                                      child:
                                          Icon(Icons.calendar_today_outlined)),
                                  tileColor: Color(0xfff3f3f4),
                                  title: Text('Today'),
                                  subtitle: Text('$formattedDate'),
                                  trailing: Icon(
                                    Icons.filter_list_outlined,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      startDate = formattedDate;
                                      endDate = prevWeek;
                                    });
                                    print(endDate);
                                    dataStatus(startDate, endDate);
                                  },
                                  leading: CircleAvatar(
                                      backgroundColor: Color(0xfff3f3f4),
                                      child:
                                          Icon(Icons.calendar_today_outlined)),
                                  tileColor: Color(0xfff3f3f4),
                                  title: Text('Last Week'),
                                  subtitle: Text('$prevWeek - $formattedDate'),
                                  trailing: Icon(
                                    Icons.filter_list_outlined,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      startDate = formattedDate;
                                      endDate = prevMonth;
                                    });
                                    dataStatus(startDate, endDate);
                                  },
                                  leading: CircleAvatar(
                                      backgroundColor: Color(0xfff3f3f4),
                                      child:
                                          Icon(Icons.calendar_today_outlined)),
                                  tileColor: Color(0xfff3f3f4),
                                  title: Text('Last Month'),
                                  subtitle: Text('$prevMonth - $formattedDate'),
                                  trailing: Icon(
                                    Icons.filter_list_outlined,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      errorMessage = false;
                                      isCustom
                                          ? isCustom = false
                                          : isCustom = true;
                                      startDate = null;
                                      endDate = null;
                                    });
                                  },
                                  leading: CircleAvatar(
                                      backgroundColor: Color(0xfff3f3f4),
                                      child:
                                          Icon(Icons.calendar_today_outlined)),
                                  tileColor: Color(0xfff3f3f4),
                                  title: Text('Custom Date'),
                                  trailing: Icon(
                                    Icons.filter_list_outlined,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                              isCustom
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        // height: getProportionateScreenHeight(60),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                                'Select Start Date And End Date'),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                InkWell(
                                                  onTap: () async {
                                                    DateTime x =
                                                        await _selectDate(
                                                            context, startDate);
                                                    setState(() {
                                                      errorMessage = false;
                                                      startDate = DateFormat(
                                                              'yyyy-MM-dd')
                                                          .format(x);
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      height:
                                                          getProportionateScreenHeight(
                                                              50),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          color: Colors.cyan),
                                                      child: Center(
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              '  Start Date  ',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            Text(
                                                              startDate == null
                                                                  ? ''
                                                                  : startDate,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    DateTime x =
                                                        await _selectDate(
                                                            context, startDate);
                                                    setState(() {
                                                      errorMessage = false;
                                                      endDate = DateFormat(
                                                              'yyyy-MM-dd')
                                                          .format(x);
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      height:
                                                          getProportionateScreenHeight(
                                                              50),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          color: Colors.cyan),
                                                      child: Center(
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              '  End Date  ',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            Text(
                                                              endDate == null
                                                                  ? ''
                                                                  : endDate,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    if (startDate != null &&
                                                        endDate != null) {
                                                      await dataStatus(
                                                          startDate, endDate);
                                                    } else {
                                                      setState(() {
                                                        errorMessage = true;
                                                      });
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      height:
                                                          getProportionateScreenHeight(
                                                              50),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          color: Colors.cyan),
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              '  Filter Data ',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              errorMessage
                                  ? Text('Please Select The Date Range First')
                                  : Container()
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(),
              isLoading
                  ? Container(
                      height: getProportionateScreenHeight(200),
                      child: Center(
                        child: CupertinoActivityIndicator(
                          animating: true,
                          radius: 20,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        // height: getProportionateScreenHeight(350),
                        child: dataMap == null
                            ? Card(
                                elevation: 10,
                                child: Container(
                                  width: double.infinity,
                                  child: Center(
                                    child: Text(
                                        'There is No Data Within That Range'),
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 0, right: 0, top: 0, bottom: 0),
                                    child: Text(
                                      'Summary Of The TP Verifications Operations: Between  $startDate and  $endDate',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 1),
                                    child: Center(
                                      child: Text(
                                        'Total TP: $sum',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Card(
                                    elevation: 10,
                                    shadowColor: kPrimaryColor,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 20,
                                          left: 5,
                                          right: 5,
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
                                          centerText: "Total = $sum",
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
                                  ),
                                ],
                              ),
                      ),
                    ),
            ],
          ),
        ));
  }
}
