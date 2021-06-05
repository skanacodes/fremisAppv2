import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fremisAppV2/services/routes.dart';
import 'package:fremisAppV2/services/theme.dart';
import 'package:fremisAppV2/screens/splash/splashscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer _timer;

  void _initializeTimer() {
    print('Timer');
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _logOutUser);
  }

  void _logOutUser() {
    // Log out the user if they're logged in, then cancel the timer.
    // You'll have to make sure to cancel the timer if the user manually logs out
    //   and to call _initializeTimer once the user logs in
    print('logout');
    SharedPreferences.getInstance().then((prefs) {
      prefs.clear();
    });
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    _timer.cancel();
  }

  // You'll probably want to wrap this function in a debounce
  void _handleUserInteraction([_]) {
    if (!_timer.isActive) {
      // This means the user has been logged out
      return;
    }

    _timer.cancel();
    _initializeTimer();
  }

  @override
  void initState() {
    _initializeTimer();
    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleUserInteraction,
      onPanDown: _handleUserInteraction,
      onScaleStart: _handleUserInteraction,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FremisApp',
        theme: theme(),
        // home: SplashScreen(),
        // We use routeName so that we dont need to remember the name
        initialRoute: SplashScreen.routeName,
        routes: routes,
      ),
    );
  }
}
