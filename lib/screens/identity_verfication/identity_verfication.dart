import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/common/widgets/text_field_widgets.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/features/identity_verification/enum/identity_loading_enum.dart';
import 'package:picapool/features/identity_verification/indentity_verification_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/screens/identity_verfication/otp_verification.dart';

class IdentityVerfication extends StatefulWidget {
  const IdentityVerfication({super.key});

  @override
  State<IdentityVerfication> createState() => _IdentityVerficationState();
}

class _IdentityVerficationState extends State<IdentityVerfication> {
  final IndentityVerificationController _controller =
      Get.find<IndentityVerificationController>();

  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  final IndentityVerificationController _identityVerificationController =
      Get.put(IndentityVerificationController());
  final UserController _userController = Get.find<UserController>();
  String? errorText;
  bool get isValidated => _formKey.currentState?.validate() ?? false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Verify Organization Email',
        ),
        automaticallyImplyLeading: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 12,
            children: [
              Image.asset(
                "assets/images/identity_illustration_blue.png",
                width: double.infinity,
                height: 300,
              ),
              const Text(
                'We don\'t spam. Your email address is used to verify your organization and will not be shared with anyone.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xff6B7280),
                ),
              ),
              PicaOutlinedTextField(
                hintText: 'Enter your organization email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                controller: _emailController,
                autovalidateMode: AutovalidateMode.always,
                
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email cannot be left empty";
                  }
                  final emailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return "Please enter a valid email address";
                  }
                  return null;
                },
                errorText: errorText,
                onChanged: (p0) => setState(() {
                  errorText = null;
                })
              ),
              PicaPrimaryButton(
                text: "Verify Email",
                onPressed: _sendVerificationCode,
                isLoading: _controller.getLoadingState(
                  IdentityLoadingEnum.sendVerificationCode,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  FutureVoid _sendVerificationCode() async {
    setState(() {
      errorText = null;
    });

    var (isSent, error) =
        await _controller.sendVerificationCode(email: _emailController.text);

    if (isSent) {
      Get.to(
        () => OtpVerificationScreen(
          userId: _userController.user!.id,
          email: _emailController.text,
        ),
      );
    } else {
      setState(() {
        errorText = error;
      });
      // Get.snackbar(
      //   "Error",
      //   "Failed to send verification code. Please try again.",
      //   snackPosition: SnackPosition.TOP,
      //   backgroundColor: Colors.red.withOpacity(0.8),
      //   colorText: Colors.white,
      // );
    }
  }
}
