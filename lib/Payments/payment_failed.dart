import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 50.h),
              Image.asset(
                'assets/payments/failed.png',
                width: 120.w,
                height: 120.h,
              ),
              SizedBox(height: 10.h),
              Text(
                'Payment Failed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 30.h,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                widget.failureDetail ??
                    'Something went wrong. Please try again\nor check your balance to ensure sufficient\nfunds.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.h,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 50.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF0B1220), // dark blue-ish like your image
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      _buildRow("Amount", "₹${widget.amount}"),
                      Divider(color: Colors.white.withOpacity(0.08)),
                      _buildRow(
                        "Date",
                        "${widget.date}",
                      ),
                      Divider(color: Colors.white.withOpacity(0.08)),
                      _buildRow(
                        "Time",
                        "${widget.time}",
                      ),
                      Divider(color: Colors.white.withOpacity(0.08)),
                      _buildRow("Vendor", widget.vendorName),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50.h),
              GestureDetector(
                onTap: () {
                  if (widget.onRetry != null) {
                    widget.onRetry!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  height: 56.h,
                  width: 308.w,
                  decoration: BoxDecoration(
                    color: Color(0xFF1F283B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 20.h, color: Colors.white),
                        SizedBox(width: 10.w),
                        Text(
                          'Retry Payment',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.h,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () {
                  if (widget.onBackToHome != null) {
                    widget.onBackToHome!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  height: 56.h,
                  width: 308.w,
                  decoration: BoxDecoration(
                    color: Color(0xFF1E82BE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Back to Home',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16.h,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.h,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16.h,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
