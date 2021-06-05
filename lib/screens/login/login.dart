import 'dart:convert';
import 'dart:io';

import 'package:fremisAppV2/screens/dashboard/dashboardScreen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fremisAppV2/screens/login/Widget/bezierContainer.dart';

import 'package:fremisAppV2/services/constants.dart';
import 'package:flutter/material.dart';
import 'package:fremisAppV2/services/form_error.dart';
import 'package:fremisAppV2/services/size_config.dart';
import 'package:fremisAppV2/services/usermodel.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = "/login";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isaUser = false;
  bool isLoading = false;
  String username;
  String password;
  final List<String> errors = [];
  var roles = [];
  String fname;
  String lname;
  String tok;
  Future<void> createUser(
    String token,
    int userId,
    int stationId,
    int zoneId,
    String fname,
    String lname,
    String email,
    String phoneNumber,
    int checkpointId,
    String checkpointname,
    String stationName,
    String roleCheck,
  ) async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('user_id', userId);
      prefs.setString('token', token);
      prefs.setInt('station_id', stationId);
      prefs.setInt('zoneId', zoneId);
      prefs.setString('fname', fname);
      prefs.setString('lname', lname);
      prefs.setString('email', email);
      prefs.setString('phoneNumber', phoneNumber);
      prefs.setInt('checkpointId', checkpointId);
      prefs.setString('role', roleCheck);
      prefs.setString('checkpointname', checkpointname);
      prefs.setString('station_name', stationName);
    });
  }

  Future<String> getUserDetails() async {
    try {
      final response = await http.post(
        'http://41.59.227.103:9092/api/login',
        body: {'email': username, 'password': password},
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          String roleCheck;

          setState(() {
            res = json.decode(response.body);
            print(res);
          });

          int i = 0;
          setState(() {
            while (i <= res['roles'].length - 1) {
              var role1 = res['roles'][i]['role_name'];
              print(role1);
              if (role1 == 'FSUHQ' ||
                  role1 == 'Checkpoint' ||
                  role1 == 'FSUZone') {
                roleCheck = role1;

                // print(roleCheck + '  dwidiw ejwue');
              }
              roles.add(role1);
              // print(roles);
              i++;
            }
            fname = res['user']['first_name'];
            lname = res['user']['last_name'];
            tok = res['access_token'];
          });

          await createUser(
              res['access_token'],
              res['user']['id'],
              res['user']['station_id'],
              res['user']['zone_id'],
              res['user']['first_name'],
              res['user']['last_name'],
              res['user']['email'],
              res['user']['phone'],
              res['user']['checkpoint_id'],
              res['user']['checkpoint']['name'],
              res['user']['station']['name'],
              roleCheck);

          return 'success';
          break;

        case 401:
          setState(() {
            res = json.decode(response.body);
            print(res);
            addError(error: 'Incorrect Password or Email');
          });
          return 'fail';
          break;
        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            addError(error: res['Something Went Wrong']);
          });
          return 'fail';
          break;
      }
    } catch (e) {
      setState(() {
        print(e);
        addError(error: 'Server Or Network Connectivity Error');
      });
      return 'fail';
    }
  }

  void addError({String error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error);
      });
  }

  void removeError({String error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }

  Widget _entryField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text(
              title,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          TextFormField(
              onChanged: (value) {
                if (value.isNotEmpty) {
                  errors.contains('Network Problem')
                      ? removeError(
                          error: 'Server Or Network Connectivity Error')
                      : errors.contains('Incorrect Password or Email')
                          ? removeError(error: 'Incorrect Password or Email')
                          : removeError(
                              error: 'Your Not Authourized To Use This App');
                }
                return null;
              },
              validator: (value) => value == ''
                  ? 'This  Field Is Required'
                  : emailValidatorRegExp.hasMatch(value)
                      ? null
                      : !isPassword
                          ? 'provide Valid Email Address'
                          : null,
              onSaved: (value) {
                setState(() {
                  isPassword ? password = value : username = value;
                });
              },
              keyboardType: TextInputType.emailAddress,
              cursorColor: kPrimaryColor,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState.validate()) {
          _formKey.currentState.save();
          setState(() {
            isLoading = true;
          });
          String val = await getUserDetails();
          if (val == 'success') {
            if (roles.contains('Checkpoint') ||
                roles.contains('FSUHQ') ||
                roles.contains('FSUZone')) {
              Navigator.pushNamed(context, DashboardScreen.routeName,
                  arguments: User(fname: fname, lname: lname));
            } else {
              addError(error: 'Your Not Authourized To Use This App');
            }
          }
          setState(() {
            isLoading = false;
          });
        }
      },
      child: isLoading
          ? SpinKitWave(
              color: kPrimaryColor,
            )
          : Container(
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
                'Login',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
    );
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('v.1.0.0'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Tanzania  ',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.display1,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0XFF105F01),
          ),
          children: [
            TextSpan(
              text: 'Forest  ',
              style: TextStyle(color: Color(0XFF105F01), fontSize: 20),
            ),
            TextSpan(
              text: 'Services  ',
              style: TextStyle(color: Color(0XFF105F01), fontSize: 20),
            ),
            TextSpan(
              text: 'Agency  ',
              style: TextStyle(color: Color(0XFF105F01), fontSize: 20),
            ),
            TextSpan(
              text: '(TFS).',
              style: TextStyle(color: Color(0XFF105F01), fontSize: 20),
            ),
          ]),
    );
  }

  Widget _title2() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Fremis',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.display1,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.green[400],
          ),
          children: [
            TextSpan(
              text: 'App',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ]),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("User id"),
        _entryField("Password", isPassword: true),
      ],
    );
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned(
              top: -height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: getProportionateScreenHeight(100)),
                      _title(),
                      Container(
                        decoration: BoxDecoration(
                            // border: Border.all(
                            //     color: Colors.cyan,
                            //     style: BorderStyle.solid,
                            //     width: 1),
                            ),
                        height: getProportionateScreenHeight(150),
                        width: getProportionateScreenHeight(150),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(20)),
                      _title2(),
                      SizedBox(height: getProportionateScreenHeight(20)),
                      _emailPasswordWidget(),
                      FormError(errors: errors),
                      SizedBox(height: getProportionateScreenHeight(15)),
                      _submitButton(),
                      SizedBox(height: getProportionateScreenHeight(15)),
                      _divider(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
