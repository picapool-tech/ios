import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/features/identity_verification/indentity_verification_controller.dart';
import 'package:picapool/screens/identity_verfication/verified_profile.dart';

class OtpVerificationScreen extends StatefulWidget {
  final int userId;
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  final IndentityVerificationController _controller =
      Get.find<IndentityVerificationController>();

  Timer? _timer;
  int _remainingTime = 60;
  bool _isResendEnabled = false;
  bool _isLoading = false;
  String _otpCode = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Header
            const Text(
              'Verify Your Email',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Enter the 4-digit code sent to\n${widget.email}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 50),

            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 55,
                  height: 65,
                  child: TextFormField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.orange, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) => _onOtpChanged(value, index),
                    onTap: () => _controllers[index].selection =
                        TextSelection.fromPosition(
                      TextPosition(offset: _controllers[index].text.length),
                    ),
                    onEditingComplete: () => _focusNodes[index].unfocus(),
                    onFieldSubmitted: (value) => _focusNodes[index].unfocus(),
                  ),
                );
              }),
            ),

            const SizedBox(height: 40),

            // Timer and Resend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                PicaTextButton(
                  isSmall: true,
                  text: _isResendEnabled
                      ? 'Resend'
                      : 'Resend in ${_remainingTime}s',
                  isLoading: false.obs,
                  onPressed: _isResendEnabled ? _resendOtp : null,
                  color: _isResendEnabled ? Colors.blue : Colors.grey[400],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Verify Button
            PicaPrimaryButton(
              onPressed:
                  _otpCode.length == 4 && !_isLoading ? _verifyOtp : null,
              text: 'Verify',
              isLoading: _isLoading.obs,
            ),

            const Spacer(),

            // Footer
            Text(
              'By continuing, you agree to our Terms of Service\nand Privacy Policy',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _clearOtp() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    _otpCode = '';
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next field when entering a digit
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      // Handle backspace - move to previous field when current is empty
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    // Update the OTP code
    setState(() {
      _otpCode = _controllers.map((controller) => controller.text).join();
    });

    // Auto-verify when all 4 digits are entered
    if (_otpCode.length == 4) {
      _verifyOtp();
    }
  }

  Future<void> _resendOtp() async {
    try {
      // TODO: Implement your resend OTP API call here
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      _startTimer();
      _clearOtp();

      if (mounted) {
        Get.snackbar(
          'OTP Resent',
          'A new OTP has been sent to ${widget.email}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to resend OTP. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void _startTimer() {
    _remainingTime = 60;
    _isResendEnabled = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _isResendEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var (isVerified, message) = await _controller.verifyOtp(
        otp: _otpCode,
      );

      if (isVerified) {
        // Add a small delay before navigation for better UX
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to verified_profile with a fade transition
        if (mounted) {
          Get.off(
            () => VerifiedProfile(
              title: "Profile Verified",
              description:
                  "Your profile has been successfully verified. Enjoy using PicaPool!",
            ),
            transition: Transition.fade,
            fullscreenDialog: true,
            curve: Curves.easeInOutCubic,
            duration: const Duration(milliseconds: 800),
          );
        }
        // if (mounted) {
        //   Get.snackbar(
        //     'Success',
        //     'OTP verified successfully!',
        //     snackPosition: SnackPosition.TOP,
        //     backgroundColor: Colors.green,
        //     colorText: Colors.white,
        //   );
        // }

        // Get.back();
        // Get.back();

        // Navigate to the next screen or perform any other action
        // For example, you can navigate to the dashboard or home screen
        // Navigator.pushReplacementNamed(context, '/dashboard'); // Replace with your route
      } else {
        // Show error message
        if (mounted) {
          Get.snackbar(
            'Oops!',
            message,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );

          _clearOtp();
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        Get.snackbar(
          'Error',
          'Invalid OTP. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        _clearOtp();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
