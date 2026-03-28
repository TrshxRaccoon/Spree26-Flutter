import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spree/Payments/payments_ui.dart';
import 'package:spree/Services/payments.dart';

class ResetPin extends StatefulWidget {
  const ResetPin({super.key});

  @override
  State<ResetPin> createState() => _ResetPinState();
}

class _ResetPinState extends State<ResetPin> {
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final Services _services = Services();

  /// Step 1: Send OTP. Step 2: Enter OTP + new PIN.
  int _step = 1;
  bool _isLoading = false;

  late FocusNode _otpFocus;
  late FocusNode _newPinFocus;
  late FocusNode _confirmPinFocus;

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _otpFocus = FocusNode();
    _newPinFocus = FocusNode();
    _confirmPinFocus = FocusNode();
    _otpFocus.addListener(_onFocusChanged);
    _newPinFocus.addListener(_onFocusChanged);
    _confirmPinFocus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _otpFocus.removeListener(_onFocusChanged);
    _newPinFocus.removeListener(_onFocusChanged);
    _confirmPinFocus.removeListener(_onFocusChanged);
    _newPinController.dispose();
    _confirmPinController.dispose();
    _otpController.dispose();
    _otpFocus.dispose();
    _newPinFocus.dispose();
    _confirmPinFocus.dispose();
    super.dispose();
  }

  /// Wave 1: Call reset-pin request-otp endpoint to send OTP.
  Future<void> _sendOTP() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await _services.requestOTP();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _step = 2;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'OTP sent to your registered email',
            style: PaymentsUi.body(color: PaymentsUi.onPrimary),
          ),
          backgroundColor: const Color(0xFF16A34A),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to send OTP: ${e.toString()}',
            style: PaymentsUi.body(color: PaymentsUi.onPrimary),
          ),
          backgroundColor: PaymentsUi.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Resend OTP (same endpoint as send).
  Future<void> _resendOTP() async {
    if (_isLoading) return;
    await _sendOTP();
  }

  bool _validateStep2() {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter the OTP',
            style: PaymentsUi.body(color: PaymentsUi.onPrimary),
          ),
          backgroundColor: PaymentsUi.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    }
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'OTP must be 6 digits',
            style: PaymentsUi.body(color: PaymentsUi.onPrimary),
          ),
          backgroundColor: PaymentsUi.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    }
    if (_newPinController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter exactly 6 digits for new PIN',
            style: PaymentsUi.body(color: PaymentsUi.onPrimary),
          ),
          backgroundColor: PaymentsUi.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    }
    if (_confirmPinController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter exactly 6 digits for confirm PIN',
            style: PaymentsUi.body(color: PaymentsUi.onPrimary),
          ),
          backgroundColor: PaymentsUi.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    }
    if (_newPinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'New PIN and Confirm PIN do not match',
            style: PaymentsUi.body(color: PaymentsUi.onPrimary),
          ),
          backgroundColor: PaymentsUi.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  /// Wave 2: Verify OTP and set new PIN.
  Future<void> _handleResetPin() async {
    if (!_validateStep2()) return;
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final ok = await _services.verifyOTP(
        _otpController.text.trim(),
        _newPinController.text,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'PIN reset successful!',
              style: PaymentsUi.body(color: PaymentsUi.onPrimary),
            ),
            backgroundColor: const Color(0xFF16A34A),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid OTP. Please try again or request a new OTP.',
              style: PaymentsUi.body(color: PaymentsUi.onPrimary),
            ),
            backgroundColor: PaymentsUi.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString()}',
            style: PaymentsUi.body(color: PaymentsUi.onPrimary),
          ),
          backgroundColor: PaymentsUi.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    FocusNode? nextFocusWhenFilled,
    int maxLength = 6,
    bool obscure = true,
  }) {
    final isActive = focusNode.hasFocus;
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        color: PaymentsUi.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          width: 1,
          color: isActive ? PaymentsUi.primary : PaymentsUi.border,
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(maxLength),
          ],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: PaymentsUi.font,
            fontSize: 20.sp,
            color: PaymentsUi.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          obscureText: obscure,
          obscuringCharacter: '•',
          onChanged: (value) {
            if (value.length != maxLength) return;
            if (nextFocusWhenFilled != null) {
              FocusScope.of(context).requestFocus(nextFocusWhenFilled);
            } else {
              FocusScope.of(context).unfocus();
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: PaymentsUi.font,
              fontSize: 14.sp,
              color: PaymentsUi.textMuted,
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaymentsUi.bg,
      appBar: PaymentsUi.backOnlyAppBar(context),
      body: PaymentsUi.centeredContent(
        context: context,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            bottom: MediaQuery.paddingOf(context).bottom + 24.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 8.h),
              Text('RESET PIN', style: PaymentsUi.displayTitle()),
              SizedBox(height: 16.h),
              if (_step == 1) ...[
                Text(
                  "We'll send an OTP to your registered email. Tap below to receive it.",
                  textAlign: TextAlign.center,
                  style: PaymentsUi.body(),
                ),
                SizedBox(height: 36.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _sendOTP,
                    style: PaymentsUi.primaryButtonStyle(),
                    child: _isLoading
                        ? SizedBox(
                            height: 22.h,
                            width: 22.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: PaymentsUi.onPrimary,
                            ),
                          )
                        : const Text('SEND OTP'),
                  ),
                ),
              ] else ...[
                Text(
                  'Enter the OTP you received and your new 6-digit PIN.',
                  textAlign: TextAlign.center,
                  style: PaymentsUi.body(),
                ),
                SizedBox(height: 20.h),
                _buildInputBox(
                  controller: _otpController,
                  focusNode: _otpFocus,
                  hint: 'OTP',
                  nextFocusWhenFilled: _newPinFocus,
                  obscure: false,
                ),
                SizedBox(height: 12.h),
                _buildInputBox(
                  controller: _newPinController,
                  focusNode: _newPinFocus,
                  hint: 'New PIN',
                  nextFocusWhenFilled: _confirmPinFocus,
                ),
                SizedBox(height: 12.h),
                _buildInputBox(
                  controller: _confirmPinController,
                  focusNode: _confirmPinFocus,
                  hint: 'Confirm PIN',
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: _isLoading ? null : _resendOTP,
                  child: Text(
                    'Resend OTP',
                    style: PaymentsUi.body(
                      color: PaymentsUi.primary,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _handleResetPin,
                    style: PaymentsUi.primaryButtonStyle(),
                    child: _isLoading
                        ? SizedBox(
                            height: 22.h,
                            width: 22.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: PaymentsUi.onPrimary,
                            ),
                          )
                        : const Text('RESET PIN'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
