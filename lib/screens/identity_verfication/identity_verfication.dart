import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/common/widgets/text_field_widgets.dart';
import 'package:picapool/features/identity_verification/indentity_verification_controller.dart';

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
  bool get isValidated => _formKey.currentState?.validate() ?? false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verify Organization Email',
          // style: TextStyle(
          //   color: Color(0xffFFFFFF),
          // ),
        ),
        // systemOverlayStyle: uiOverlayStyle(
        //   context,
        //   brightness: Brightness.dark,
        // ),
        automaticallyImplyLeading: true,
        elevation: 0,
        // backgroundColor: const Color(0xff02005D),
        // iconTheme: const IconThemeData(
        //   color: Colors.white,
        // ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 12,
            children: [
              Image.asset(
                "assets/images/identity_illustration_blue.png",
                width: double.infinity,
                height: 400,
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
              ),
              SizedBox(
                width: double.infinity,
                child: PicaPrimaryButton(
                  text: "Verify Email",
                  onPressed: () {
                    // var isValidated = _formKey.currentState?.validate();
                    // if (isValidated != true) {
                    //   return;
                    // }
                    // _controller.sendVerificationCode(
                    //   email: _emailController.text,
                    // );
                    isLoading.value = !isLoading.value;
                    Future.delayed(const Duration(seconds: 2), () {
                      isLoading.value = !isLoading.value;
                      // if (isValidated) {
                      //   _controller.sendVerificationCode(
                      //     email: _emailController.text,
                      //   );
                      // }
                    });
                  },
                  isLoading: isLoading,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
