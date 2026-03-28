import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spree/Payments/payments_gate.dart';
import 'package:spree/Payments/payments_ui.dart';
import 'package:spree/Payments/reset_pin.dart';
import 'package:spree/Payments/transaction_history.dart';
import 'package:spree/Services/payments.dart';

class PaymentsHome extends StatefulWidget {
  const PaymentsHome({super.key});

  @override
  State<PaymentsHome> createState() => _PaymentsHomeState();
}

class _PaymentsHomeState extends State<PaymentsHome> {
  late Future<Map<String, dynamic>> _walletFuture;

  @override
  void initState() {
    super.initState();
    _walletFuture = Services().transactions();
  }

  Future<void> _reloadWallet() async {
    setState(() {
      _walletFuture = Services().transactions();
    });
    try {
      await _walletFuture;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: PaymentsUi.bg,
        body: RefreshIndicator(
          color: PaymentsUi.primary,
          onRefresh: _reloadWallet,
          child: FutureBuilder<Map<String, dynamic>>(
            future: _walletFuture,
            builder: (context, snapshot) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: PaymentsUi.horizontalPagePadding(context)
                            .add(EdgeInsets.only(top: 8.h, bottom: 24.h)),
                        child: PaymentsUi.centeredContent(
                          context: context,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Payments',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: PaymentsUi.font,
                                  fontSize: 26.sp,
                                  color: PaymentsUi.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'Wallet & scan to pay',
                                textAlign: TextAlign.center,
                                style: PaymentsUi.bodySmall(),
                              ),
                              if (snapshot.hasError) ...[
                                SizedBox(height: 12.h),
                                Text(
                                  'Could not load balance. Pull to refresh.',
                                  style: PaymentsUi.bodySmall(
                                    color: PaymentsUi.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              SizedBox(height: 24.h),
                              GestureDetector(
                                onTap: () async {
                                  await Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          const PaymentsGate(),
                                    ),
                                  );
                                  if (context.mounted) _reloadWallet();
                                },
                                child: Container(
                                  height: 160.h,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    gradient: PaymentsUi.scanCardGradient,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.qr_code_scanner,
                                        size: 36.sp,
                                        color: PaymentsUi.onPrimary,
                                      ),
                                      SizedBox(height: 10.h),
                                      Text(
                                        'Scan QR Code',
                                        style: TextStyle(
                                          fontFamily: PaymentsUi.font,
                                          fontSize: 18.sp,
                                          color: PaymentsUi.onPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'Pay vendors & food stalls',
                                        style: TextStyle(
                                          fontFamily: PaymentsUi.font,
                                          fontSize: 12.sp,
                                          color: PaymentsUi.onPrimary
                                              .withValues(alpha: 0.85),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              TextButton(
                                onPressed: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (context) => const ResetPin(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Reset PIN',
                                  style: PaymentsUi.body(
                                    color: PaymentsUi.primary,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          const TransactionHistory(),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 80.h,
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                  ),
                                  decoration: PaymentsUi.cardDecoration(),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.history_outlined,
                                        color: PaymentsUi.primary,
                                        size: 28.sp,
                                      ),
                                      SizedBox(width: 14.w),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Transaction History',
                                              style: TextStyle(
                                                fontFamily: PaymentsUi.font,
                                                fontSize: 15.sp,
                                                color: PaymentsUi.textPrimary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              'View all past spends',
                                              style: PaymentsUi.bodySmall(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: PaymentsUi.textMuted,
                                        size: 22.sp,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
