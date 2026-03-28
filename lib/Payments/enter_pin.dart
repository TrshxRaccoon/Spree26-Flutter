import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spree/Payments/payment_confirmation.dart';
import 'package:spree/Payments/payments_ui.dart';

class EnterPin extends StatefulWidget {
  final String amount;
  final String qrData;
  final String vendor;

  const EnterPin({
    super.key,
    required this.amount,
    required this.qrData,
    required this.vendor,
  });

  @override
  State<EnterPin> createState() => _EnterPinState();
}

class _EnterPinState extends State<EnterPin> {
  final TextEditingController _pinController = TextEditingController();
  bool _swdConsent = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final snackBottom = bottom > 0 ? bottom - 10.h : 20.h;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: PaymentsUi.body(color: PaymentsUi.onPrimary),
        ),
        backgroundColor: PaymentsUi.error,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: snackBottom, left: 20.w, right: 20.w),
      ),
    );
  }

  void _submit() {
    if (_pinController.text.length != 6) {
      _snack('Please enter exactly 6 digits');
      return;
    }

    if (!_swdConsent) {
      _snack('Please confirm SWD dues consent to continue.');
      return;
    }

    FocusScope.of(context).unfocus();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder<void>(
        pageBuilder: (context, animation1, animation2) => PaymentConfirmation(
          amount: widget.amount,
          vendor: widget.vendor,
          qrData: widget.qrData,
          pin: _pinController.text,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaymentsUi.bg,
      appBar: PaymentsUi.appBar(context, 'Enter PIN'),
      body: PaymentsUi.centeredContent(
        context: context,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 8.h,
            bottom: MediaQuery.paddingOf(context).bottom + 24.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _pinController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                keyboardType: TextInputType.number,
                obscureText: true,
                obscuringCharacter: '•',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: PaymentsUi.font,
                  color: PaymentsUi.textPrimary,
                  fontSize: 22.sp,
                  letterSpacing: 6,
                ),
                onChanged: (value) {
                  if (_pinController.text.length == 6) {
                    FocusScope.of(context).unfocus();
                  }
                },
                decoration: PaymentsUi.inputDecoration(hint: '6-digit PIN'),
              ),
              SizedBox(height: 20.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24.h,
                    width: 24.w,
                    child: Checkbox(
                      value: _swdConsent,
                      onChanged: (v) {
                        setState(() => _swdConsent = v ?? false);
                      },
                      activeColor: PaymentsUi.primary,
                      checkColor: PaymentsUi.onPrimary,
                      side: const BorderSide(color: PaymentsUi.border),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _swdConsent = !_swdConsent),
                      child: Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Text(
                          'I consent for the amount to be deducted from my SWD Dues',
                          style: PaymentsUi.body(
                            height: 1.35,
                            color: PaymentsUi.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              FilledButton(
                onPressed: _submit,
                style: PaymentsUi.primaryButtonStyle(),
                child: const Text('Pay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
