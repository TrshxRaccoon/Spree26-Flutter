import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spree/Payments/payments_ui.dart';
import 'package:spree/Services/payments.dart';

class SetPin extends StatefulWidget {
  /// When non-null (e.g. from [PaymentsGate]), called after a successful API set-pin instead of [Navigator.pop].
  final VoidCallback? onPinSetSuccess;

  const SetPin({super.key, this.onPinSetSuccess});

  @override
  State<SetPin> createState() => _SetPinState();
}

class _SetPinState extends State<SetPin> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isLoading = false;
  final Services _services = Services();

  late FocusNode _pinFocus;
  late FocusNode _confirmPinFocus;

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _pinFocus = FocusNode();
    _confirmPinFocus = FocusNode();
    _pinFocus.addListener(_onFocusChanged);
    _confirmPinFocus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _pinFocus.removeListener(_onFocusChanged);
    _confirmPinFocus.removeListener(_onFocusChanged);
    _pinController.dispose();
    _confirmPinController.dispose();
    _pinFocus.dispose();
    _confirmPinFocus.dispose();
    super.dispose();
  }

  bool _validateFields() {
    if (_pinController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter exactly 6 digits for PIN',
            textAlign: TextAlign.center,
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
            textAlign: TextAlign.center,
            style: PaymentsUi.body(color: PaymentsUi.onPrimary),
          ),
          backgroundColor: PaymentsUi.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    }
    if (_pinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PIN and Confirm PIN do not match',
            textAlign: TextAlign.center,
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

  Future<void> _handleSetPin() async {
    if (!_validateFields()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _services.setPin(_pinController.text);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'PIN set successfully!',
                textAlign: TextAlign.center,
                style: PaymentsUi.body(color: PaymentsUi.onPrimary),
              ),
              backgroundColor: const Color(0xFF16A34A),
              duration: const Duration(seconds: 2),
            ),
          );

          if (widget.onPinSetSuccess != null) {
            widget.onPinSetSuccess!();
          } else {
            Navigator.pop(context);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to set PIN. Please try again.',
                textAlign: TextAlign.center,
                style: PaymentsUi.body(color: PaymentsUi.onPrimary),
              ),
              backgroundColor: PaymentsUi.error,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              textAlign: TextAlign.center,
              style: PaymentsUi.body(color: PaymentsUi.onPrimary),
            ),
            backgroundColor: PaymentsUi.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    FocusNode? nextFocusWhenFilled,
    int maxLength = 6,
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
          obscureText: true,
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
              Text('SET PIN', style: PaymentsUi.displayTitle()),
              SizedBox(height: 8.h),
              Text(
                'Choose a 6-digit PIN for wallet payments.',
                textAlign: TextAlign.center,
                style: PaymentsUi.body(),
              ),
              SizedBox(height: 28.h),
              _buildInputBox(
                controller: _pinController,
                focusNode: _pinFocus,
                hint: 'New PIN',
                nextFocusWhenFilled: _confirmPinFocus,
              ),
              SizedBox(height: 12.h),
              _buildInputBox(
                controller: _confirmPinController,
                focusNode: _confirmPinFocus,
                hint: 'Confirm PIN',
              ),
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _handleSetPin,
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
                      : const Text('SET PIN'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
