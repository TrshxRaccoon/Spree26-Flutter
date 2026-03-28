import 'dart:convert';
import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import 'package:spree/Services/config.dart';

/// Loads `pass_portal_url` from Firestore (`config/api_config` on DB `spree-26`
/// via [Config]), then GET `{pass_portal_url}/pass?email=...`.
class GatePassScreen extends StatefulWidget {
  const GatePassScreen({super.key});

  @override
  State<GatePassScreen> createState() => _GatePassScreenState();
}

class _GatePassScreenState extends State<GatePassScreen> {
  late final WebViewController _webViewController;
  final _emailController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  static const _storage = FlutterSecureStorage();
  Map<String, dynamic>? passData;
  String? errorMessage;
  final Config _config = Config();
  bool isLoading = false;

  static const _bg = Color(0xFF171717);
  static const _accent = Color(0xFFFF7A1A);
  static const _card = Color(0xFF1E1E1E);
  static const _errorBg = Color(0xFF2A0F14);
  static const _errorBorder = Color(0xFFFF3355);

  @override
  void initState() {
    super.initState();
    _loadEmailAndPass();
    _initializeConfig();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://drive.google.com/file/d/') &&
                request.url.contains('/preview')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
          onHttpError: (HttpResponseError error) {
            _showErrorSnackBar();
          },
          onWebResourceError: (WebResourceError error) {
            _showErrorSnackBar();
          },
        ),
      )
      ..setBackgroundColor(Colors.transparent);
  }

  Future<void> _initializeConfig() async {
    await _config.initialize();
    if (_config.passPortalUrl == null) {
      await _config.fetchPassPortalUrl();
    }
  }

  Future<void> _loadEmailAndPass() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      if (account != null) {
        setState(() {
          _emailController.text = account.email;
        });
        fetchPass();
        return;
      }
    } catch (_) {}

    final stored = await _storage.read(key: 'user_email');
    if (stored != null && stored.isNotEmpty) {
      setState(() {
        _emailController.text = stored;
      });
      fetchPass();
    }
  }

  String getGoogleDriveDirectUrl(String sharingUrl) {
    if (sharingUrl.contains('open?id=')) {
      final fileId = sharingUrl.split('open?id=').last;
      return 'https://drive.google.com/file/d/$fileId/preview';
    }

    final regExp = RegExp(r'/d/([a-zA-Z0-9-_]+)');
    final match = regExp.firstMatch(sharingUrl);
    if (match != null) {
      final fileId = match.group(1);
      return 'https://drive.google.com/file/d/$fileId/preview';
    }

    return sharingUrl;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Widget buildPhotoWidgetforIOS(String photoUrl) {
    final isIOS = Platform.isIOS;

    if (isIOS) {
      String fileId = '';
      if (photoUrl.contains('open?id=')) {
        fileId = photoUrl.split('open?id=').last;
      } else {
        final regExp = RegExp(r'/d/([a-zA-Z0-9-_]+)');
        final match = regExp.firstMatch(photoUrl);
        if (match != null) {
          fileId = match.group(1)!;
        }
      }

      final imageUrl = 'https://drive.google.com/uc?export=download&id=$fileId';

      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 30.w,
              height: 30.w,
              child: const CircularProgressIndicator(
                color: _accent,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.error_outline,
              color: _errorBorder,
              size: 40.w,
            ),
          );
        },
      );
    } else {
      return WebViewWidget(controller: _webViewController);
    }
  }

  Future<void> fetchPass() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      passData = null;
    });

    try {
      await _config.fetchPassPortalUrl();

      if (_config.passPortalUrl == null || _config.passPortalUrl!.isEmpty) {
        _showErrorSnackBar();
        return;
      }

      final email = _emailController.text.trim();
      if (email.isEmpty) {
        setState(() {
          errorMessage = 'No email available. Please sign in again.';
        });
        return;
      }

      final base = _config.passPortalUrl!.replaceAll(RegExp(r'/+$'), '');
      final uri = Uri.parse('$base/pass').replace(
        queryParameters: {'email': email},
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body) as Map<String, dynamic>;
        if (decodedData['photo'] != null && Platform.isAndroid) {
          final directUrl =
              getGoogleDriveDirectUrl(decodedData['photo'] as String);
          final htmlContent = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          body { margin: 0; padding: 0; overflow: hidden; }
          iframe { width: 100%; height: 100vh; border: none; }
        </style>
      </head>
      <body>
        <iframe src="$directUrl" frameborder="0" allowfullscreen></iframe>
      </body>
      </html>
    ''';
          await _webViewController.loadHtmlString(htmlContent);
        }
        setState(() {
          passData = decodedData;
        });
      } else if (response.statusCode == 404 || response.statusCode == 401) {
        setState(() {
          errorMessage = 'No pass associated with this account';
        });
      } else {
        _showErrorSnackBar();
      }
    } catch (e) {
      _showErrorSnackBar();
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          'Gate Pass',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: _accent.withValues(alpha: 0.85), width: 1.w),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : fetchPass,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 28.w,
                          height: 28.w,
                          child: const CircularProgressIndicator(
                            color: _accent,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Refresh Pass',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 24.h),
              if (errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: _errorBg,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: _errorBorder),
                  ),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      color: _errorBorder,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (passData != null) ...[
                if (passData?['photo'] != null)
                  Container(
                    width: 200.w,
                    height: 200.w,
                    decoration: BoxDecoration(
                      color: _card.withValues(alpha: 0.9),
                      border: Border.all(
                        color: _accent.withValues(alpha: 0.5),
                        width: 1.w,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: buildPhotoWidgetforIOS(passData!['photo'] as String),
                    ),
                  ),
                SizedBox(height: 24.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: _card.withValues(alpha: 0.9),
                    border: Border.all(
                      color: _accent.withValues(alpha: 0.5),
                      width: 1.w,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pass Details',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildDetailRow('Name', passData?['name'] ?? ''),
                      _buildDetailRow('College', passData?['college'] ?? ''),
                      _buildDetailRow('Type', passData?['type'] ?? ''),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: _card.withValues(alpha: 0.9),
                    border: Border.all(
                      color: _accent.withValues(alpha: 0.5),
                      width: 1.w,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Pass Barcode',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: BarcodeWidget(
                          barcode: Barcode.code128(),
                          data: passData?['id'] ?? '',
                          width: 250.w,
                          height: 100.h,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                color: _accent.withValues(alpha: 0.95),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Error! Please try again later',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        backgroundColor: _errorBorder,
      ),
    );
  }
}
