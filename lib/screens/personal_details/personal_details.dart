import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/common/widgets/text_field_widgets.dart';
import 'package:picapool/features/auth/auth_controller.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/features/user/values/user_data_model_enum.dart';
import 'package:picapool/features/user/values/user_loading_enums.dart';
import 'package:picapool/screens/login/otp_screen.dart';
import 'package:picapool/screens/public_profile/public_profile.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class PersonalDetails extends StatefulWidget {
  const PersonalDetails({Key? key}) : super(key: key);

  @override
  State<PersonalDetails> createState() => _PersonalDetailsState();
}

class _PersonalDetailsState extends State<PersonalDetails> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedGender;
  final AuthController _authController = Get.find<AuthController>();
  final UserController _userController = Get.find<UserController>();

  bool get isFromAppleAuth =>
      Platform.isIOS && _authController.auth?.appleSub != null;

  TextTheme get textTheme => Theme.of(context).textTheme;

  bool get _isFormValid {
    var isValidName = _nameController.text.isNotEmpty || isFromAppleAuth;

    // var isValidPhone = _authController.auth.value?.mobile != null;

    var isValidAge = _ageController.text.isNotEmpty;

    var isValidGender = _selectedGender != null;

    return isValidName && isValidAge && isValidGender;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Center(
          child: SizedBox(
            width: 100,
            child: StepProgressIndicator(
              totalSteps: 2,
              currentStep: 1,
              size: 4,
              padding: 8,
              selectedColor: Colors.orange,
              unselectedColor: Colors.grey[300]!,
            ),
          ),
        ),
        actions: <Widget>[
          // Creates an invisible IconButton to balance the AppBar visually
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.transparent),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Personal Details',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.visibility_off,
                      color: Colors.grey, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    'This is invisible for others',
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              PicaOutlinedTextField(
                labelText: 'Full name*',
                hintText: "Add your fullname here",
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              _buildPhoneField(), // Phone field is optional now
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: PicaOutlinedTextField(
                      hintText: 'Add your age*',
                      controller: _ageController,
                      labelText: "Your Age",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildGenderDropdown(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PicaPrimaryButton(
                onPressed: _isFormValid ? _updateUserPersonalDetails : null,
                text: "Next",
                isLoading: _userController
                    .getLoadingState(UserLoadingEnums.updateUser),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = _userController.user?.name ?? '';
    _ageController.text = _userController.user?.age?.toString() ?? '';
    _selectedGender = _userController.user?.gender;

    _phoneController.text = _authController.auth?.mobile ?? "";
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Your gender',
            style: textTheme.labelSmall,
            children: const [
              TextSpan(
                text: '*',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFA3A3A3), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              borderRadius: BorderRadius.circular(20),
              isExpanded: true,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Select',
                ),
              ),
              value: _selectedGender,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
              items: <String>['Male', 'Female', 'Other']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: textTheme.bodySmall,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return PicaOutlinedTextField(
      controller: _phoneController,
      keyboardType: TextInputType.number,
      readOnly: _authController.auth?.mobile != null,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(12),
      ],
      labelText: "Your phone number",
      hintText: "+91XXXXXXXXXX",
      helperText: "Enter 10 digits phone number only",
      suffixIcon: Padding(
        padding: const EdgeInsets.only(right: 8.0, top: 4.0, bottom: 4.0),
        child: ElevatedButton(
          onPressed: _phoneController.text.length == 10
              ? () async {
                  // Handle verify button press
                  var auth = Get.find<AuthController>();
                  var phone = "91${_phoneController.text}";
                  var isSent = await auth.sendOtp(phone);
                  if (!isSent) {
                    Get.snackbar(
                        "Error", "Not able to get the OTP at this time.");
                    return;
                  }

                  var value = await Get.to(
                    () => OtpScreen(
                      phoneNumber: phone,
                    ),
                  ) as List<dynamic>?;

                  if (value != null && value[0]) {
                    // Verify successful
                    debugPrint("$value is from OTP");
                    var updatedPhoneToServer =
                        await _authController.updatePhoneNumber(
                      phoneNumber: phone,
                      code: value[1],
                    );

                    if (!updatedPhoneToServer) {
                      Get.snackbar(
                          "Oops!", "Not able to update phone at this time.");
                      return;
                    }

                    Get.find<StorageController>().auth.refresh();

                    setState(() {
                      _phoneController.text = phone;
                    });
                  } else {
                    // Verify failed
                    debugPrint("Failed");
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _phoneController.text.length == 10 &&
                    _authController.auth?.mobile == null
                ? const Color(0xFFFF8D41)
                : const Color(0xFFC2C2C2),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(80, 30),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Obx(
            () {
              if (_authController.isLoading.value) {
                return const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                );
              }

              if (_authController.auth?.mobile != null) {
                return const Text(
                  'Verified',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                );
              }

              return const Text(
                'Verify',
                style: TextStyle(
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
      onChanged: (text) {
        setState(() {}); // To update the Verify button's state
      },
    );
  }

  void _updateUserPersonalDetails() async {
    var storageController = Get.find<StorageController>();
    if (storageController.user.value == null) {
      return;
    }

    var backupUser = storageController.user.value;

    storageController.user.update((user) {
      if (isFromAppleAuth) {
        user!.name = "iOS User";
      } else {
        user!.name = _nameController.text;
      }

      user.age = int.parse(_ageController.text);
      user.gender = _selectedGender;
    });

    debugPrint("updateUser: ${storageController.user.toJson()}");
    var successful = await _userController.updateUser(
      [UserField.name, UserField.age, UserField.gender],
      previousUser: backupUser,
    );

    setState(() {});

    if (successful) {
      Get.to(() => const PublicProfile());
    }
  }
}
