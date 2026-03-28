import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:spree/Payments/enter_amount.dart';
import 'package:spree/Payments/payments_ui.dart';
import 'package:spree/Services/payments.dart';

/// Camera QR scan → [Services.validateVendor] → [EnterAmount] on success.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with WidgetsBindingObserver {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool _isDisposed = false;
  bool _cameraPermissionDenied = false;
  bool _isProcessingScan = false;
  StreamSubscription<Barcode>? _scanSubscription;
  bool _permissionHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final status = await Permission.camera.status;

      if (status.isDenied) {
        final req = await Permission.camera.request();
        if (!req.isGranted && mounted) {
          setState(() => _cameraPermissionDenied = true);
        }
      } else if (status.isPermanentlyDenied && mounted) {
        setState(() => _cameraPermissionDenied = true);
        openAppSettings();
      }
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid && !_isDisposed) {
      _safePauseCamera();
    }
    if (!_isDisposed && !_cameraPermissionDenied) {
      _safeResumeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isDisposed = true;
    _isProcessingScan = false;
    _scanSubscription?.cancel();
    _scanSubscription = null;

    final c = controller;
    if (c != null) {
      unawaited(c.pauseCamera().catchError((_) {}));
    }
    super.dispose();
  }

  void _safePauseCamera() {
    final c = controller;
    if (c == null || _isDisposed) return;
    unawaited(c.pauseCamera().catchError((_) {}));
  }

  void _safeResumeCamera() {
    final c = controller;
    if (c == null || _isDisposed) return;
    unawaited(c.resumeCamera().catchError((_) {}));
  }

  void _onQRViewCreated(QRViewController ctrl) {
    if (_isDisposed) return;

    setState(() => controller = ctrl);
    _scanSubscription = ctrl.scannedDataStream.listen((scanData) async {
      if (_isProcessingScan) return;
      _isProcessingScan = true;
      _safePauseCamera();

      final qrCode = scanData.code;

      if (qrCode == null || qrCode.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid QR code. Please try again.',
              style: PaymentsUi.body(color: PaymentsUi.onPrimary),
            ),
            backgroundColor: PaymentsUi.error,
          ),
        );
        _isProcessingScan = false;
        _safeResumeCamera();
        return;
      }

      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              backgroundColor: PaymentsUi.surface,
              content: Row(
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: PaymentsUi.primary,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    'Validating vendor…',
                    style: PaymentsUi.body(color: PaymentsUi.textPrimary),
                  ),
                ],
              ),
            ),
          );
        },
      );

      try {
        final shopName = await Services().validateVendor(qrCode);
        if (!mounted) return;
        Navigator.of(context).pop();

        if (shopName != null) {
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
              builder: (context) =>
                  EnterAmount(vendor: shopName, qrdata: qrCode),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Vendor not found, please try again.',
                style: PaymentsUi.body(color: PaymentsUi.onPrimary),
              ),
              backgroundColor: PaymentsUi.error,
            ),
          );
          _isProcessingScan = false;
          _safeResumeCamera();
        }
      } catch (_) {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error processing request. Please try again.',
              style: PaymentsUi.body(color: PaymentsUi.onPrimary),
            ),
            backgroundColor: PaymentsUi.error,
          ),
        );
        _isProcessingScan = false;
        _safeResumeCamera();
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      if (_permissionHandled) return;
      _permissionHandled = true;
      if (mounted) setState(() => _cameraPermissionDenied = true);
    } else {
      if (mounted) {
        setState(() {
          _cameraPermissionDenied = false;
          _permissionHandled = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanSize = MediaQuery.sizeOf(context).shortestSide * 0.72;
    final box = scanSize.clamp(220.0, 340.0);

    return Scaffold(
      backgroundColor: PaymentsUi.bg,
      appBar: PaymentsUi.appBar(context, 'Scan QR'),
      body: PaymentsUi.centeredContent(
        context: context,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Point the camera at the vendor QR code',
                textAlign: TextAlign.center,
                style: PaymentsUi.body(color: PaymentsUi.textSecondary),
              ),
              SizedBox(height: 24.h),
              Container(
                height: box,
                width: box,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: PaymentsUi.primary, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: _cameraPermissionDenied
                      ? ColoredBox(
                          color: PaymentsUi.surfaceElevated,
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 48.r,
                            color: PaymentsUi.textMuted,
                          ),
                        )
                      : QRView(
                          key: qrKey,
                          onQRViewCreated: _onQRViewCreated,
                          overlay: QrScannerOverlayShape(
                            borderColor: PaymentsUi.primary,
                            borderRadius: 16,
                            borderLength: 40,
                            borderWidth: 8,
                            cutOutSize: box * 0.85,
                          ),
                          onPermissionSet: (c, p) =>
                              _onPermissionSet(context, c, p),
                        ),
                ),
              ),
              if (_cameraPermissionDenied) ...[
                SizedBox(height: 16.h),
                Text(
                  'Enable camera permission in Settings to scan.',
                  textAlign: TextAlign.center,
                  style: PaymentsUi.bodySmall(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
