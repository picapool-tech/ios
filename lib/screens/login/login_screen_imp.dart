import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/functions/url_launch.dart';
import 'package:picapool/common/values/enums.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/common/widgets/dialog_widgets.dart';
import 'package:picapool/common/widgets/text_field_widgets.dart';
import 'package:picapool/features/auth/auth_controller.dart';
import 'package:picapool/features/auth/values/enums.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/screens/login/otp_screen.dart';
import 'package:picapool/screens/login/values/login_enums.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/bottom_navbar/common_bottom_navbar.dart';
import 'package:picapool/widgets/home/divider.dart';

class LoginScreenImp extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController phoneController = TextEditingController();

  LoginScreenImp({super.key});

  bool get isPhoneValid =>
      RegExp(r'^[6-9]\d{9}$').hasMatch(phoneController.text);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        systemOverlayStyle: uiOverlayStyle(
          context,
        ),
        elevation: 0,
        actions: [
          PicaTextButton(
            text: "Sign in as guest",
            onPressed: () {
              Get.find<StorageController>().setIsGuest(true);
              Get.offAll(
                () => const NewBottomBar(),
              );
            },
            isLoading: false.obs,
          )
        ],
      ),
      resizeToAvoidBottomInset: false,
      // extendBody: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Login",
                  style: textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.exit_to_app,
                ),
              ],
            ),
            const SizedBox(
              height: PicaValues.largeSpacing,
            ),
            Text(
              "Enter your phone number",
              style: textTheme.labelLarge,
            ),
            const SizedBox(
              height: PicaValues.mediumSpacing,
            ),
            PicaPhoneField(
              controller: phoneController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                final regex = RegExp(r'^[6-9]\d{9}$');
                if (!regex.hasMatch(value)) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
              onChanged: (value) {
                phoneController.text = value;
              },
            ),
            const SizedBox(
              height: PicaValues.smallSpacing,
            ),
            Text(
              "We'll text you a code to verify you're really you.\nMessage and data rates may apply.",
              style: textTheme.labelSmall?.copyWith(
                color: AppTheme.currentTheme.hintColor,
              ),
            ),
            const SizedBox(
              height: PicaValues.largeSpacing,
            ),
            PicaPrimaryButton(
              text: "Send Otp",
              onPressed: _sendOtp,
              isLoading: authController.getLoadingState(AuthLoadingEnum.phone),
            ),
            const SizedBox(
              height: PicaValues.largeSpacing,
            ),
            CustomDivider(
              text: "Or sign up with",
              color: AppTheme.currentTheme.dividerColor,
              textColor: AppTheme.currentTheme.hintColor,
            ),
            const SizedBox(
              height: PicaValues.largeSpacing,
            ),
            PicaOutlineButton(
              text: "Continue with Google",
              onPressed: authController.loginWithGoogle,
              isLoading: authController.getLoadingState(AuthLoadingEnum.google),
              icon: Image.asset(
                VendorLogin.google.assest,
                width: 18,
              ),
            ),
            const SizedBox(height: PicaValues.mediumSpacing),
            if (Platform.isIOS)
              PicaOutlineButton(
                text: "Continue with Apple",
                onPressed: authController.loginWithApple,
                isLoading:
                    authController.getLoadingState(AuthLoadingEnum.apple),
                icon: Image.asset(
                  VendorLogin.apple.assest,
                  width: 18,
                  color: AppTheme.currentTheme.hintColor,
                ),
              ),
            const SizedBox(
              height: PicaValues.mediumSpacing,
            ),
            Center(
              child: RichText(
                text: TextSpan(
                  text: "By continuing, you agree to our\n",
                  children: [
                    policyInfoTextSpan(TermsInfo.privacyPolicy,
                        separator: ", "),
                    policyInfoTextSpan(TermsInfo.termsOfService,
                        separator: ", "),
                    policyInfoTextSpan(TermsInfo.contentPolicy),
                  ],
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  TextSpan policyInfoTextSpan(
    TermsInfo info, {
    String separator = "",
  }) {
    return TextSpan(
      text: "${info.text}$separator",
      recognizer: TapGestureRecognizer()..onTap = () => _performClick(info),
      style: const TextStyle(
        decoration: TextDecoration.underline,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _performClick(TermsInfo info) {
    launchUrl(info.url);
  }

  void _sendOtp() async {
    debugPrint("+91${phoneController.text}");
    if (phoneController.text.isEmpty) {
      showPicaAlertDialog(
        message: "Please re-enter your phone number",
        confirmText: "Ok",
        onConfirm: () {
          Get.back();
        },
      );
      return;
    }
    if (!isPhoneValid) {
      showPicaAlertDialog(
        message:
            "+91${phoneController.text} number is not valid. Please re-enter your valid phone number",
        confirmText: "Ok",
        onConfirm: () {
          Get.back();
        },
      );
      return;
    }
    bool isSent = await authController.sendOtp(
      "91${phoneController.text}",
    );
    if (isSent) {
      var isVerified = await Get.to(
        () => OtpScreen(
          phoneNumber: "91${phoneController.text}",
        ),
      );

      debugPrint("$isVerified");

      if (isVerified != null && isVerified[0]) {
        await authController.loginWithOtp(
            "91${phoneController.text}", isVerified[1]);
      }
      debugPrint("current route: ${Get.currentRoute}");
    }
    debugPrint("+91${phoneController.text} after 2 seconds");
  }
}
