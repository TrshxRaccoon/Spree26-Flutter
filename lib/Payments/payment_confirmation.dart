import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:spree/Payments/payment_failed.dart';
import 'package:spree/Payments/payment_success.dart';
import 'package:spree/Payments/payments_ui.dart';
import 'package:spree/Services/payments.dart';

/// Single route: loading → [PaymentSuccess] or [PaymentFailed] (same page / no extra pushes).
class PaymentConfirmation extends StatefulWidget {
  final String amount;
  final String vendor;
  final String qrData;
  final String pin;

  const PaymentConfirmation({
    super.key,
    required this.amount,
    required this.vendor,
    required this.qrData,
    required this.pin,
  });

  @override
  State<PaymentConfirmation> createState() => _PaymentConfirmationState();
}

class _PaymentConfirmationState extends State<PaymentConfirmation> {
  bool _loading = true;
  String? _successDate;
  String? _successTime;
  String? _failureDetail;
  String? _failureDate;
  String? _failureTime;

  @override
  void initState() {
    super.initState();
    _pay();
  }

  Future<void> _pay() async {
    try {
      final body = await Services().makePayment(
        widget.qrData,
        int.parse(widget.amount),
        widget.pin,
      );

      if (!mounted) return;

      String timeStr;
      String dateStr;
      try {
        final map = jsonDecode(body) as Map<String, dynamic>;
        final ts = map['timestamp'] ?? map['createdAt'];
        if (ts != null) {
          final dt = DateTime.parse(ts.toString()).toLocal();
          timeStr = DateFormat('hh:mm a').format(dt);
          dateStr = DateFormat('d MMM').format(dt);
        } else {
          final now = DateTime.now();
          timeStr = DateFormat('hh:mm a').format(now);
          dateStr = DateFormat('d MMM').format(now);
        }
      } catch (_) {
        final now = DateTime.now();
        timeStr = DateFormat('hh:mm a').format(now);
        dateStr = DateFormat('d MMM').format(now);
      }

      setState(() {
        _loading = false;
        _successDate = dateStr;
        _successTime = timeStr;
        _failureDetail = null;
        _failureDate = null;
        _failureTime = null;
      });
    } catch (e) {
      if (!mounted) return;
      final message = e.toString();
      String display;
      if (message.contains('Invalid PIN') || message.contains('403')) {
        display = 'Invalid PIN. Please try again.';
      } else if (message.toLowerCase().contains('network')) {
        display = 'Kindly check your network connection.';
      } else {
        display = 'An error occurred during payment. Please try again.';
      }

      final now = DateTime.now();
      setState(() {
        _loading = false;
        _failureDetail = display;
        _failureDate = DateFormat('d MMM').format(now);
        _failureTime = DateFormat('hh:mm a').format(now);
        _successDate = null;
        _successTime = null;
      });
    }
  }

  void _backToHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final allowSystemBack =
        !_loading && _failureDetail != null;

    Widget child;
    if (_loading) {
      child = Scaffold(
        backgroundColor: PaymentsUi.bg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: PaymentsUi.primary),
              SizedBox(height: 24.h),
              Text(
                'Processing payment…',
                style: PaymentsUi.body(color: PaymentsUi.textSecondary),
              ),
            ],
          ),
        ),
      );
    } else if (_successDate != null && _successTime != null) {
      child = PaymentSuccess(
        amount: widget.amount,
        vendorName: widget.vendor,
        date: _successDate!,
        time: _successTime!,
        onBackToHome: _backToHome,
      );
    } else if (_failureDate != null &&
        _failureTime != null &&
        _failureDetail != null) {
      child = PaymentFailed(
        amount: widget.amount,
        vendorName: widget.vendor,
        date: _failureDate!,
        time: _failureTime!,
        failureDetail: _failureDetail,
        onRetry: () => Navigator.of(context).pop(),
        onBackToHome: _backToHome,
      );
    } else {
      child = const SizedBox.shrink();
    }

    return PopScope(
      canPop: allowSystemBack,
      child: child,
    );
  }
}
