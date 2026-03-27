import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spree/Payments/qr_scanner.dart';
import 'package:spree/Payments/set_pin.dart';
import 'package:spree/Services/payments.dart';

/// Entry for pay-by-QR: loads [Services.checkPin]; QR scanner if PIN exists, else [SetPin].
class PaymentsGate extends StatefulWidget {
  const PaymentsGate({super.key});

  @override
  State<PaymentsGate> createState() => _PaymentsGateState();
}

class _PaymentsGateState extends State<PaymentsGate> {
  Future<bool>? _checkPinFuture;

  @override
  void initState() {
    super.initState();
    _checkPinFuture = Services().checkPin();
  }

  void _retryCheckPin() {
    setState(() => _checkPinFuture = Services().checkPin());
  }

  void _onPinSetSuccess() {
    setState(() => _checkPinFuture = Services().checkPin());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<bool>(
        future: _checkPinFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                width: 40.w,
                height: 40.w,
                child: const CircularProgressIndicator(color: Colors.white),
              ),
            );
          }
          if (snapshot.hasError) {
            return _buildErrorState();
          }
          if (snapshot.hasData && snapshot.data == true) {
            return const QrScannerScreen();
          }
          return SetPin(onPinSetSuccess: _onPinSetSuccess);
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            SizedBox(height: 20.h),
            Text(
              'Session expired. Please logout and try again with your institute account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14.sp),
            ),
            SizedBox(height: 24.h),
            FilledButton(
              onPressed: _retryCheckPin,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
