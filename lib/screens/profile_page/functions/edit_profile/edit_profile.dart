import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/common/widgets/text_field_widgets.dart';
import 'package:picapool/features/assets/assets_controller.dart';
import 'package:picapool/features/auth/auth_controller.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/features/user/values/user_data_model_enum.dart';
import 'package:picapool/features/user/values/user_loading_enums.dart';
import 'package:picapool/models/user_model.dart';
import 'package:picapool/screens/login/otp_screen.dart';
import 'package:picapool/utils/image_utils.dart';
import 'package:picapool/utils/theme.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final UserController _userController = Get.find<UserController>();
  final AuthController _authController = Get.find<AuthController>();

  final StorageController _storageController = Get.find<StorageController>();

  XFile? pickedImage;

  String get getPhoneNumber =>
      _authController.auth?.mobile?.replaceFirst("91", "") ?? "";

  User get user => _userController.user!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.currentTheme.cardColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Edit Profile",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Update Your Profile Information",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  foregroundImage: (pickedImage == null)
                      ? (user.pic == null)
                          ? const AssetImage(
                              'assets/icons/Frame 64.png', // Profile picture asset
                            ) as ImageProvider
                          : CachedNetworkImageProvider(
                              user.pic!,
                            )
                      : Image.file(
                          File(
                            pickedImage!.path,
                          ),
                        ).image,
                ),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xffFF8D41),
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit,
                      size: 18,
                    ),
                    onPressed: () async {
                      // Add your image picker logic here
                      var imagesFile = await ImageUtils.pickImages();
                      pickedImage = imagesFile?.firstOrNull;
                      debugPrint(
                        "picked image from profile section: ${pickedImage?.name}",
                      );
                      setState(() {});
                    },
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Profile Information Section with Orange Border
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 1.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  PicaOutlinedTextField(
                    controller: _nameController,
                    labelText: "Name",
                    prefixIcon: const Icon(Icons.person),
                  ),
                  const Divider(
                    thickness: 1,
                    height: 20,
                  ),
                  PicaOutlinedTextField(
                    controller: _usernameController,
                    labelText: "Username",
                    prefixIcon: const Icon(Icons.alternate_email),
                  ),
                  const Divider(
                    thickness: 1,
                    height: 20,
                  ),
                  PicaPhoneField(
                    controller: _phoneController,
                    labelText: "Phone number",
                    enabled: _authController.auth?.mobile == null,
                    suffixIcon: _checkNumberVerification(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Submit Button
            PicaPrimaryButton(
              isLoading: _userController.getLoadingState(
                UserLoadingEnums.updateUser,
              ),
              onPressed: () async {
                var backupUser = _storageController.user.value;
                List<UserField> userFieldsToBeUpdated = [];

                _storageController.user.update((user) {
                  if (_nameController.text.isNotEmpty &&
                      _nameController.text != user!.name) {
                    user.name = _nameController.text;
                    userFieldsToBeUpdated.add(UserField.name);
                  }
                  if (_usernameController.text.isNotEmpty &&
                      _usernameController.text != user!.username) {
                    user.username = _usernameController.text;
                    userFieldsToBeUpdated.add(UserField.username);
                  }
                });

                var userPic = user.pic;

                if (pickedImage != null) {
                  userPic = await Get.find<AssetsController>().uploadImage(
                      pickedImage, "${DateTime.now()}${user.username}");
                  _storageController.user.update((user) {
                    if (userPic != null) {
                      user!.pic = userPic;
                      userFieldsToBeUpdated.add(UserField.pic);
                    }
                  });
                }

                if (context.mounted && userFieldsToBeUpdated.isNotEmpty) {
                  await _userController.updateUser(
                    userFieldsToBeUpdated,
                    previousUser: backupUser,
                  );

                  if (context.mounted) {
                    Navigator.pop(context); // Close the modal
                    setState(() {});
                  }
                } else {
                  debugPrint(
                      "Update user value : ${_storageController.user.value?.toUpdateJson(includeFields: userFieldsToBeUpdated)}");
                  Get.back();
                }
              },
              text: "Submit",
            ),
            const SizedBox(height: 10),
            // Go Back Button
            PicaTextButton(
              onPressed: () {
                Navigator.pop(context); // Close the modal
              },
              text: "Go Back",
              isLoading: false.obs,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
  }

  @override
  void initState() {
    super.initState();

    _nameController.text = user.name ?? "";
    _usernameController.text = user.username ?? "";
    _phoneController.text = getPhoneNumber;
  }

  Widget _checkNumberVerification() {
    if (_authController.auth?.mobile == null) {
      return TextButton(
        onPressed: () async {
          if (_phoneController.text.isEmpty) {
            Get.snackbar(
              "Error",
              "Phone number cannot be empty",
              snackPosition: SnackPosition.TOP,
            );
            return;
          }

          if (_phoneController.text.length != 10) {
            Get.snackbar(
              "Error",
              "Phone number should be 10 digits",
              snackPosition: SnackPosition.TOP,
            );
            return;
          }

          var sent =
              await _authController.sendOtp("91${_phoneController.text}");
          if (!sent) {
            return;
          }
          var value = await Get.to(
            () => OtpScreen(
              phoneNumber: "91${_phoneController.text}",
            ),
          ) as List<dynamic>?;

          if (value != null && value[0]) {
            // Verify successful
            debugPrint("$value is from OTP");
            var updatedPhoneToServer = await _authController.updatePhoneNumber(
              phoneNumber: "91${_phoneController.text}",
              code: value[1],
            );

            if (!updatedPhoneToServer) {
              Get.snackbar("Oops!", "Not able to update phone at this time.");
              return;
            }

            var auth = _storageController.auth.value!.update({
              "mobile": "91${_phoneController.text}",
            });
            await _storageController.saveAuth(auth);
            setState(() {});
          } else {
            // Verify failed
            debugPrint("Failed");
            Get.snackbar(
              "Error",
              "Could not update phone number",
              snackPosition: SnackPosition.TOP,
            );
          }
        },
        child: Obx(
          () {
            if (_authController.isLoading.value) {
              return const CircularProgressIndicator();
            }
            return Text(
              (_authController.auth!.mobile != null) ? "Verified" : "Verify",
              style: const TextStyle(
                color: Colors.orange,
                fontFamily: "MontserratR",
              ),
            );
          },
        ),
      );
    } else {
      return const Icon(
        Icons.check_circle,
        color: Colors.green,
      );
    }
  }
}
