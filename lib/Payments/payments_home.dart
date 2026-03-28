import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spree/Payments/payments_gate.dart';
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
    setState(() => _walletFuture = Services().transactions());
    try {
      await _walletFuture;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: RefreshIndicator(
          color: const Color(0xFF2563EB),
          onRefresh: _reloadWallet,
          child: FutureBuilder<Map<String, dynamic>>(
            future: _walletFuture,
            builder: (context, snapshot) {
              final balanceText = _balanceLabel(snapshot);

              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 175.h,
                              width: 324.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF642878), Colors.black],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 24.h,
                                  horizontal: 24.w,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Current Fest Balance',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 14.h,
                                                color: const Color.fromARGB(
                                                  255,
                                                  130,
                                                  128,
                                                  128,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              balanceText,
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 30.h,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.account_balance_wallet_outlined,
                                          size: 60.h,
                                          color: const Color.fromARGB(
                                            255,
                                            97,
                                            96,
                                            96,
                                          ).withOpacity(0.5),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Top-up is not available in the app yet.',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 40.h,
                                        width: 292.w,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E828E),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_circle_outline,
                                                size: 15.h,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 10.w),
                                              Text(
                                                'Add Money',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 14.h,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (snapshot.hasError)
                              Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: Text(
                                  'Could not load balance. Pull to refresh.',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12.sp,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            SizedBox(height: 24.h),
                            GestureDetector(
                              onTap: () async {
                                await Navigator.push<void>(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (context) => const PaymentsGate(),
                                  ),
                                );
                                if (context.mounted) _reloadWallet();
                              },
                              child: Container(
                                height: 175.h,
                                width: 324.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF781E),
                                      Color(0xFFA01414),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.qr_code_scanner,
                                      size: 40.h,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      'Scan QR Code',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 20.h,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Pay vendors & food stalls',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 10.h,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
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
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14.sp,
                                  color: const Color(0xFF94A3B8),
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
                                height: 84.h,
                                width: 324.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: const Color(0xFF1E1E1E),
                                  border: Border.all(
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.history_outlined,
                                      color: const Color.fromARGB(
                                        255,
                                        70,
                                        114,
                                        93,
                                      ),
                                      size: 30.h,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Transaction History',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 16.h,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'View all past spends',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12.h,
                                            color: const Color.fromARGB(
                                              255,
                                              103,
                                              103,
                                              103,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: const Color.fromARGB(
                                        255,
                                        94,
                                        94,
                                        94,
                                      ),
                                      size: 20.h,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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

  String _balanceLabel(AsyncSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return '…';
    }
    if (snapshot.hasError || !snapshot.hasData) {
      return '—';
    }
    final balance = snapshot.data!['balance'];
    if (balance is num) {
      return '₹${balance.toString()}';
    }
    if (balance != null) {
      return '₹$balance';
    }
    return '₹0';
  }
}
