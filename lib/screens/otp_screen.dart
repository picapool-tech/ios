import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:picapool/functions/auth/auth_controller.dart';
import 'dart:async';
import 'dart:convert';

import 'package:picapool/models/response_model.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final bool returnValue;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    this.returnValue = false,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  bool _isOtpComplete = false;
  bool _isOtpIncorrect = false;
  bool _isResendButtonDisabled = false;
  int _resendCountdown = 59;
  Timer? _timer;
  String? otpCode;
  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    debugPrint(
      "OTP Screen: ${widget.phoneNumber} with return Value : ${widget.returnValue}",
    );
    for (var controller in _controllers) {
      controller.addListener(_checkOtpComplete);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.removeListener(_checkOtpComplete);
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _checkOtpComplete() {
    setState(() {
      _isOtpComplete =
          _controllers.every((controller) => controller.text.length == 1);
    });
  }

  Future<void> _verifyOtp() async {
    if (authController.isLoading.value) return;
    String otp = _controllers.map((controller) => controller.text).join('');
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
          if (widget.returnValue) {
            debugPrint("INSIDE RETURN VALUE");
            Get.back(result: true);
            return;
          } else {
            await authController.loginWithOtp(widget.phoneNumber, otp);
          }
        } else {
          setState(() {
            _isOtpIncorrect = true;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Incorrect OTP. Please try again.')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to verify OTP. Please try again.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('An error occurred. Please try again later.')),
        );
      }
    }
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
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to resend OTP. $responseBody')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to resend OTP. Please try again.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('An error occurred. Please try again later.')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Enter your code',
                  style: TextStyle(
                    fontFamily: "MontserratR",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.phoneNumber,
                  style: const TextStyle(
                    fontFamily: "MontserratR",
                    fontSize: 12,
                    color: Color(0xff7C7C7C),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (index) => Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _isOtpIncorrect
                                  ? Colors.red
                                  : const Color(0xffFF8D41),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _isOtpIncorrect
                                  ? Colors.red
                                  : const Color(0xffA3A3A3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.only(bottom: 5),
                        ),
                        onChanged: (value) {
                          if (value.length == 1 && index < 3) {
                            _focusNodes[index + 1].requestFocus();
                          }
                          if (_isOtpIncorrect) {
                            setState(() {
                              _isOtpIncorrect = false;
                            });
                          }
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isOtpComplete ? _verifyOtp : null,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.disabled)) {
                          return const Color(0xffC2C2C2);
                        }
                        return const Color(0xffFF8D41);
                      },
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.disabled)) {
                          return const Color(0xff626262);
                        }
                        return const Color(0xffFFFFFF);
                      },
                    ),
                    minimumSize: WidgetStateProperty.all(
                        const Size(double.infinity, 50)),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    )),
                  ),
                  child: Obx(() {
                    if (authController.isLoading.value) {
                      return const CircularProgressIndicator();
                    }
                    return Text(
                      (widget.returnValue) ? "Done" : "Verify",
                      style: const TextStyle(
                        fontFamily: "MontserratSB",
                        fontSize: 16,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Didn't get code?",
                  style: TextStyle(
                    fontFamily: "MontserratR",
                    fontSize: 12,
                    color: Color(0xff7C7C7C),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _isResendButtonDisabled ? null : _resendOtp,
                  child: Text(
                    _isResendButtonDisabled
                        ? "Resend ($_resendCountdown)"
                        : "Resend",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xffFF8D41),
                      fontFamily: "MontserratR",
                      fontSize: 12,
                      color: _isResendButtonDisabled
                          ? Colors.grey
                          : const Color(0xffFF8D41),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
