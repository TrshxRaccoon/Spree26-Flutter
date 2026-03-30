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
  bool _isBlocking = false;

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

  Future<void> _onBlockAccountPressed() async {
    if (_isBlocking) return;
    final shouldBlock = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Block account?'),
          content: const Text(
            'Are you sure you want to block your payments account? This action may prevent further transactions.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: PaymentsUi.error),
              child: const Text('Block'),
            ),
          ],
        );
      },
    );

    if (shouldBlock != true || !mounted) return;

    setState(() => _isBlocking = true);
    try {
      await Services().blockaccount();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account blocked successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isBlocking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: PaymentsUi.bg,
        appBar: PaymentsUi.appBar(
          context,
          'Transaction history',
          actions: [
            TextButton.icon(
              onPressed: _isBlocking ? null : _onBlockAccountPressed,
              icon: _isBlocking
                  ? SizedBox(
                      width: 14.r,
                      height: 14.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: PaymentsUi.error,
                      ),
                    )
                  : Icon(
                      Icons.block,
                      color: PaymentsUi.error,
                      size: 18.r,
                    ),
              label: Text(
                'Block Account',
                style: TextStyle(
                  color: PaymentsUi.error,
                  fontFamily: PaymentsUi.font,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ),
            SizedBox(width: 6.w),
          ],
        ),
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
