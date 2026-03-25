import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spree/Payments/payment_failed.dart';
import 'package:spree/Payments/payment_success.dart';
import 'package:spree/Payments/payments_home.dart';
import 'package:spree/Payments/transaction_history.dart';
import 'package:spree/Screens/Sponsors/sponsors.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
//import 'package:no_screenshot/no_screenshot.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411.42857142857144, 911.2380952380952),
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // TRY THIS: Try running your application with "flutter run". You'll see
            // the application has a purple toolbar. Then, without quitting the app,
            // try changing the seedColor in the colorScheme below to Colors.green
            // and then invoke "hot reload" (save your changes or press the "hot
            // reload" button in a Flutter-supported IDE, or press "r" if you used
            // the command line to start the app).
            //
            // Notice that the counter didn't reset back to zero; the application
            // state is not lost during the reload. To reset the state, use hot
            // restart instead.
            //
            // This works for code too, not just values: Most code changes can be
            // tested with just a hot reload.
            colorScheme: .fromSeed(seedColor: Colors.deepPurple),
          ),
          //home: const MyHomePage(title: 'Flutter Demo Home Page'),
          home: Sponsors(),
        );
      },
    );
  }
}
