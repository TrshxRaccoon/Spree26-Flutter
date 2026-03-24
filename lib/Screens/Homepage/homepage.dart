import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:spree/Widgets/event_card.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  static const _storage = FlutterSecureStorage();
  bool _isGuest = true;

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
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            onPressed: () {
              debugPrint('Menu Clicked');
            },
            icon: Icon(Icons.menu, color: Color(0xFFCBD5E1)),
          ),
          actions: [
            IconButton(
              onPressed: () {
                debugPrint('Notifications Clicked');
              },
              icon: Icon(Icons.notifications_none, color: Color(0xFFCBD5E1)),
            ),
            SizedBox(width: 8),
          ],
        ),
        body: Stack(
          children: [
            Image.asset(
              width: double.infinity,
              'assets/homepage/homepage_bg.png',
              fit: BoxFit.cover,
            ),

            Center(
              child: Column(
                children: [
                  //SPREE LOGO
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Image.asset(
                        'assets/homepage/spree_logo.png',
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: EdgeInsetsGeometry.only(top: 10),
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

                  //EVENTS TAB
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Discover Events",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            debugPrint('View All Clicked');
                          },
                          child: Text(
                            "View All",
                            style: TextStyle(
                              color: Color(0xFFFF7A1A),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    height: 228.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(left: 16.w),
                      children: [
                        EventCard(
                          image: 'assets/events/battle_of_bands.png',
                          category: 'CULTURAL',
                          title: 'Battle of Bands',
                          date: 'Oct 24, 2026',
                        ),
                        SizedBox(width: 16.h),
                        EventCard(
                          image: 'assets/events/cricket.png',
                          category: 'SPORTS',
                          title: 'Cricket',
                          date: 'Oct 25, 2026',
                        ),
                        SizedBox(width: 16.h),
                        EventCard(
                          image: 'assets/events/fash_night.png',
                          category: 'ENTERTAINMENT',
                          title: 'Fashion Night',
                          date: 'Oct 26, 2026',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  //GALLERY TAB
                  Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Padding(
                          padding: EdgeInsetsGeometry.symmetric(
                            horizontal: 16.w,
                          ),
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
                                'Memories from Spree \'25',
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
                              Image.asset(
                                'assets/gallery/Image+Border+Shadow.png',
                              ),
                              SizedBox(width: 12.w),
                              Image.asset(
                                'assets/gallery/Image+Border+Shadow-1.png',
                              ),
                              SizedBox(width: 12.w),

                              Image.asset(
                                'assets/gallery/Image+Border+Shadow-2.png',
                              ),
                              SizedBox(width: 12.w),

                              Image.asset(
                                'assets/gallery/Image+Border+Shadow-3.png',
                              ),
                              SizedBox(width: 12.w),

                              Image.asset(
                                'assets/gallery/Image+Border+Shadow-4.png',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
