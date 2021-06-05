import 'package:flutter/material.dart';
import 'package:fremisAppV2/screens/verification/scanQr.dart';
import 'package:fremisAppV2/services/constants.dart';

class VerificationScreen extends StatefulWidget {
  static String routeName = "/verification";
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  @override
  Widget build(BuildContext context) {
    final String arguments = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        backgroundColor: Color(0xFFF6FBFC),
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: Text(
            'Verification Of TP',
            style: TextStyle(color: Colors.black, fontFamily: 'Ubuntu'),
          ),
        ),
        body: SingleChildScrollView(
          child: ScanQr(
            role: arguments,
          ),
        ));
  }
}
