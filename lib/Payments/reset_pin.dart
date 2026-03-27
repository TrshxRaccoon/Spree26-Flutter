import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  bool _resendCooldown = false;

  late FocusNode _otpFocus;
  late FocusNode _newPinFocus;
  late FocusNode _confirmPinFocus;
  TextEditingController? _activeController;

  @override
  void initState() {
    super.initState();
    _otpFocus = FocusNode();
    _newPinFocus = FocusNode();
    _confirmPinFocus = FocusNode();
    _activeController = _otpController;

    _otpFocus.addListener(() {
      if (_otpFocus.hasFocus)
        setState(() => _activeController = _otpController);
    });
    _newPinFocus.addListener(() {
      if (_newPinFocus.hasFocus)
        setState(() => _activeController = _newPinController);
    });
    _confirmPinFocus.addListener(() {
      if (_confirmPinFocus.hasFocus)
        setState(() => _activeController = _confirmPinController);
    });
  }

  @override
  void dispose() {
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
      // await _services.requestOTP();
      await Future.delayed(
        const Duration(seconds: 2),
      ); // Simulate network delay
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _step = 2;
        _resendCooldown = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent to your registered email'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      // Cooldown for resend (e.g. 60s)
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) setState(() => _resendCooldown = false);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send OTP: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Resend OTP (same endpoint as send).
  Future<void> _resendOTP() async {
    if (_isLoading || _resendCooldown) return;
    await _sendOTP();
  }

  bool _validateStep2() {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the OTP'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP must be 6 digits'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    if (_newPinController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter exactly 6 digits for new PIN'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    if (_confirmPinController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter exactly 6 digits for confirm PIN'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    if (_newPinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New PIN and Confirm PIN do not match'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
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
      // final ok = await _services.verifyOTP(
      //   _otpController.text.trim(),
      //   _newPinController.text,
      // );
      await Future.delayed(
        const Duration(seconds: 2),
      ); // Simulate network delay
      final ok = true; // Simulate success response
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN reset successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid OTP. Please try again or request a new OTP.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onKeyPressed(String key) {
    if (_activeController == null) return;
    setState(() {
      if (key == '<') {
        if (_activeController!.text.isNotEmpty) {
          _activeController!.text = _activeController!.text.substring(
            0,
            _activeController!.text.length - 1,
          );
        }
      } else {
        if (_activeController!.text.length < 6) {
          _activeController!.text += key;
        }
        // Mirroring your original logic to advance focus
        if (_activeController!.text.length == 6) {
          if (_activeController == _otpController) {
            FocusScope.of(context).requestFocus(_newPinFocus);
          } else if (_activeController == _newPinController) {
            FocusScope.of(context).requestFocus(_confirmPinFocus);
          } else {
            FocusScope.of(context).unfocus();
          }
        }
      }
    });
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    int maxLength = 6,
  }) {
    bool isActive = focusNode.hasFocus;
    return Container(
      width: 343.w,
      height: 60.h, // Slightly reduced to fit all elements
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark Mode surface
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          width: 1.w,
          color: isActive ? const Color(0xFF2563EB) : const Color(0xFF334155),
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          readOnly: true, // Prevents native keyboard
          showCursor: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(maxLength),
          ],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.r,
            color: const Color(0xFFF1F5F9), // Digits color requested
            fontFamily: 'Albert',
          ),
          obscureText: true,
          obscuringCharacter: '*',
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 18.r,
              color: const Color(0xFF94A3B8),
              fontFamily: 'Albert',
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildKeyPad() {
    return Column(
      children: [
        _buildKeyPadRow(['1', '2', '3']),
        SizedBox(height: 12.h),
        _buildKeyPadRow(['4', '5', '6']),
        SizedBox(height: 12.h),
        _buildKeyPadRow(['7', '8', '9']),
        SizedBox(height: 12.h),
        _buildKeyPadRow(['', '0', '<']),
      ],
    );
  }

  Widget _buildKeyPadRow(List<String> keys) {
    return SizedBox(
      width: 342.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: keys.map((key) => _buildKey(key)).toList(),
      ),
    );
  }

  Widget _buildKey(String key) {
    if (key.isEmpty) {
      return SizedBox(width: 103.33.w, height: 64.h);
    }
    return GestureDetector(
      onTap: () => _onKeyPressed(key),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 103.33.w, // Dimension requested
        height: 64.h, // Dimension requested
        alignment: Alignment.center,
        child: key == '<'
            ? Icon(
                Icons.backspace_outlined,
                color: const Color(0xFFF1F5F9),
                size: 28.r,
              )
            : Text(
                key,
                style: TextStyle(
                  fontSize: 32.sp,
                  color: const Color(0xFFF1F5F9), // White color requested
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF111111), // Dark mode background
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0.0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, size: 24.r, color: Colors.white),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 375.w,
                  height: 54.h,
                  child: Center(
                    child: Text(
                      'RESET PIN',
                      style: TextStyle(
                        fontSize: 36.sp,
                        color: Colors.white,
                        fontFamily: 'Orbitron_Bold',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                if (_step == 1) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      "We'll send an OTP to your registered email. Tap below to receive it.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF94A3B8), // Slate 400
                        fontFamily: 'Albert',
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 48.h),
                  GestureDetector(
                    onTap: _isLoading ? null : _sendOTP,
                    child: Container(
                      height: 56.h, // Requested dimension
                      width: 342.w, // Requested dimension
                      decoration: BoxDecoration(
                        color: _isLoading
                            ? const Color(0xFF334155)
                            : const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: _isLoading
                            ? SizedBox(
                                height: 24.h,
                                width: 24.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'SEND OTP',
                                style: TextStyle(
                                  fontFamily: 'Orbitron_Bold',
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                ),
                              ),
                      ),
                    ),
                  ),
                ] else ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      'Enter the OTP you received and your new 6-digit PIN.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF94A3B8), // Slate 400
                        fontFamily: 'Albert',
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildInputBox(
                    controller: _otpController,
                    focusNode: _otpFocus,
                    hint: 'ENTER OTP',
                  ),
                  SizedBox(height: 10.h),
                  _buildInputBox(
                    controller: _newPinController,
                    focusNode: _newPinFocus,
                    hint: 'NEW PIN',
                  ),
                  SizedBox(height: 10.h),
                  _buildInputBox(
                    controller: _confirmPinController,
                    focusNode: _confirmPinFocus,
                    hint: 'CONFIRM PIN',
                  ),
                  // Wrap in a fixed-height SizedBox to prevent layout jumping
                  SizedBox(
                    height: 48.h,
                    child: Center(
                      child: _resendCooldown
                          ? Text(
                              'Resend OTP available in 60s',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white54,
                              ),
                            )
                          : TextButton(
                              onPressed: _isLoading ? null : _resendOTP,
                              style: TextButton.styleFrom(
                                // Strip out excess default padding to keep it tight
                                minimumSize: Size.zero,
                                padding: EdgeInsets.symmetric(
                                  vertical: 8.h,
                                  horizontal: 16.w,
                                ),
                              ),
                              child: Text(
                                'Resend OTP',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF2563EB),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildKeyPad(),
                  SizedBox(height: 24.h),
                  GestureDetector(
                    onTap: _isLoading ? null : _handleResetPin,
                    child: Container(
                      height: 56.h, // Requested container dimension
                      width: 342.w, // Requested container dimension
                      decoration: BoxDecoration(
                        color: _isLoading
                            ? const Color(0xFF334155)
                            : const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: _isLoading
                            ? SizedBox(
                                height: 24.h,
                                width: 24.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'RESET PIN',
                                style: TextStyle(
                                  fontFamily: 'Orbitron_Bold',
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
