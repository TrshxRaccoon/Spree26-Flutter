import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spree/Services/payments.dart';

class SetPin extends StatefulWidget {
  const SetPin({super.key});

  @override
  State<SetPin> createState() => _SetPinState();
}

class _SetPinState extends State<SetPin> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isLoading = false;
  final Services _services = Services();

  late FocusNode _pinFocus;
  late FocusNode _confirmPinFocus;
  TextEditingController? _activeController;

  @override
  void initState() {
    super.initState();
    _pinFocus = FocusNode();
    _confirmPinFocus = FocusNode();
    _activeController = _pinController;

    _pinFocus.addListener(() {
      if (_pinFocus.hasFocus) setState(() => _activeController = _pinController);
    });
    _confirmPinFocus.addListener(() {
      if (_confirmPinFocus.hasFocus) setState(() => _activeController = _confirmPinController);
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    _pinFocus.dispose();
    _confirmPinFocus.dispose();
    super.dispose();
  }

  bool _validateFields() {
    if (_pinController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter exactly 6 digits for PIN',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "Cinzel", fontSize: 20.r),
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    if (_confirmPinController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter exactly 6 digits for confirm PIN',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "Cinzel", fontSize: 20.r),
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    if (_pinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PIN and Confirm PIN do not match',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "Cinzel", fontSize: 20.r),
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _handleSetPin() async {
    if (!_validateFields()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await _services.setPin(_pinController.text);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'PIN set successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: "Cinzel"),
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          await Future.delayed(const Duration(seconds: 2));
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to set PIN. Please try again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: "Cinzel"),
              ),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: "Cinzel"),
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onKeyPressed(String key) {
    if (_activeController == null) return;
    setState(() {
      if (key == '<') {
        if (_activeController!.text.isNotEmpty) {
          _activeController!.text = _activeController!.text.substring(0, _activeController!.text.length - 1);
        }
      } else {
        if (_activeController!.text.length < 6) {
          _activeController!.text += key;
        }
        // Mirroring your original onChanged logic to unfocus
        if (_activeController!.text.length == 6) {
          if (_activeController == _pinController) {
            FocusScope.of(context).requestFocus(_confirmPinFocus);
          } else {
            FocusScope.of(context).unfocus();
          }
        }
      }
    });
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
  }) {
    bool isActive = focusNode.hasFocus;
    return Container(
      width: 343.w,
      height: 72.h,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark mode surface
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          width: 1.w,
          color: isActive ? const Color(0xFF2563EB) : const Color(0xFF334155),
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          readOnly: true, // Prevents system keyboard from popping up
          showCursor: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.r,
            color: const Color(0xFFF1F5F9), // Digits color requested
            fontFamily: 'Albert',
          ),
          obscureText: true,
          obscuringCharacter: "*",
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 20.r,
              color: const Color(0xFF94A3B8),
              fontFamily: 'Albert',
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildKeyPad() {
    return Column(
      children: [
        _buildKeyPadRow(['1', '2', '3']),
        SizedBox(height: 16.h),
        _buildKeyPadRow(['4', '5', '6']),
        SizedBox(height: 16.h),
        _buildKeyPadRow(['7', '8', '9']),
        SizedBox(height: 16.h),
        _buildKeyPadRow(['', '0', '<']),
      ],
    );
  }

  Widget _buildKeyPadRow(List<String> keys) {
    return SizedBox(
      width: 342.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: keys.map((key) => _buildKey(key)).toList(),
      ),
    );
  }

  Widget _buildKey(String key) {
    if (key.isEmpty) {
      return SizedBox(width: 103.33.w, height: 64.h);
    }
    return GestureDetector(
      onTap: () => _onKeyPressed(key),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 103.33.w, // Dimensions requested
        height: 64.h,    // Dimensions requested
        alignment: Alignment.center,
        child: key == '<'
            ? Icon(Icons.backspace_outlined, color: const Color(0xFFF1F5F9), size: 28.r)
            : Text(
                key,
                style: TextStyle(
                  fontSize: 32.sp,
                  color: const Color(0xFFF1F5F9), // White color for digits
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF111111), // Dark mode background
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.r),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 375.w,
                  height: 54.h,
                  child: Center(
                    child: Text(
                      "SET PIN",
                      style: TextStyle(
                        fontSize: 36.r,
                        color: Colors.white,
                        fontFamily: 'Orbitron_Bold',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 36.h),
                _buildInputBox(
                  controller: _pinController,
                  focusNode: _pinFocus,
                  hint: "ENTER YOUR PIN",
                ),
                SizedBox(height: 10.h),
                _buildInputBox(
                  controller: _confirmPinController,
                  focusNode: _confirmPinFocus,
                  hint: "RE-ENTER YOUR PIN",
                ),
                SizedBox(height: 40.h),
                _buildKeyPad(),
                SizedBox(height: 40.h),
                GestureDetector(
                  onTap: _isLoading ? null : _handleSetPin,
                  child: Container(
                    height: 56.h, // Requested container dimension
                    width: 342.w, // Requested container dimension
                    decoration: BoxDecoration(
                      color: _isLoading ? const Color(0xFF334155) : const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'SET PIN',
                              style: TextStyle(
                                fontFamily: 'Orbitron_Bold',
                                color: Colors.white,
                                fontSize: 20.r,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}