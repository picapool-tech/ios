import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:picapool/functions/auth/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();

  String selectedCountryCode = "91";
  String selectedFlag = "🇮🇳";

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a valid mobile number';
    } else if (value.length != 10) {
      return 'Mobile number must be 10 digits';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Mobile number must contain only digits';
    }
    return null;
  }

  void _sendOtp(String phoneNumber) async {
    await authController.sendOtp(phoneNumber);
  }

  void _signInWithGoogle() async {
    await authController.loginWithGoogle();
  }

  void _signInWithApple() async {
    await authController.loginWithApple();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 150),
                const Row(
                  children: [
                    Text(
                      "Login",
                      style: TextStyle(
                        fontFamily: "MontserratSB",
                        color: Color(0xff000000),
                        fontSize: 36,
                      ),
                    ),
                    Icon(
                      Icons.login_rounded,
                      size: 40,
                      color: Color(0xff000000),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Enter your phone number",
                  style: TextStyle(
                      fontFamily: "MontserratR",
                      color: Color(0xff000000),
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: const Color(0xffFFFFFF),
                        border: Border.all(color: const Color(0xffA3A3A3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCountryCode,
                          items: const [
                            DropdownMenuItem(
                              value: "91",
                              child: Row(
                                children: [
                                  Text("🇮🇳"),
                                  SizedBox(width: 8),
                                  Text("+91"),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: "1",
                              child: Row(
                                children: [
                                  Text("🇺🇸"),
                                  SizedBox(width: 8),
                                  Text("+1"),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedCountryCode = value!;
                              selectedFlag = value == "91" ? "🇮🇳" : "🇺🇸";
                            });
                          },
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(Icons.arrow_drop_down,
                                color: Color(0xffA3A3A3)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xffFF8D41)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xffA3A3A3)),
                          ),
                          hintText: "Ph no",
                          hintStyle: const TextStyle(
                            fontFamily: "MontserratR",
                            color: Color(0xffA3A3A3),
                          ),
                          fillColor: const Color(0xffFFFFFF),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: _validatePhoneNumber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      String fullPhoneNumber =
                          "$selectedCountryCode${_phoneController.text}";
                      _sendOtp(fullPhoneNumber);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(const Color(0xffFF8D41)),
                    minimumSize: WidgetStateProperty.all(
                        const Size(double.infinity, 50)),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    )),
                  ),
                  child: authController.isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Send OTP",
                          style: TextStyle(
                            fontFamily: "MontserratSB",
                            color: Color(0xffFFFFFF),
                            fontSize: 16,
                          ),
                        ),
                ),
                const SizedBox(height: 40),
                const Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Color(0xffAAAAAA),
                      ),
                    ),
                    Text("   Or continue with   ",
                        style: TextStyle(
                            fontFamily: "MontserratR",
                            color: Color(0xff757171),
                            fontSize: 12,
                            fontWeight: FontWeight.normal)),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Color(0xffAAAAAA),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _signInWithGoogle,
                      child: Container(
                        height: 42,
                        width: 42,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xffFFFFFF),
                          border: Border.all(
                            color: const Color(0xff000000),
                            width: 1.0,
                          ),
                        ),
                        child: Image.asset("assets/icons/google.png"),
                      ),
                    ),
                    if (Platform.isIOS) ...[
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: _signInWithApple,
                        child: Container(
                          height: 42,
                          width: 42,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xffFFFFFF),
                            border: Border.all(
                              color: const Color(0xff000000),
                              width: 1.0,
                            ),
                          ),
                          child: Image.asset("assets/icons/apple_logo.png"),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text("By continuing, you agree to our",
                      style: TextStyle(
                        fontFamily: "MontserratR",
                        color: Color(0xffA3A3A3),
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      )),
                ),
                const Center(
                  child: Text("Terms & Conditions",
                      style: TextStyle(
                        fontFamily: "MontserratSB",
                        color: Color(0xff000000),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
