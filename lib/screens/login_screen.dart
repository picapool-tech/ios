import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:picapool/controllers/network_controller.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/screens/otp_screen.dart';
import 'package:picapool/screens/public_profile.dart';
import 'package:picapool/widgets/login/google_button.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();

  final NetworkController _networkController = Get.find<NetworkController>();

  String selectedCountryCode = "91";
  String selectedFlag = "🇮🇳";

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
                const SizedBox(height: 120),
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
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "We’ll text you a code to verify you’re really you.",
                  style: TextStyle(
                      fontFamily: "MontserratR",
                      color: Color(0xff757171),
                      fontSize: 12,
                      fontWeight: FontWeight.normal),
                ),
                const Text(
                  "Message and data rates may apply.",
                  style: TextStyle(
                    fontFamily: "MontserratR",
                    color: Color(0xff757171),
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        !authController.isLoading.value) {
                      String fullPhoneNumber =
                          "$selectedCountryCode${_phoneController.text}";
                      _sendOtp(fullPhoneNumber);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      const Color(0xffFF8D41),
                    ),
                    minimumSize: WidgetStateProperty.all(
                      const Size(double.infinity, 50),
                    ),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    )),
                  ),
                  child: Obx(
                    () {
                      if (authController.isLoading.value) {
                        return const CircularProgressIndicator();
                      }
                      return const Text(
                        "Send OTP",
                        style: TextStyle(
                          fontFamily: "MontserratSB",
                          color: Color(0xffFFFFFF),
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VendorLoginButton(
                      title: "Continue with Google",
                      onPressed: _signInWithGoogle,
                      assetName: "assets/icons/google.png",
                    ),
                    const SizedBox(height: 20),
                    if (Platform.isIOS)
                      VendorLoginButton(
                        title: "Continue with Apple ID",
                        onPressed: _signInWithApple,
                        assetName: "assets/icons/apple_logos.png",
                      ),

                    // MaterialButton(
                    //   onPressed: _signInWithGoogle,
                    //   shape: OutlineInputBorder(
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 15, vertical: 10),
                    //   child: Row(
                    //     children: [
                    //       Image.asset(
                    //         "assets/icons/google.png",
                    //         height: 20,
                    //       ),
                    //       const SizedBox(width: 10),
                    //       const Text(
                    //         "Sign in with Google",
                    //         style: TextStyle(
                    //           fontFamily: "MontserratR",
                    //           color: Color(0xff757171),
                    //           fontSize: 12,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // if (!Platform.isIOS) ...[
                    // const SizedBox(width: 20),
                    //   MaterialButton(
                    //     onPressed: _signInWithGoogle,
                    //     shape: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 15, vertical: 10),
                    //     child: Row(
                    //       children: [
                    //         Image.asset(
                    //           "assets/icons/apple_logo.png",
                    //           height: 20,
                    //         ),
                    //         const SizedBox(width: 10),
                    //         const Text(
                    //           "Sign in with Google",
                    //           style: TextStyle(
                    //             fontFamily: "MontserratR",
                    //             color: Color(0xff757171),
                    //             fontSize: 12,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),

                    // ],
                  ],
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text("By continuing, you agree to our",
                      style: TextStyle(
                        fontFamily: "MontserratR",
                        color: Color(0xff757171),
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _termText(
                      "Terms of Service",
                      onTap: () {
                        _launchUrl(
                            "https://picapool.com/terms-and-conditions.html");
                      },
                    ),
                    const SizedBox(width: 10),
                    _termText(
                      "Privacy Policy",
                      onTap: () {
                        _launchUrl(
                            "https://www.picapool.com/privacy-policy.html");
                      },
                    ),
                    const SizedBox(width: 10),
                    _termText(
                      "Content policy",
                      onTap: () {
                        _launchUrl(
                            "https://www.picapool.com/refund-policy.html");
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Center(
                  child: InkWell(
                    onTap: () {
                      Get.to(
                        () => const PublicProfile(),
                      );
                    },
                    child: const Text(
                      "Continue as a guest",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontFamily: "MontserratR",
                        color: Color(0xff757171),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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

  void _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      debugPrint("Could not launch $url");
    }
  }

  void _sendOtp(String phoneNumber) async {
    if (authController.isLoading.value) {
      return;
    }
    var isSent = await authController.sendOtp(phoneNumber);
    if (isSent) {
      Get.to(
        () => OtpScreen(phoneNumber: phoneNumber),
      );
    }
  }

  void _signInWithApple() async {
    if (authController.isLoading.value) {
      return;
    }
    await authController.loginWithApple();
  }

  void _signInWithGoogle() async {
    if (authController.isLoading.value) {
      return;
    }
    await authController.loginWithGoogle();
  }

  Widget _termText(String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          decoration: TextDecoration.underline,
          fontFamily: "MontserratR",
          color: Color(0xff757171),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

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
}
