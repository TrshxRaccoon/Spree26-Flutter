import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Hardcoded shared visuals for payment flows (not a ThemeData / theme page).
abstract final class PaymentsUi {
  static const Color bg = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceElevated = Color(0xFF141414);
  static const Color border = Color(0xFF334155);
  static const Color borderMuted = Color(0xFF1E293B);
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDisabled = Color(0xFF334155);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color error = Color(0xFFEF4444);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const String font = 'Inter';

  static const LinearGradient scanCardGradient = LinearGradient(
    colors: [Color(0xFFFF781E), Color(0xFFA01414)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Keeps forms readable on iPad / large phones (centered column).
  static double maxContentWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return math.min(480, w - 32);
  }

  static EdgeInsets horizontalPagePadding(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return EdgeInsets.symmetric(horizontal: narrow ? 20.w : 24.w);
  }

  static TextStyle displayTitle() => TextStyle(
        fontFamily: font,
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.2,
      );

  static TextStyle screenTitle() => TextStyle(
        fontFamily: font,
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle body({
    Color? color,
    FontWeight? weight,
    double? height,
  }) =>
      TextStyle(
        fontFamily: font,
        fontSize: 14.sp,
        fontWeight: weight ?? FontWeight.w400,
        color: color ?? textSecondary,
        height: height ?? 1.45,
      );

  static TextStyle bodySmall({Color? color}) => TextStyle(
        fontFamily: font,
        fontSize: 12.sp,
        color: color ?? textMuted,
        height: 1.4,
      );

  static TextStyle labelOverField() => TextStyle(
        fontFamily: font,
        fontSize: 13.sp,
        color: textSecondary,
      );

  static InputDecoration inputDecoration({
    required String hint,
    bool obscureHint = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: font,
        color: textMuted,
        fontSize: 14.sp,
        letterSpacing: obscureHint ? 0 : 0,
      ),
      filled: true,
      fillColor: surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
    );
  }

  static AppBar appBar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: bg,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: font,
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
    );
  }

  /// App bar with only a back control (screen title stays in body).
  static AppBar backOnlyAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: bg,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, size: 22.r, color: textPrimary),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }

  static ButtonStyle primaryButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      disabledBackgroundColor: primaryDisabled,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      textStyle: TextStyle(
        fontFamily: font,
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: borderMuted),
    );
  }

  static Widget centeredContent({
    required BuildContext context,
    required Widget child,
  }) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth(context)),
        child: child,
      ),
    );
  }
}
