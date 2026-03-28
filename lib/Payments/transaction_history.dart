import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:spree/Payments/payments_ui.dart';
import 'package:spree/Payments/transaction_card.dart';
import 'package:spree/Services/payments.dart';
import 'package:spree/models/transactions.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = Services().transactions();
  }

  Future<void> _reload() async {
    setState(() {
      _future = Services().transactions();
    });
    try {
      await _future;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: PaymentsUi.bg,
        appBar: PaymentsUi.appBar(context, 'Transaction history'),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: PaymentsUi.primary),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Could not load transactions.',
                        textAlign: TextAlign.center,
                        style: PaymentsUi.body(),
                      ),
                      SizedBox(height: 16.h),
                      FilledButton(
                        onPressed: _reload,
                        style: PaymentsUi.primaryButtonStyle(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data!;
            final balance = data['balance'];
            final transactions =
                data['transactions'] as List<Transaction>? ?? <Transaction>[];

            final balanceLabel = balance is num
                ? '₹${balance.toString()}'
                : '₹${balance ?? '0'}';

            return RefreshIndicator(
              color: PaymentsUi.primary,
              onRefresh: _reload,
              child: PaymentsUi.centeredContent(
                context: context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8.h),
                    Text(
                      'AVAILABLE BALANCE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: PaymentsUi.font,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                        color: PaymentsUi.textMuted,
                        letterSpacing: 0.6,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      balanceLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: PaymentsUi.font,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: PaymentsUi.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: transactions.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(height: 80.h),
                                Center(
                                  child: Text(
                                    'No transactions yet.',
                                    style: PaymentsUi.body(),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final tx = transactions[index];
                                final d = tx.timestamp;
                                final dateStr = DateFormat('d MMM').format(d);
                                final timeStr = DateFormat('hh:mm a').format(d);
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  child: TransactionCard(
                                    vendorName: tx.vendor,
                                    date: dateStr,
                                    time: timeStr,
                                    amount: tx.amount.toString(),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
