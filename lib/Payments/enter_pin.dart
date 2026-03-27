import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spree/Payments/payment_confirmation.dart';

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

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_pinController.text.length != 6) {
      final bottom = MediaQuery.of(context).viewInsets.bottom;
      final snackBottom = bottom > 0 ? bottom - 10.h : 20.h;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please enter exactly 6 digits',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: snackBottom, left: 20.w, right: 20.w),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    Navigator.push<void>(
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Enter PIN', style: TextStyle(fontSize: 18.sp)),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 32.h),
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
                color: Colors.white,
                fontSize: 24.sp,
                letterSpacing: 8,
              ),
              onChanged: (value) {
                if (_pinController.text.length == 6) {
                  FocusScope.of(context).unfocus();
                }
              },
              decoration: InputDecoration(
                hintText: '6-digit PIN',
                hintStyle: TextStyle(color: Colors.white38, letterSpacing: 0),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFF2563EB)),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                backgroundColor: const Color(0xFF2563EB),
              ),
              child: Text('Pay', style: TextStyle(fontSize: 16.sp)),
            ),
          ],
        ),
      ),
    );
  }
}
