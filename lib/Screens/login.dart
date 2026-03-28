import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spree/Screens/entry.dart';
import 'package:spree/Services/config.dart';
import 'package:spree/Services/payments.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';

class LoginScreen extends StatefulWidget {
  /// When opened from logout, pass this so Entry gets the logout callback after re-login.
  final Future<void> Function()? onLogoutForEntry;

  const LoginScreen({super.key, this.onLogoutForEntry});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool isAppleAuthEnabled = false;

  final Color _buttonBgColor = const Color(0xFF14123D);
  final Color _buttonTextColor = const Color(0xFFB1CBF8);

  @override
  void initState() {
    super.initState();
    _checkAppleAuthEnabled();
  }

  Future<void> _checkAppleAuthEnabled() async {
    isAppleAuthEnabled = await Config().isAppleAuthEnabled();
    setState(() {
      isAppleAuthEnabled = isAppleAuthEnabled;
    });
  }

  Future<void> _handleSignIn() async {
    setState(() {});

    try {
      debugPrint('Starting Google Sign-In process');

      // Clear any existing session first
      if (await _googleSignIn.isSignedIn()) {
        debugPrint('Clearing existing session');
        await _googleSignIn.signOut();
        await _googleSignIn.disconnect();
        await _storage.delete(key: 'user_name');
        await _storage.delete(key: 'user_email');
        await _storage.delete(key: 'user_type');
      }

      // debugPrint('Attempting to sign in with Google');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        debugPrint('Google Sign-In successful: ${googleUser.email}');

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        String? idToken = googleAuth.idToken;
        debugPrint('idToken: $idToken');
        // debugPrint('ID Token obtained: ${idToken != null ? 'Yes' : 'No'}');

        if (idToken != null) {
          try {
            debugPrint('Fetching API configuration');
            // await Config().fetchAndStoreApiUrl();

            debugPrint('Processing authentication');
            String userType = await Services().auth(idToken);
            debugPrint('User type determined: $userType');

            try {
              await _storage.write(
                key: 'user_name',
                value: googleUser.displayName,
              );
              await _storage.write(key: 'user_email', value: googleUser.email);
              await _storage.write(key: 'user_type', value: userType);
            } catch (e) {}

            debugPrint('User data stored successfully');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Signed in as: ${googleUser.displayName}",
                  style: TextStyle(fontFamily: "Cinzel"),
                ),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate to Entry screen only after successful authentication
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Entry(onLogout: widget.onLogoutForEntry),
              ),
            );
          } catch (authError) {
            debugPrint('Authentication processing failed: $authError');
            _showSnackBar(
              "Authentication failed. Please try again.",
              Colors.red,
            );
          }
        } else {
          debugPrint('No ID token received from Google');
          _showSnackBar(
            "Authentication failed. No token received.",
            Colors.red,
          );
        }
      } else {
        debugPrint('Google Sign-In was canceled by user');
        _showSnackBar("Sign-in canceled", Colors.orange);
      }
    } catch (error) {
      debugPrint('Error during Google Sign-In: $error');
      _showSnackBar(
        "Sign in failed. Please check your connection and try again.",
        Colors.red,
      );
    } finally {
      setState(() {});
    }
  }

  void _handleAppleSignIn() async {
    try {
      final credentials = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (credentials.userIdentifier != null) {
        debugPrint('Apple Sign In Success');

        String? userName;
        try {
          await _storage.write(key: 'user_type', value: 'guest');

          userName =
              credentials.givenName != null && credentials.familyName != null
              ? '${credentials.givenName} ${credentials.familyName}'
              : credentials.givenName ?? 'Apple User';

          await _storage.write(key: 'user_name', value: userName);
          await _storage.write(
            key: 'user_email',
            value: credentials.email ?? '',
          );
        } catch (e) {}

        debugPrint('Apple user data stored successfully');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Signed in as: $userName",
              style: TextStyle(fontFamily: "Cinzel"),
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Entry(onLogout: widget.onLogoutForEntry),
          ),
        );
      } else {
        debugPrint('Apple Sign In failed - no user identifier');
        _showSnackBar("Apple Sign In failed. Please try again.", Colors.red);
      }
    } catch (error) {
      debugPrint('Apple Sign In Error: $error');
      _showSnackBar(
        "Sign in failed. Please check your connection.",
        Colors.red,
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontFamily: "Cinzel")),
        backgroundColor: color,
      ),
    );
  }

  Widget _buildAuthButton({
    Widget? iconWidget,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 342.w,
        height: 56.h,
        decoration: BoxDecoration(
          color: const Color(0xFF707070).withOpacity(0.20),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFF3250A0).withOpacity(0.30),
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            // Exact 51x44 bounded box for the icon based on your spec
            SizedBox(
              width: 51.w,
              height: 44.h,
              child: Center(child: iconWidget),
            ),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Dummy SizedBox to perfectly balance the row and keep the text completely centered
            SizedBox(width: 51.w),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Login/Login_bg.gif'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 14.h), // Top offset
                    // 1. UNLEASH THE UNTAMED (Using Container instead of Padding)
                    Container(
                      margin: EdgeInsets.only(left: 17.w),
                      width: 236.w,
                      child: Text(
                        "UNLEASH\nTHE\nUNTAMED",
                        style: TextStyle(
                          fontFamily: 'Akira Expanded',
                          fontSize: 26.sp,
                          height: 21 / 26,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 1.2.w
                            ..color = const Color(0xFFAEAEAE),
                        ),
                      ),
                    ),

                    // MANDATORY SPACING
                    SizedBox(height: 47.h),

                    // 2. SPREE LOGO (Using Container instead of Padding)
                    Container(
                      margin: EdgeInsets.only(left: 34.w),
                      child: Image.asset(
                        'assets/Login/Spree_logo.png',
                        width: 324.w,
                        height: 137.h,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // This Spacer is critical for tablets. It automatically absorbs
                    // the empty space so you don't need a hardcoded height like 243.h
                    const Spacer(flex: 2),

                    // 3. AUTHENTICATION BUTTONS CONTAINER (Using Container instead of Padding)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 24.w),
                      width: double.infinity,
                      child: Column(
                        children: [
                          _buildAuthButton(
                            iconWidget: SvgPicture.asset(
                              'assets/Login/google_icon.svg',
                              height: 24.h,
                            ),
                            text: 'Continue with Google',
                            onTap: _handleSignIn,
                          ),

                          if (Platform.isIOS) ...[
                            SizedBox(height: 16.h),
                            _buildAuthButton(
                              iconWidget: Icon(
                                Icons.apple_rounded,
                                color: Colors.white,
                                size: 30.sp,
                              ),
                              text: 'Continue with Apple',
                              onTap: _handleAppleSignIn,
                            ),
                          ],

                          // SizedBox(height: 16.h),
                          // _buildAuthButton(
                          //   iconWidget: Icon(
                          //     Icons.apple_rounded,
                          //     color: Colors.white,
                          //     size: 30.sp,
                          //   ),
                          //   text: 'Continue with Apple',
                          //   onTap: _handleAppleSignIn,
                          // ),
                        ],
                      ),
                    ),

                    // This bottom spacer keeps the buttons from sitting completely on the bottom edge
                    const Spacer(flex: 1),

                    SizedBox(height: 24.h), // Small bottom safe-area offset
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
