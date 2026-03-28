import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spree/Payments/payments_ui.dart';

class PaymentFailed extends StatefulWidget {
  final String amount;
  final String vendorName;
  final String date;
  final String time;

  /// Replaces the default grey explanation when non-null.
  final String? failureDetail;

  final VoidCallback? onRetry;
  final VoidCallback? onBackToHome;

  const PaymentFailed({
    super.key,
    required this.amount,
    required this.vendorName,
    required this.date,
    required this.time,
    this.failureDetail,
    this.onRetry,
    this.onBackToHome,
  });

  @override
  State<PaymentFailed> createState() => _PaymentFailedState();
}

class _PaymentFailedState extends State<PaymentFailed> {
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
                      SizedBox(height: 12.h),
                      Image.asset(
                        'assets/payments/failed.png',
                        width: 100.w,
                        height: 100.h,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Payment failed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: PaymentsUi.font,
                          fontSize: 22.sp,
                          color: PaymentsUi.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        widget.failureDetail ??
                            'Something went wrong. Please try again or check your balance.',
                        textAlign: TextAlign.center,
                        style: PaymentsUi.body(),
                      ),
                      SizedBox(height: 24.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        decoration: PaymentsUi.cardDecoration(),
                        child: Column(
                          children: [
                            _buildRow('Amount', '₹${widget.amount}'),
                            Divider(
                              height: 20.h,
                              color: PaymentsUi.textPrimary
                                  .withValues(alpha: 0.08),
                            ),
                            _buildRow('Date', widget.date),
                            Divider(
                              height: 20.h,
                              color: PaymentsUi.textPrimary
                                  .withValues(alpha: 0.08),
                            ),
                            _buildRow('Time', widget.time),
                            Divider(
                              height: 20.h,
                              color: PaymentsUi.textPrimary
                                  .withValues(alpha: 0.08),
                            ),
                            _buildRow('Vendor', widget.vendorName),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            if (widget.onRetry != null) {
                              widget.onRetry!();
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: PaymentsUi.surfaceElevated,
                            foregroundColor: PaymentsUi.textPrimary,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: const BorderSide(color: PaymentsUi.border),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh, size: 20.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'Retry payment',
                                style: TextStyle(
                                  fontFamily: PaymentsUi.font,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: PaymentsUi.bodySmall(),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontFamily: PaymentsUi.font,
              fontSize: 14.sp,
              color: PaymentsUi.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
