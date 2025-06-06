import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:picapool/common/values/values.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/features/auth/auth_controller.dart';
import 'package:picapool/features/auth/values/enums.dart';
import 'package:picapool/models/response_model.dart';
import 'package:picapool/widgets/login/text_field_pin.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  bool _isOtpComplete = false;
  bool _isOtpIncorrect = false;
  bool _isResendButtonDisabled = false;
  bool _isVerified = false;
  int _resendCountdown = 59;
  Timer? _timer;

  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        systemOverlayStyle: uiOverlayStyle(context),
        title: Image.asset('assets/images/ic_launcher.png', height: 40),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Enter your code',
                    style: TextStyle(
                      fontFamily: "MontserratR",
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      widget.phoneNumber,
                      style: const TextStyle(
                        fontFamily: "MontserratR",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff7C7C7C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Improved OTP Input Fields
                  TextFieldPin(
                    codeLength: 4,
                    defaultBoxSize: 60.0,
                    selectedBoxSize: 62.0,
                    margin: 8,
                    autoFocus: true,
                    textController: _otpController,
                    onChange: (value) {
                      if (value.length == 1 && _focusNodes.length > 1) {
                        _focusNodes[1].requestFocus();
                      }
                      _checkOtpComplete();
                    },
                    defaultDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: _isOtpIncorrect
                            ? Colors.red.shade300
                            : Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.5),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xffFF8D41).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: _isOtpIncorrect
                            ? Colors.red
                            : const Color(0xffFF8D41),
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: "MontserratR",
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Success animation when verification is successful
                  if (_isVerified)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade100),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Code verified successfully!",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontFamily: "MontserratR",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 30),

                  // Improved Button
                  SizedBox(
                    width: double.infinity,
                    child: PicaPrimaryButton(
                      onPressed: _isOtpComplete ? _verifyOtp : null,
                      text: "Verify",
                      isLoading: authController
                          .getLoadingState(AuthLoadingEnum.verifyOtp),
                    ),
                  ),

                  // Error message when OTP is incorrect
                  if (_isOtpIncorrect) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Incorrect code. Please try again.",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontFamily: "MontserratR",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),

                  // Improved Resend Option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Didn't get code? ",
                        style: TextStyle(
                          fontFamily: "MontserratR",
                          fontSize: 14,
                          color: Color(0xff7C7C7C),
                        ),
                      ),
                      GestureDetector(
                        onTap: _isResendButtonDisabled ? null : _resendOtp,
                        child: _isResendButtonDisabled
                            ? Row(
                                children: [
                                  const Text(
                                    "Resend in ",
                                    style: TextStyle(
                                      fontFamily: "MontserratR",
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "$_resendCountdown s",
                                      style: const TextStyle(
                                        fontFamily: "MontserratR",
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                "Resend",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xffFF8D41),
                                  fontFamily: "MontserratR",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xffFF8D41),
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    debugPrint(
      "OTP Screen: ${widget.phoneNumber} ",
    );
    _otpController.addListener(_checkOtpComplete);

    // Reset the error state when user starts typing again
    _otpController.addListener(() {
      if (_isOtpIncorrect && _otpController.text.isNotEmpty) {
        setState(() {
          _isOtpIncorrect = false;
        });
      }
    });
  }

  void _checkOtpComplete() {
    setState(() {
      _isOtpComplete = _otpController.text.length == 4;
    });
  }

  Future<void> _resendOtp() async {
    String url = 'https://api.picapool.com/v2/otp?mobile=${widget.phoneNumber}';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobile': widget.phoneNumber,
        }),
      );

      if (response.statusCode == 201) {
        final responseBody = response.body;

        if (responseBody.contains('"type":"success"')) {
          setState(() {
            _isResendButtonDisabled = true;
            _resendCountdown = 59;
          });
          _startResendCountdown();

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('OTP sent successfully!'),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to resend OTP. $responseBody'),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to resend OTP. Please try again.'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('An error occurred. Please try again later.'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  void _startResendCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _isResendButtonDisabled = false;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOtp() async {
    if (authController.isLoading.value) return;
    String otp = _otpController.text;
    String url =
        'https://api.picapool.com/v2/otp/verify?otp=$otp&mobile=${widget.phoneNumber}';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Response: ${response.body}');
      if (response.statusCode == 200) {
        var responseModel = ResponseModel.fromJson(jsonDecode(response.body));

        if (responseModel.success) {
          // Show verification success animation
          setState(() => _isVerified = true);
          await Future.delayed(const Duration(milliseconds: 1000));

          debugPrint("INSIDE RETURN VALUE");
          Get.back(result: <dynamic>[true, otp]);
          return;
        } else {
          setState(() {
            _isOtpIncorrect = true;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Incorrect OTP. Please try again.'),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to verify OTP. Please try again.'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('An error occurred. Please try again later.'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }
}
