import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        backgroundColor: Colors.black,
        body: Center(
          child: Container(
            height: 791.h,
            width: 358.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color(0xFF160D26),
            ),
            child: Column(
              children: [
                SizedBox(height: 33.h),
                Text(
                  'Payment Status',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18.h,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40.h),
                Image.asset(
                  'assets/payments/tick.png',
                  width: 120.w,
                  height: 120.h,
                ),
                Text(
                  'Payment\nSuccessful!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 30.h,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Your transaction has been completed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16.h,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  '₹${widget.amount}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 50.h,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Paid to ${widget.vendorName}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18.h,
                    color: Color(0xFF1E82BE),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30.h),
                Container(
                  height: 150.h,
                  width: 340.w,
                  padding: EdgeInsets.symmetric(
                    vertical: 20.h,
                    horizontal: 16.w,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF2A1E3F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Time: ${widget.time}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 24.h,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height:10.h),
                        Text(
                          'Date: ${widget.date}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 24.h,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 50.h),
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
      ),
    );
  }
}
