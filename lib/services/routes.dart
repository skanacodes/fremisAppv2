import 'package:fremisAppV2/screens/ImageScreen/imagescreen.dart';
import 'package:fremisAppV2/screens/RejectedTp/rejectedTpScreen.dart';
import 'package:fremisAppV2/screens/dashboard/dashboardScreen.dart';
import 'package:fremisAppV2/screens/splash/splashscreen.dart';
import 'package:flutter/widgets.dart';
import 'package:fremisAppV2/screens/login/login.dart';
import 'package:fremisAppV2/screens/statistics/statisticsScreen.dart';
import 'package:fremisAppV2/screens/verification/verificationScreen.dart';
import 'package:fremisAppV2/screens/verifiedTpScreen/verifiedTpScreen.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  DashboardScreen.routeName: (context) => DashboardScreen(),
  VerificationScreen.routeName: (context) => VerificationScreen(),
  StatisticsScreen.routeName: (context) => StatisticsScreen(),
  VerifiedTpScreen.routeName: (context) => VerifiedTpScreen(),
  RejectedTpScreen.routeName: (context) => RejectedTpScreen(),
  ImageScreen.routeName: (context) => ImageScreen(),
};
