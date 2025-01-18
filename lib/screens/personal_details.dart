import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/user/user_controller.dart';
import 'package:picapool/screens/otp_screen.dart';
import 'package:picapool/screens/public_profile.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Personal Details',
                  style: TextStyle(
                    fontFamily: "MontserratR",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.visibility_off, color: Colors.grey, size: 16),
                  SizedBox(width: 5),
                  Text(
                    'This is invisible for others',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontFamily: 'MontserratR',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField('Add your full name*', _nameController,
                  isName: true),
              const SizedBox(height: 16),
              _buildPhoneField(), // Phone field is optional now
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Add your age*', _ageController,
                        isAge: true),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildGenderDropdown(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isFormValid()
                    ? () async {
                        // Update user details
                        final user = _userController.user.value;
                        if (user == null) {
                          return;
                        }

                        if (Platform.isIOS) {
                          user.name = "iOS User";
                        } else {
                          user.name = _nameController.text;
                        }

                        user.age = int.parse(_ageController.text);
                        user.gender = _selectedGender;
                        debugPrint("updateUser: ${user.toJson()}");
                        var successful = await _userController.updateUser(
                          {
                            "name": _nameController.text,
                            "age": int.parse(_ageController.text),
                            "gender": _selectedGender.toString(),
                          },
                        );
                        setState(() {});

                        // await authController.updateUserData(user);
                        if (successful) {
                          Get.to(() => const PublicProfile());
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid()
                      ? const Color(0xFFFF8D41)
                      : const Color(0xFFC2C2C2),
                  foregroundColor:
                      _isFormValid() ? Colors.white : const Color(0xFF626262),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: (_userController.isLoading.value)
                    ? const CircularProgressIndicator()
                    : const Text('Next'),
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
    _nameController.text = _userController.user.value?.name ?? '';
    _ageController.text = _userController.user.value?.age?.toString() ?? '';
    _selectedGender = _userController.user.value?.gender;
    _phoneController.text = _authController.auth.value?.mobile ?? "";
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Your gender',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontFamily: 'MontserratR',
            ),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48, // Match the height of other fields
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFA3A3A3), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Select',
                  style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'MontserratR',
                      fontSize: 12),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      value,
                      style: const TextStyle(
                          fontFamily: 'MontserratR', fontSize: 12),
                    ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Add Phone no.',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontFamily: 'MontserratR',
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            hintText: '+1234567890',
            hintStyle: const TextStyle(
                color: Colors.grey, fontFamily: 'MontserratR', fontSize: 12),
            fillColor: Colors.transparent,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFA3A3A3), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFF8D41), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            returnValue: true,
                          ),
                        ) as bool?;

                        if (value != null && value) {
                          // Verify successful
                          debugPrint("$value is from OTP");
                          var auth = _authController.auth.value!.update({
                            "mobile": phone,
                          });
                          await _authController.loadAndSaveAuth(auth);
                          _authController.auth.refresh();
                          await _userController.updateUser({
                            "mobile": phone,
                          });
                          setState(() {});
                        } else {
                          // Verify failed
                          debugPrint("Failed");
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _phoneController.text.length == 10 &&
                          _authController.auth.value?.mobile == null
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

                    if (_authController.auth.value?.mobile != null) {
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
          ),
          style: const TextStyle(fontSize: 14),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          onChanged: (text) {
            setState(() {}); // To update the Verify button's state
          },
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isName = false,
    bool isAge = false,
  }) {
    return (isName && Platform.isIOS)
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: label.split('*')[0],
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontFamily: 'MontserratR',
                  ),
                  children: const [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                keyboardType: isAge
                    ? TextInputType.number
                    : TextInputType.text, // Numeric keyboard for age field
                decoration: InputDecoration(
                  filled: true,
                  hintText: (isAge) ? "Your age" : "Your full name",
                  hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontFamily: 'MontserratR',
                      fontSize: 12),
                  fillColor: Colors.transparent,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFA3A3A3), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFFF8D41), width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                style: const TextStyle(fontSize: 14),
                inputFormatters: [
                  if (isName) ...[
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  ],
                  if (isAge) ...[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                ],
              ),
            ],
          );
  }

  bool _isFormValid() {
    return _nameController.text.isNotEmpty ||
        Platform.isIOS &&
            _ageController.text.isNotEmpty &&
            _selectedGender != null;
  }
}
