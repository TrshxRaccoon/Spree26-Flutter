import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spree/Payments/enter_pin.dart';
import 'package:spree/Payments/reset_pin.dart';

class EnterAmount extends StatefulWidget {
  final String vendor;
  final String qrdata;

  const EnterAmount({
    super.key,
    required this.vendor,
    required this.qrdata,
  });

  @override
  State<EnterAmount> createState() => _EnterAmountState();
}

class _EnterAmountState extends State<EnterAmount> {
  final TextEditingController _amountController = TextEditingController();

  static const int _maxAmount = 3000;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final amountInIntegers = int.tryParse(_amountController.text);
    if (amountInIntegers == null) {
      _snack('Please enter a valid amount!');
      return;
    }
    if (amountInIntegers <= 0) {
      _snack('Please enter a valid amount!');
      return;
    }
    if (amountInIntegers > _maxAmount) {
      _snack('Amount exceeds maximum limit of ₹$_maxAmount');
      return;
    }

    Navigator.push<void>(
      context,
      PageRouteBuilder<void>(
        pageBuilder: (context, animation1, animation2) => EnterPin(
          amount: _amountController.text,
          vendor: widget.vendor,
          qrData: widget.qrdata,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
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
        title: Text('Enter amount', style: TextStyle(fontSize: 18.sp)),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 32.h),
            Text(
              'Paying to',
              style: TextStyle(color: Colors.white54, fontSize: 14.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              widget.vendor,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32.h),
            TextField(
              controller: _amountController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28.sp,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Amount (₹)',
                hintStyle: TextStyle(color: Colors.white38),
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
              child: Text('Continue', style: TextStyle(fontSize: 16.sp)),
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () {
                Navigator.push<void>(
                  context,
                  PageRouteBuilder<void>(
                    pageBuilder: (context, a1, a2) => const ResetPin(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: Text(
                'Reset PIN',
                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
