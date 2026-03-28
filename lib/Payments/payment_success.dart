import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spree/Payments/payments_ui.dart';

class PaymentSuccess extends StatefulWidget {
  final String amount;
  final String vendorName;
  final String date;
  final String time;

  /// When set (e.g. from [PaymentConfirmation]), used instead of a single [Navigator.pop].
  final VoidCallback? onBackToHome;

  const PaymentSuccess({
    super.key,
    required this.amount,
    required this.vendorName,
    required this.date,
    required this.time,
    this.onBackToHome,
  });

  @override
  State<PaymentSuccess> createState() => _PaymentSuccessState();
}

class _PaymentSuccessState extends State<PaymentSuccess> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: PaymentsUi.bg,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: PaymentsUi.centeredContent(
                  context: context,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 24.h,
                          horizontal: 16.w,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: PaymentsUi.surface,
                          border: Border.all(color: PaymentsUi.borderMuted),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Payment successful',
                              style: TextStyle(
                                fontFamily: PaymentsUi.font,
                                fontSize: 18.sp,
                                color: PaymentsUi.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Image.asset(
                              'assets/payments/tick.png',
                              width: 100.w,
                              height: 100.h,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Your transaction is complete',
                              textAlign: TextAlign.center,
                              style: PaymentsUi.body(),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              '₹${widget.amount}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: PaymentsUi.font,
                                fontSize: 36.sp,
                                color: PaymentsUi.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'Paid to ${widget.vendorName}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: PaymentsUi.font,
                                fontSize: 15.sp,
                                color: PaymentsUi.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: 16.h,
                                horizontal: 12.w,
                              ),
                              decoration: BoxDecoration(
                                color: PaymentsUi.surfaceElevated,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Time · ${widget.time}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: PaymentsUi.font,
                                      fontSize: 15.sp,
                                      color: PaymentsUi.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Date · ${widget.date}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: PaymentsUi.font,
                                      fontSize: 15.sp,
                                      color: PaymentsUi.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24.h),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () {
                                  if (widget.onBackToHome != null) {
                                    widget.onBackToHome!();
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                },
                                style: PaymentsUi.primaryButtonStyle(),
                                child: const Text('Back to Home'),
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
          },
        ),
      ),
    );
  }
}
