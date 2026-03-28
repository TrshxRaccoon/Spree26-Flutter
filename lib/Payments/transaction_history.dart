import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text('Transaction history', style: TextStyle(fontSize: 18.sp)),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
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
                        style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                      ),
                      SizedBox(height: 16.h),
                      FilledButton(
                        onPressed: _reload,
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
              color: const Color(0xFF2563EB),
              onRefresh: _reload,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 8.h),
                  Text(
                    'AVAILABLE BALANCE',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 14.h,
                      color: const Color.fromARGB(255, 130, 128, 128),
                    ),
                  ),
                  Text(
                    balanceLabel,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 36.h,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: transactions.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 120.h),
                              Center(
                                child: Text(
                                  'No transactions yet.',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14.sp,
                                  ),
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
                                padding: EdgeInsets.symmetric(vertical: 10.h),
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
            );
          },
        ),
      ),
    );
  }
}
