import 'package:flutter/material.dart';
import 'package:fremisAppV2/screens/RejectedTp/rejectedTp.dart';
import 'package:fremisAppV2/services/constants.dart';

class RejectedTpScreen extends StatefulWidget {
  static String routeName = "/rejected";
  @override
  _RejectedTpScreenState createState() => _RejectedTpScreenState();
}

class _RejectedTpScreenState extends State<RejectedTpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Search Screen',
          style: TextStyle(color: Colors.black, fontFamily: 'Ubuntu'),
        ),
      ),
      body: SingleChildScrollView(child: RejectedTp()),
    );
  }
}
