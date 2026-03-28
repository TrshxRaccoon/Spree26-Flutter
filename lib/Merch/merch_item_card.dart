import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spree/Payments/payments_ui.dart';
import 'package:spree/models/merch_order.dart';

class MerchItemCard extends StatelessWidget {
  final MerchItem item;

  const MerchItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: PaymentsUi.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border(
          left: BorderSide(
            color: item.distributed
                ? const Color(0xFF22C55E)
                : Colors.transparent,
            width: 3,
          ),
          top: BorderSide(color: PaymentsUi.borderMuted),
          right: BorderSide(color: PaymentsUi.borderMuted),
          bottom: BorderSide(color: PaymentsUi.borderMuted),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName,
                  style: TextStyle(
                    fontFamily: PaymentsUi.font,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: PaymentsUi.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      item.distributed
                          ? Icons.check_circle_rounded
                          : Icons.schedule_rounded,
                      size: 13.sp,
                      color: item.distributed
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFF59E0B),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      item.distributed ? 'Collected' : 'Pending',
                      style: TextStyle(
                        fontFamily: PaymentsUi.font,
                        fontSize: 12.sp,
                        color: item.distributed
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (item.size != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: PaymentsUi.border,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                item.size!,
                style: TextStyle(
                  fontFamily: PaymentsUi.font,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: PaymentsUi.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
