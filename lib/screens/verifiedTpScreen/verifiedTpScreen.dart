import 'package:flutter/material.dart';
import 'package:fremisAppV2/screens/verifiedTpScreen/verified.dart';
import 'package:fremisAppV2/services/constants.dart';

class VerifiedTpScreen extends StatefulWidget {
  static String routeName = "/verified";
  @override
  _VerifiedTpScreenState createState() => _VerifiedTpScreenState();
}

class _VerifiedTpScreenState extends State<VerifiedTpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'List Of Verified Tp',
          style: TextStyle(color: Colors.black, fontFamily: 'Ubuntu'),
        ),
      ),
      body: VerifiedTp(),
    );
  }
}
