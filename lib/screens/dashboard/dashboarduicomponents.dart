import 'package:fremisAppV2/screens/RejectedTp/rejectedTpScreen.dart';
import 'package:fremisAppV2/screens/statistics/statisticsScreen.dart';
import 'package:fremisAppV2/screens/verifiedTpScreen/verifiedTpScreen.dart';

import 'package:flutter/material.dart';
import 'package:fremisAppV2/screens/verification/verificationScreen.dart';
import 'package:fremisAppV2/services/constants.dart';
import 'package:fremisAppV2/services/size_config.dart';

class DashboardUiComponents extends StatefulWidget {
  final String role;
  DashboardUiComponents({this.role});
  @override
  _DashboardUiComponentsState createState() => _DashboardUiComponentsState();
}

class _DashboardUiComponentsState extends State<DashboardUiComponents> {
  Widget gridTile(String title, Icon icon) {
    return Container(
      height: getProportionateScreenHeight(50),
      width: getProportionateScreenWidth(152),
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          Text(
            title,
            style: TextStyle(
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          )
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.role == 'FSUHQ' || widget.role == 'FSUZone'
          ? getProportionateScreenHeight(200)
          : getProportionateScreenHeight(300),
      width: getProportionateScreenWidth(350),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: kPrimaryColor, blurRadius: 10, offset: Offset.zero)
          ],
          border: Border.all(
              color: Colors.black26, style: BorderStyle.solid, width: 1)),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 0,
        childAspectRatio: 3 / 2,
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, VerificationScreen.routeName,
                  arguments: widget.role);
            },
            child: gridTile(
                'Verification',
                Icon(
                  Icons.qr_code_outlined,
                  size: 50,
                  color: Colors.cyan,
                )),
          ),
          InkWell(
            onTap: () {
              widget.role == 'FSUHQ' || widget.role == 'FSUZone'
                  ? null
                  : Navigator.pushNamed(
                      context,
                      VerifiedTpScreen.routeName,
                    );
            },
            child: gridTile(
                widget.role == 'FSUHQ' || widget.role == 'FSUZone'
                    ? 'Reported TP'
                    : 'Verified TP',
                Icon(
                  widget.role == 'FSUHQ' || widget.role == 'FSUZone'
                      ? Icons.folder_open_rounded
                      : Icons.verified_user_outlined,
                  size: 50,
                  color: Colors.green[300],
                )),
          ),
          widget.role == 'FSUHQ' || widget.role == 'FSUZone'
              ? Container()
              : InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, RejectedTpScreen.routeName,
                        arguments: widget.role);
                  },
                  child: gridTile(
                      'Search Vehicle',
                      Icon(
                        Icons.search_outlined,
                        size: 50,
                        color: Colors.red[300],
                      )),
                ),
          widget.role == 'FSUHQ' || widget.role == 'FSUZone'
              ? Container()
              : InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      StatisticsScreen.routeName,
                    );
                  },
                  child: gridTile(
                      'Statistics',
                      Icon(
                        Icons.bar_chart_outlined,
                        size: 50,
                        color: Colors.blue[200],
                      )),
                ),
        ],
      ),
    );
  }
}
