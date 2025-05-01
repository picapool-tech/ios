import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/functions/model_bottom_sheet_caller.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/features/auth/auth_controller.dart';
import 'package:picapool/features/feedback/feedback_controller.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/screens/login/otp_screen.dart';
import 'package:picapool/screens/pooling_history/pooling_history.dart';
import 'package:picapool/screens/profile_page/functions/feedback/feedback_sheet.dart';
import 'package:picapool/screens/profile_page/functions/notification_preferences/notification_preferences.dart';
import 'package:picapool/screens/profile_page/functions/permissions/permission_sheet.dart';
import 'package:picapool/screens/profile_page/widgets/logout_widget.dart';
import 'package:picapool/screens/profile_page/widgets/tile_buttons.dart';
import 'package:picapool/screens/profile_page/widgets/user_info.dart';
import 'package:picapool/utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageController _storageController = Get.find<StorageController>();
  final AuthController _authController = Get.find<AuthController>();
  final FeedbackController _feedbackController = Get.find<FeedbackController>();
  bool imageError = false;

  TextTheme get textTheme => Theme.of(context).textTheme;

  @override
  Widget build(BuildContext context) {
    var user = _storageController.user.value;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("You need to have an account to access this page"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff02005D),
        systemOverlayStyle: uiOverlayStyle(
          context,
          brightness: Brightness.dark,
        ),
        actions: [
          PicaPrimaryButton(
            isLoading: false.obs,
            onPressed: () async {
              if (kDebugMode) {
                Get.to(
                  () => const OtpScreen(
                    phoneNumber: "917224052216",
                  ),
                );
                return;
              }

              var url = Uri.parse("https://wa.me/917224052216");
              if (!await launchUrl(url)) {
                debugPrint("Could not launch $url");
              }
            },
            text: "Help",
          ),
        ],
      ),
      backgroundColor: const Color(0xff02005D), // Dark blue background
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header section with profile picture, name, and other details
          const UserInfo(),
          const SizedBox(height: 15),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.currentTheme.dialogBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              clipBehavior: Clip.hardEdge,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.currentTheme.scaffoldBackgroundColor,
                        border: Border.all(
                          color: AppTheme.currentTheme.primaryColor,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.fromLTRB(
                        16,
                        20,
                        16,
                        20,
                      ),
                      child: Column(
                        children: [
                          TileButton(
                            imagePath: "assets/icons/Bell.png",
                            title: 'Notification Preferences',
                            onTap: () => Get.to(
                              () => const NotificationPreferences(),
                            ),
                          ),
                          TileButton(
                              imagePath: "assets/icons/History.png",
                              title: 'Pooling History',
                              onTap: () {
                                Get.to(() => const PoolingHistory());
                              }),
                          TileButton(
                            imagePath: "assets/icons/Letter Opened.png",
                            title: 'Feedback Form',
                            onTap: () {
                              _showFeedbackModal(context);
                            },
                          ),
                          TileButton(
                            imagePath: "assets/icons/Frame 157.png",
                            title: 'Permissions',
                            onTap: () {
                              _showPermissionsModal(
                                  context); // Open permissions modal
                            },
                          ),
                          TileButton(
                            imagePath: "assets/icons/File Text.png",
                            title: 'Privacy Policy',
                            onTap: () async {
                              // Open privacy policy page
                              final Uri url = Uri.parse(
                                'https://www.picapool.com/privacy-policy.html',
                              );
                              debugPrint(url.toString());
                              if (!await launchUrl(url)) {
                                debugPrint("Could not launch $url");
                              }
                            },
                          ),
                          TileButton(
                            imagePath: "assets/icons/Group 59.png",
                            title: 'App Guide',
                            isDisabled: true,
                            onTap: () {},
                          ),
                          if (kDebugMode)
                            TileButton(
                              imagePath: "assets/icons/Group 59.png",
                              title: 'Delete Account',
                              onTap: () {},
                            ),
                          TileButton(
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
                    Text(
                      "Picapool for ${Platform.isAndroid ? "Android" : "iOS"} BETA v3.1.3 (31001052025)",
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppTheme.currentTheme.disabledColor,
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
          // Footer section with version number
        ],
      ),
    );
  }

  void _showFeedbackModal(BuildContext context) {
    showPicaModelBottomSheet(
      context: context,
      child: FeebackSheet(feedbackController: _feedbackController),
    );
  }

  void _showLogoutModal(BuildContext context) {
    showPicaModelBottomSheet(context: context, child: const LogoutWidget());
  }

  void _showPermissionsModal(BuildContext context) {
    showPicaModelBottomSheet(
      context: context,
      child: const PermissionSheet(),
    );
  }
}
