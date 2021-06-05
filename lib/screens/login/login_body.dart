import 'package:fremisAppV2/services/constants.dart';
import 'package:fremisAppV2/services/size_config.dart';
import 'package:flutter/material.dart';

import 'signin_form.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Log',
                    style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: getProportionateScreenHeight(30)),
                  ),
                  Text(
                    'in',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: getProportionateScreenHeight(30)),
                  ),
                  SizedBox(
                    width: getProportionateScreenWidth(10),
                  ),
                  Text(
                    'Fo',
                    style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: getProportionateScreenHeight(30)),
                  ),
                  Text(
                    'rm',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: getProportionateScreenHeight(30)),
                  ),
                ],
              ),
              SignInForm(),
              SizedBox(height: SizeConfig.screenHeight * 0.08),
            ],
          ),
        ),
      ),
    );
  }
}
