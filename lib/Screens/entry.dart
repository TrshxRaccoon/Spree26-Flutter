import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spree/Screens/Homepage/homepage.dart';
import 'package:spree/Screens/Login.dart';
import 'package:spree/Payments/payments_home.dart';
import 'package:spree/Screens/Events/events_page.dart';
import 'package:spree/Screens/placeholders/nav_placeholders.dart';
import 'package:spree/Services/config.dart';

class Entry extends StatefulWidget {
  final Future<void> Function()? onLogout;

  const Entry({super.key, this.onLogout});

  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  static const _storage = FlutterSecureStorage();
  int _currentIndex = 0;
  bool _isGuest = true;
  bool _isLoggingOut = false;

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

  Future<void> _handleLogoutTap() async {
    if (widget.onLogout == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF171717),
        title: Text(
          'Logout',
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70, fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Logout', style: TextStyle(color: Color(0xFFFF3355))),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isLoggingOut = true);
    try {
      await widget.onLogout!.call();
      if (!mounted) return;
      // Replace [Entry] so the user cannot navigate back into the signed-in shell.
      Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => LoginScreen(onLogoutForEntry: widget.onLogout),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = _isGuest;
    final showEvents = Config().showEvents;

    // Order must match bottom nav: Home → Events? → Payments? → Pass
    final pages = <Widget>[
      const Homepage(),
      if (showEvents) const EventsPage(),
      if (!isGuest) const PaymentsHome(),
      const PassPlaceholderPage(),
    ];

    final pageCount = pages.length;
    final passIndex = pageCount - 1;
    final paymentsIndex =
        !isGuest ? (showEvents ? 2 : 1) : null;
    final safeIndex = _currentIndex.clamp(0, pageCount - 1);
    if (safeIndex != _currentIndex && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentIndex = safeIndex);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      body: pages[safeIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: const BoxDecoration(
            color: Color(0xFF171717),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.home_outlined,
                      size: 24.r,
                      color: _currentIndex == 0 ? Colors.white : Colors.grey,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _currentIndex == 0 ? Colors.white : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (showEvents)
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 24.r,
                        color: _currentIndex == 1 ? Colors.white : Colors.grey,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Events',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _currentIndex == 1 ? Colors.white : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              if (!isGuest)
                GestureDetector(
                  onTap: () => setState(
                    () => _currentIndex = paymentsIndex!,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code_2,
                        size: 24.r,
                        color: paymentsIndex != null &&
                                _currentIndex == paymentsIndex
                            ? Colors.white
                            : Colors.grey,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Payments',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: paymentsIndex != null &&
                                  _currentIndex == paymentsIndex
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              GestureDetector(
                onTap: () => setState(() => _currentIndex = passIndex),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fingerprint,
                      size: 24.r,
                      color: _currentIndex == passIndex
                          ? Colors.white
                          : Colors.grey,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Pass',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _currentIndex == passIndex
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _isLoggingOut ? null : _handleLogoutTap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 24.r,
                      color: _isLoggingOut ? Colors.grey : Colors.white70,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _isLoggingOut ? Colors.grey : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}