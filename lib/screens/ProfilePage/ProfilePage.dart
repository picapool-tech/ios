import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:picapool/functions/assets/assets_controller.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/feedback/feedback_controller.dart';
import 'package:picapool/functions/storage/storage_controller.dart';
import 'package:picapool/functions/tags/tag_controller.dart';
import 'package:picapool/functions/user/user_controller.dart';
import 'package:picapool/models/user_model.dart';
import 'package:picapool/screens/ProfilePage/notification_preferences/notification_preferences.dart';
import 'package:picapool/screens/login_screen.dart';
import 'package:picapool/screens/otp_screen.dart';
import 'package:picapool/screens/pooling_history.dart';
import 'package:picapool/utils/permission_util.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _feedbackTextController = TextEditingController();

  final AuthController _authController = Get.find<AuthController>();
  final UserController _userController = Get.find<UserController>();
  final StorageController _storageController = Get.find<StorageController>();
  final FeedbackController _feedbackController = Get.find<FeedbackController>();
  bool imageError = false;

  @override
  Widget build(BuildContext context) {
    var user = _userController.user.value;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("You need to have an account to access this page"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xff02005D), // Dark blue background
      body: SafeArea(
        child: Column(
          children: [
            // Header section with profile picture, name, and other details
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      onPressed: () {
                        // Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      if (kDebugMode) {
                        Get.to(() => const OtpScreen(
                              phoneNumber: "917224052216",
                              returnValue: false,
                            ));
                        return;
                      }

                      var url = Uri.parse("https://wa.me/917224052216");
                      if (!await launchUrl(url)) {
                        debugPrint("Could not launch $url");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      "Help",
                      style: TextStyle(
                        fontFamily: "MontserratSB",
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Profile image
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    foregroundImage: (user.pic != null)
                        ? (imageError)
                            ? const AssetImage(
                                'assets/icons/Frame 64.png', // Replace with your image
                                // width: 100,
                                // height: 100,
                              ) as ImageProvider
                            : CachedNetworkImageProvider(
                                user.pic!,
                                errorListener: (p0) {
                                  debugPrint(
                                      "Error loading image : ${p0.toString()} with Access Token : ${_authController.auth.value!.accessToken}");
                                  setState(() {
                                    imageError = true;
                                  });
                                },
                              )
                        : const AssetImage(
                            'assets/icons/Frame 64.png', // Replace with your image
                            // width: 100,
                            // height: 100,
                          ) as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          child: Text(
                            user.name ?? "",
                            style: const TextStyle(
                              fontFamily: "MontserratSB",
                              fontSize: 24,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "@${user.username ?? "nousername"}",
                          style: const TextStyle(
                            fontFamily: "MontserratR",
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _authController.auth.value?.mobile ?? "",
                          style: const TextStyle(
                            fontFamily: "MontserratR",
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await _showEditProfileModal(
                                  context,
                                  user,
                                ); // Open bottom modal
                                setState(() {});
                              },
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/icons/Frame 153.png",
                                    height: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Edit Profile",
                                    style: TextStyle(
                                      fontFamily: "MontserratM",
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xffF0F0F0),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border:
                                Border.all(color: Colors.orange, width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              _buildOptionTile(
                                context,
                                imagePath: "assets/icons/Bell.png",
                                title: 'Notification Preferences',
                                onTap: () => Get.to(
                                  () => const NotificationPreferences(),
                                ),
                              ),
                              _buildOptionTile(context,
                                  imagePath: "assets/icons/History.png",
                                  title: 'Pooling History', onTap: () {
                                Get.to(() => const PoolingHistory());
                              }),
                              _buildOptionTile(
                                context,
                                imagePath: "assets/icons/Letter Opened.png",
                                title: 'Feedback Form',
                                onTap: () {
                                  _showFeedbackModal(context);
                                },
                              ),
                              _buildOptionTile(
                                context,
                                imagePath: "assets/icons/Frame 157.png",
                                title: 'Permissions',
                                onTap: () {
                                  _showPermissionsModal(
                                      context); // Open permissions modal
                                },
                              ),
                              _buildOptionTile(
                                context,
                                imagePath: "assets/icons/File Text.png",
                                title: 'Privacy Policy',
                                onTap: () async {
                                  // Open privacy policy page
                                  final Uri url = Uri.parse(
                                    'https://www.picapool.com/privacy-policy',
                                  );
                                  debugPrint(url.toString());
                                  if (!await launchUrl(url)) {
                                    debugPrint("Could not launch $url");
                                  }
                                },
                              ),
                              _buildOptionTile(
                                context,
                                imagePath: "assets/icons/Group 59.png",
                                title: 'App Guide',
                                isDisabled: true,
                              ),
                              if (kDebugMode)
                                _buildOptionTile(
                                  context,
                                  imagePath: "assets/icons/Group 59.png",
                                  title: 'Delete Account',
                                  onTap: () {},
                                ),
                              _buildOptionTile(
                                context,
                                imagePath: "assets/icons/Frame 59.png",
                                title: 'Logout',
                                onTap: () {
                                  _showLogoutModal(context);
                                  // setState(() {});
                                },
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required String imagePath,
    required String title,
    void Function()? onTap,
    bool isDisabled = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          leading: Image.asset(
            imagePath, // Use the provided image path
            width: 28, // Adjust the size as needed
            height: 28,
            color: (isDisabled) ? Colors.grey : null,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: "MontserratR",
              fontSize: 16,
              color: (isDisabled) ? Colors.grey : Colors.black,
            ),
          ),
          onTap: (!isDisabled) ? onTap : null,
        ),
        if (!isLast)
          const Divider(
            color: Colors.grey, // Grey color divider
            thickness: 0.5,
            height: 2,
          ),
      ],
    );
  }

  Widget _buildPermissionOption(IconData icon, String title,
      {bool isEnabled = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.orange, size: 28),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: "MontserratR",
              ),
            ),
          ],
        ),
        Icon(
          Icons.check_circle,
          color: (isEnabled) ? Colors.green : Colors.grey,
          size: 28,
        ),
      ],
    );
  }

  Widget _buildTextField(
    IconData icon,
    String label,
    TextEditingController controller, {
    bool disabled = false,
    bool isNumberOnly = false,
  }) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        labelText: label,
        border: InputBorder.none, // No border since the container has a border
      ),
      controller: controller,
      enabled: !disabled,
      keyboardType: (isNumberOnly) ? TextInputType.number : TextInputType.text,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }

  Future<XFile?> _pickImage() async {
    if (!await PermissionUtil().isPhotoPermissionGranted()) {
      await PermissionUtil().requestPhotoPermission();
      return null;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
      imageQuality: 10,
    );
    debugPrint("Image has been picked : ${image?.name}");
    return image;
  }

  void _sendFeedback(String feedback) async {
    await _feedbackController.sendFeedback(feedback);
    if (mounted) {
      Navigator.pop(context); // Close the modal
    }
  }

  Future<void> _showEditProfileModal(BuildContext context, User user) async {
    debugPrint(user.toJson().toString());
    _usernameController.text = user.username ?? "";
    _nameController.text = user.name ?? "";
    _phoneController.text = _authController.auth.value?.mobile ?? "";
    XFile? pickedImage;

    await showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true, // This makes modal full screen
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Circular Profile Image with Edit Icon
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: "MontserratSB",
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Update Your Profile Information",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontFamily: "MontserratR",
                      ),
                    ),
                    const SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: (pickedImage == null)
                                ? (user.pic == null)
                                    ? const AssetImage(
                                        'assets/icons/Frame 64.png', // Profile picture asset
                                      ) as ImageProvider
                                    : CachedNetworkImageProvider(user.pic!)
                                : FileImage(
                                    File(pickedImage!.path),
                                  ) as ImageProvider),
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
                              pickedImage = await _pickImage();
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
                        color: Colors.white,
                        border: Border.all(color: Colors.orange, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildTextField(
                              Icons.person, "Name", _nameController),
                          const Divider(thickness: 1.5),
                          _buildTextField(Icons.alternate_email, "Username",
                              _usernameController),
                          const Divider(thickness: 1.5),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  Icons.phone,
                                  "Phone",
                                  _phoneController,
                                  disabled:
                                      _authController.auth.value?.mobile !=
                                          null,
                                  isNumberOnly: true,
                                ),
                              ),
                              if (_authController.auth.value?.mobile == null)
                                TextButton(
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

                                    var sent = await _authController
                                        .sendOtp("91${_phoneController.text}");
                                    if (!sent) {
                                      return;
                                    }
                                    var value = await Get.to(
                                      () => OtpScreen(
                                        phoneNumber:
                                            "91${_phoneController.text}",
                                        returnValue: true,
                                      ),
                                    ) as List<dynamic>?;

                                    if (value != null && value[0]) {
                                      // Verify successful
                                      debugPrint("$value is from OTP");
                                      var updatedPhoneToServer =
                                          await _authController
                                              .updatePhoneNumber(
                                        phoneNumber:
                                            "91${_phoneController.text}",
                                        code: value[1],
                                      );

                                      if (!updatedPhoneToServer) {
                                        Get.snackbar("Oops!",
                                            "Not able to update phone at this time.");
                                        return;
                                      }

                                      var auth =
                                          _authController.auth.value!.update({
                                        "mobile": "91${_phoneController.text}",
                                      });
                                      await _authController
                                          .loadAndSaveAuth(auth);
                                      _authController.auth.refresh();

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
                                        (_authController.auth.value!.mobile !=
                                                null)
                                            ? "Verified"
                                            : "Verify",
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontFamily: "MontserratR",
                                        ),
                                      );
                                    },
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                            ],
                          ),

                          // const Divider(thickness: 1.5),
                          // _buildTextField(
                          //     Icons.email, "Email", "noemail@gmail.com",),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Submit Button
                    ElevatedButton(
                      onPressed: () async {
                        var updatedValues = <String, String>{};
                        if (_nameController.text.isNotEmpty &&
                            _nameController.text != user.name) {
                          updatedValues["name"] = _nameController.text;
                        }
                        if (_usernameController.text.isNotEmpty &&
                            _usernameController.text != user.username) {
                          updatedValues["username"] = _usernameController.text;
                        }
                        // if (_phoneController.text.isNotEmpty &&
                        //     _phoneController.text != user.auth?.mobile) {
                        //   updatedValues["phone"] = _phoneController.text;
                        // }

                        var userPic = user.pic;

                        if (pickedImage != null) {
                          userPic = await Get.find<AssetsController>()
                              .uploadImage(pickedImage,
                                  "${DateTime.now()}${user.username}");
                          if (userPic != null) {
                            updatedValues['pic'] = userPic;
                          }
                        }

                        if (updatedValues.isNotEmpty && context.mounted) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );
                          await _userController.updateUser(updatedValues);
                          if (context.mounted) {
                            Navigator.pop(
                              context,
                            ); // Close the loading dialog
                            Navigator.pop(context); // Close the modal
                            setState(() {});
                          }
                        } else {
                          debugPrint("Update user value : $updatedValues");
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xffFF8D41), // Orange background color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                        ),
                        minimumSize: const Size(
                            double.infinity, 50), // Full width button
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white, // White text color
                          fontSize: 18,
                          fontFamily: "MontserratR",
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Go Back Button
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the modal
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Colors.grey), // Grey outline
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                        ),
                        minimumSize: const Size(
                            double.infinity, 50), // Full width button
                      ),
                      child: const Text(
                        "Go Back",
                        style: TextStyle(
                          color: Colors.grey, // Grey text color
                          fontSize: 16,
                          fontFamily: "MontserratR",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFeedbackModal(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true, // This makes modal full screen
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16.0,
              right: 16.0,
              top: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Help us Improve!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: "MontserratSB",
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your Feedback is incredibly valuable",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontFamily: "MontserratR",
                  ),
                ),
                const SizedBox(height: 16),
                // Feedback TextField
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: "Enter your Feedback...",
                      hintStyle: TextStyle(
                          color: Colors.grey, fontFamily: "MontserratR"),
                      border: InputBorder
                          .none, // No border since the container has a border
                    ),
                    controller: _feedbackTextController,
                  ),
                ),
                const SizedBox(height: 20),
                // Submit Form Button
                ElevatedButton(
                  onPressed: _feedbackTextController.text.isNotEmpty
                      ? () {
                          _sendFeedback(
                            _feedbackTextController.text,
                          ); // Add your feedback submission logic here
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xffFF8D41), // Orange background color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    minimumSize:
                        const Size(double.infinity, 50), // Full width button
                  ),
                  child: (_feedbackController.isLoading.value)
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Submit Form",
                          style: TextStyle(
                            color: Colors.white, // White text color
                            fontSize: 18,
                            fontFamily: "MontserratR",
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                // Rate Us on Play Store Button
                if (Platform.isAndroid)
                  OutlinedButton.icon(
                    onPressed: () async {
                      // Handle Play Store rating action
                      final InAppReview inAppReview = InAppReview.instance;
                      if (await inAppReview.isAvailable()) {
                        inAppReview.requestReview();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side:
                          const BorderSide(color: Colors.grey), // Grey outline
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                      minimumSize:
                          const Size(double.infinity, 50), // Full width button
                    ),
                    icon: Image.asset(
                      'assets/icons/playstore.png', // Play Store icon asset
                      width: 24,
                      height: 24,
                    ),
                    label: const Text(
                      "Rate Us on Play Store",
                      style: TextStyle(
                        color: Colors.grey, // Grey text color
                        fontSize: 16,
                        fontFamily: "MontserratR",
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutModal(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true, // This makes modal full screen
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: "MontserratSB",
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Do you really want to Log Out of your account?",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: "MontserratR",
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Log Out Button
              ElevatedButton(
                onPressed: () async {
                  await _authController.logout();
                  await Get.find<TagController>().unSubscribeToTopics();
                  if (context.mounted) {
                    Navigator.pop(context); // Close the modal
                    Get.offAll(
                      () => const LoginScreen(),
                    );
                  } // Add your logout functionality here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xffFF8D41), // Orange background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  minimumSize:
                      const Size(double.infinity, 50), // Full width button
                ),
                child: const Text(
                  "Log Out",
                  style: TextStyle(
                    color: Colors.white, // White text color
                    fontSize: 18,
                    fontFamily: "MontserratR",
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Go Back Button
              OutlinedButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey), // Grey outline
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  minimumSize:
                      const Size(double.infinity, 50), // Full width button
                ),
                child: const Text(
                  "Go Back",
                  style: TextStyle(
                    color: Colors.grey, // Grey text color
                    fontSize: 16,
                    fontFamily: "MontserratR",
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPermissionsModal(BuildContext context) async {
    var permissionUtil = PermissionUtil();

    if (context.mounted) {
      showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true, // This makes modal full screen
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          var locationEnabled = permissionUtil.isLocationPermissionGranted();
          var notificationEnabled =
              permissionUtil.isNotificationPermissionGranted();

          var galleryEnabled = permissionUtil.isPhotoPermissionGranted();
          var cameraEnabled = permissionUtil.isCameraPermissionGranted();

          return StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Edit your Preferences!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: "MontserratSB",
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enable or Disable your settings",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontFamily: "MontserratR",
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xffFFF7F3),
                      border: Border.all(color: Colors.orange, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        FutureBuilder<bool>(
                            future: locationEnabled,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return InkWell(
                                  onTap: () async {
                                    if (snapshot.data ?? false) {
                                      return;
                                    } else {
                                      await permissionUtil
                                          .requestLocationPermission();
                                      locationEnabled = permissionUtil
                                          .isLocationPermissionGranted();
                                      setState(() {});
                                    }
                                  },
                                  child: _buildPermissionOption(
                                    Icons.location_on,
                                    "Location Access",
                                    isEnabled: snapshot.data!,
                                  ),
                                );
                              }

                              return const SizedBox.shrink();
                            }),
                        const Divider(thickness: 1.5),
                        FutureBuilder<bool>(
                            future: notificationEnabled,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return InkWell(
                                  onTap: () async {
                                    if (snapshot.data ?? false) {
                                      return;
                                    } else {
                                      await permissionUtil
                                          .requestNotificationPermission();
                                      locationEnabled = permissionUtil
                                          .isNotificationPermissionGranted();
                                      setState(() {});
                                    }
                                  },
                                  child: _buildPermissionOption(
                                    Icons.notifications,
                                    "Notifications",
                                    isEnabled: snapshot.data!,
                                  ),
                                );
                              }

                              return const SizedBox.shrink();
                            }),
                        const Divider(thickness: 1.5),
                        FutureBuilder<bool>(
                          future: galleryEnabled,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return InkWell(
                                onTap: () async {
                                  if (snapshot.data ?? false) {
                                    return;
                                  } else {
                                    await permissionUtil
                                        .requestPhotoPermission();
                                    galleryEnabled = permissionUtil
                                        .isPhotoPermissionGranted();
                                    setState(() {});
                                  }
                                },
                                child: _buildPermissionOption(
                                  Icons.photo,
                                  "Photos Library",
                                  isEnabled: snapshot.data!,
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                        const Divider(thickness: 1.5),
                        FutureBuilder<bool>(
                          future: cameraEnabled,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return InkWell(
                                onTap: () async {
                                  if (snapshot.data ?? false) {
                                    return;
                                  } else {
                                    await permissionUtil
                                        .requestCameraPermission();
                                    cameraEnabled = permissionUtil
                                        .isCameraPermissionGranted();
                                    setState(() {});
                                  }
                                },
                                child: _buildPermissionOption(
                                  Icons.camera,
                                  "Camera",
                                  isEnabled: snapshot.data!,
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          });
        },
      );
    }
  }
}
