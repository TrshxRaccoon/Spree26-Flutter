import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spree/Merch/merch_item_card.dart';
import 'package:spree/Payments/payments_ui.dart';
import 'package:spree/Services/merch.dart';
import 'package:spree/models/merch_order.dart';

class MerchHome extends StatefulWidget {
  const MerchHome({super.key});

  @override
  State<MerchHome> createState() => _MerchHomeState();
}

class _MerchHomeState extends State<MerchHome> {
  final MerchService _service = MerchService();
  MerchOrder? _order;
  bool _isLoading = true;
  bool _isBooking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final order = await _service.getOrder();
      if (mounted) setState(() => _order = order);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _book() async {
    setState(() => _isBooking = true);
    try {
      await _service.book();
      await _fetchOrder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Booked for collection!',
              textAlign: TextAlign.center,
              style: PaymentsUi.body(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF22C55E),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: PaymentsUi.body(color: Colors.white),
            ),
            backgroundColor: PaymentsUi.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaymentsUi.bg,
      appBar: AppBar(
        backgroundColor: PaymentsUi.bg,
        foregroundColor: PaymentsUi.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'MERCH',
          style: TextStyle(
            fontFamily: 'Orbitron_Bold',
            fontSize: 17.sp,
            color: PaymentsUi.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: PaymentsUi.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: PaymentsUi.body(color: PaymentsUi.textSecondary),
              ),
              SizedBox(height: 20.h),
              FilledButton(
                onPressed: _fetchOrder,
                style: PaymentsUi.primaryButtonStyle(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_order == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            'No merch orders found for your account.',
            textAlign: TextAlign.center,
            style: PaymentsUi.body(color: PaymentsUi.textSecondary),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrder,
      color: PaymentsUi.primary,
      backgroundColor: PaymentsUi.surface,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        children: [
          if (_order!.booked) _buildBookedBanner(),
          if (_order!.allDistributed) _buildAllCollectedBanner(),
          if (_order!.booked) SizedBox(height: 16.h),
          ..._order!.items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: MerchItemCard(item: item),
            ),
          ),
          if (!_order!.booked) ...[
            SizedBox(height: 24.h),
            _buildBookButton(),
          ],
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildBookedBanner() {
    if (_order!.allDistributed) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFF22C55E).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: const Color(0xFF22C55E), size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'All merch collected!',
                style: TextStyle(
                  fontFamily: PaymentsUi.font,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF22C55E),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: PaymentsUi.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: PaymentsUi.border),
      ),
      child: Row(
        children: [
          Icon(Icons.confirmation_number_outlined, color: PaymentsUi.primary, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're booked! Show your OTP at the distribution counter.",
                  style: PaymentsUi.body(color: PaymentsUi.textSecondary),
                ),
                if (_order!.otp != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    _order!.otp!,
                    style: TextStyle(
                      fontFamily: 'Orbitron_Bold',
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: PaymentsUi.textPrimary,
                      letterSpacing: 6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllCollectedBanner() {
    return const SizedBox.shrink();
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: FilledButton(
        onPressed: _isBooking ? null : _book,
        style: PaymentsUi.primaryButtonStyle(),
        child: _isBooking
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'BOOK FOR COLLECTION',
                style: TextStyle(
                  fontFamily: 'Orbitron_Bold',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
