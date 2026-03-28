import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final ScrollController _scrollController = ScrollController();
  static const _storage = FlutterSecureStorage();
  bool _isGuest = true;

  String youtubeUrl = "https://youtu.be/dQw4w9WgXcQ";

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final userType = await _storage.read(key: 'user_type');
    if (mounted) {
      setState(() => _isGuest = userType == 'guest');
    }
  }

  String? _extractVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
    }

    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    }

    return null;
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'Exit App',
              style: TextStyle(color: Colors.black, letterSpacing: 0.1.sp),
            ),
            content: Text(
              'Are you sure you want to exit the app?',
              style: TextStyle(color: Colors.black, fontSize: 14.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'No',
                  style: TextStyle(color: Colors.black, fontSize: 14.sp),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Yes',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldExit = await _onWillPop();
          if (shouldExit) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.black54,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => debugPrint('Menu Clicked'),
            icon: Icon(Icons.menu, color: Color(0xFFCBD5E1)),
          ),
          actions: [
            IconButton(
              onPressed: () => debugPrint('Notifications Clicked'),
              icon: Icon(Icons.notifications_none, color: Color(0xFFCBD5E1)),
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                double offset = 0;
                if (_scrollController.hasClients) {
                  offset = -_scrollController.offset * 0.045;
                }
                return Transform.translate(
                  offset: Offset(0, offset),
                  child: child,
                );
              },
              child: Image.asset(
                'assets/homepage/homepage_bg.png',
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Center(
                  child: Column(
                    children: [
                      // SPREE LOGO
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Image.asset(
                            'assets/homepage/spree_logo.png',
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              'Unleash the Untamed',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'QwitcherGrypen',
                                fontSize: 34,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      // GALLERY TAB
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Gallery",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Memories from Spree '25",
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            SizedBox(
                              height: 128.h,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.only(left: 16.w),
                                children: [
                                  SizedBox(
                                    child: Image.asset(
                                      'assets/gallery/Image+Border+Shadow.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  SizedBox(
                                    child: Image.asset(
                                      'assets/gallery/Image+Border+Shadow-1.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  SizedBox(
                                    child: Image.asset(
                                      'assets/gallery/Image+Border+Shadow-2.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  SizedBox(
                                    child: Image.asset(
                                      'assets/gallery/Image+Border+Shadow-3.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  SizedBox(
                                    child: Image.asset(
                                      'assets/gallery/Image+Border+Shadow-4.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsetsGeometry.only(
                            left: 16.w,
                            right: 16.w,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(
                                sigmaX: 5.0,
                                sigmaY: 5.0,
                              ),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: youtubeUrl.isEmpty
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () async {
                                          final uri = Uri.parse(youtubeUrl);
                                          if (!await launchUrl(
                                            uri,
                                            mode:
                                                LaunchMode.externalApplication,
                                          )) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Could not open YouTube video',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              'https://i.ytimg.com/vi/${_extractVideoId(youtubeUrl) ?? ''}/hqdefault.jpg',
                                              fit: BoxFit.cover,
                                            ),
                                            Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .play_circle_fill_rounded,
                                                    color: Colors.orange,
                                                    size: 64.w,
                                                  ),
                                                  Text(
                                                    "WATCH THE SPREE '25 AFTERMOVIE",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
