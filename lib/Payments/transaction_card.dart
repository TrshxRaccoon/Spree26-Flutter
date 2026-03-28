import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spree/Payments/payments_ui.dart';

class TransactionCard extends StatelessWidget {
  final String time;
  final String date;
  final String amount;
  final String vendorName;

  const TransactionCard({
    super.key,
    required this.time,
    required this.date,
    required this.amount,
    required this.vendorName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: PaymentsUi.cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  vendorName,
                  style: TextStyle(
                    fontFamily: PaymentsUi.font,
                    fontSize: 15.sp,
                    color: PaymentsUi.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$date · $time',
                  style: PaymentsUi.bodySmall(),
                ),
              ],
            ),
          ),
          Text(
            '₹$amount',
            style: TextStyle(
              fontFamily: PaymentsUi.font,
              fontSize: 15.sp,
              color: PaymentsUi.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
