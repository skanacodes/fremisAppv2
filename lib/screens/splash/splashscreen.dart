import 'dart:async';

import 'package:fremisAppV2/screens/login/login.dart';
import 'package:fremisAppV2/services/permissions_service.dart';
import 'package:fremisAppV2/services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    _determinePosition();
    PermissionsService().requestCameraandlocationPermission();

    Timer(Duration(seconds: 3), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
      // SharedPreferences.getInstance().then((prefs) {
      //   print(prefs.get('id').toString());
      //   if (prefs.get('id').toString() != 'null') {
      //     // Navigator.push(context,
      //     //     MaterialPageRoute(builder: (context) => InventoryListScreen()));
      //   } else {
      //     Navigator.push(
      //         context, MaterialPageRoute(builder: (context) => LoginScreen()));
      //   }
      // });
    });
    super.initState();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    // You have to call it on your starting screen
    SizeConfig().init(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Welcome To Fremis App',
            style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: getProportionateScreenWidth(20)),
          ),
          Container(
            height: getProportionateScreenHeight(150),
            width: getProportionateScreenHeight(150),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: getProportionateScreenHeight(30),
          ),
          SpinKitWave(
            color: Colors.green,
          )
        ],
      ),
    );
  }
}
