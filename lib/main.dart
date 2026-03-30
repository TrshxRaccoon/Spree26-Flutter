import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:spree/Screens/entry.dart';
import 'package:spree/Screens/login.dart';
import 'package:spree/Services/config.dart';
import 'package:spree/Services/payments.dart';
import 'package:spree/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]);

  await Future.wait([
    NoScreenshot.instance.screenshotOff(),
    Services().initialize(),
    Config().initialize(),
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isSignedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
  }

  Future<void> _checkSignInStatus() async {
    try {
      final results = await Future.wait([
        _storage.read(key: 'user_name'),
        _storage.read(key: 'user_email'),
        _storage.read(key: 'user_type'),
        _googleSignIn.signInSilently(),
      ]);

      final userName = results[0] as String?;
      final userEmail = results[1] as String?;
      final userType = results[2] as String?;
      final googleUser = results[3] as GoogleSignInAccount?;

      if (googleUser != null &&
          userName != null &&
          userEmail != null &&
          userType != null) {
        if (mounted) {
          setState(() {
            _isSignedIn = true;
            _isLoading = false;
          });
        }
      } else {
        if (googleUser == null &&
            (userName != null || userEmail != null || userType != null)) {
          await _clearStoredData();
        }
        if (mounted) {
          setState(() {
            _isSignedIn = false;
            _isLoading = false;
          });
        }
      }
    } catch (error) {
      await _clearStoredData();
      if (mounted) {
        setState(() {
          _isSignedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _clearStoredData() async {
    try {
      await Future.wait([
        _storage.delete(key: 'user_name'),
        _storage.delete(key: 'user_email'),
        _storage.delete(key: 'user_type'),
        _storage.delete(key: 'access_token'),
      ]);

      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      try {
        await _googleSignIn.disconnect();
      } catch (_) {}
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411.42857142857144, 911.2380952380952),
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Spree 26',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: _isLoading
              ? Scaffold(
                  backgroundColor: Colors.black,
                  body: Center(
                    child: SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : _buildHomeScreen(),
        );
      },
    );
  }

  Widget _buildHomeScreen() {
    if (_isSignedIn) {
      return Entry(onLogout: _handleLogout);
    }
    return LoginScreen(onLogoutForEntry: _handleLogout);
  }

  Future<void> _handleLogout() async {
    try {
      await Services().logout();
    } catch (_) {
      // Always continue with local sign-out so the user can exit the session.
    }
    await _clearStoredData();
    if (mounted) {
      setState(() {
        _isSignedIn = false;
      });
    }
  }
}
