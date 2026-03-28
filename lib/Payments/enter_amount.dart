import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spree/Payments/enter_pin.dart';
import 'package:spree/Payments/payments_ui.dart';
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
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: PaymentsUi.body(color: PaymentsUi.onPrimary),
        ),
        backgroundColor: PaymentsUi.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaymentsUi.bg,
      appBar: PaymentsUi.appBar(context, 'Enter amount'),
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
              Text('Paying to', style: PaymentsUi.labelOverField()),
              SizedBox(height: 6.h),
              Text(
                widget.vendor,
                style: TextStyle(
                  fontFamily: PaymentsUi.font,
                  color: PaymentsUi.textPrimary,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 28.h),
              TextField(
                controller: _amountController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: PaymentsUi.font,
                  color: PaymentsUi.textPrimary,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w600,
                ),
                decoration: PaymentsUi.inputDecoration(hint: 'Amount (₹)'),
              ),
              SizedBox(height: 24.h),
              FilledButton(
                onPressed: _submit,
                style: PaymentsUi.primaryButtonStyle(),
                child: const Text('Continue'),
              ),
              SizedBox(height: 12.h),
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
                  style: PaymentsUi.body(
                    color: PaymentsUi.textSecondary,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
