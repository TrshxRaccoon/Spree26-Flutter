import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spree/Payments/payment_failed.dart';
import 'package:spree/Payments/payment_success.dart';
import 'package:spree/Payments/payments_home.dart';
import 'package:spree/Payments/transaction_history.dart';
import 'package:spree/Screens/Sponsors/sponsors.dart';
import 'package:spree/Screens/Homepage/homepage.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
//import 'package:no_screenshot/no_screenshot.dart';
import 'package:spree/Screens/login.dart';
import 'package:spree/Payments/set_pin.dart';
import 'package:spree/Payments/reset_pin.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Run initialization tasks in parallel for better performance
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]);

  // Initialize services in parallel
  await Future.wait([
    //NoScreenshot.instance.screenshotOff(),
    // Services().initialize(),
    // Config().initialize(),
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411.42857142857144, 911.2380952380952),
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: .fromSeed(seedColor: Colors.deepPurple),
          ),
          home: SetPin(),
        );
      },
    );
  }
}
