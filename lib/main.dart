import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:picapool/controllers/brand_controller.dart';
import 'package:picapool/controllers/category_controller.dart';
import 'package:picapool/controllers/live_offer_controller.dart';
import 'package:picapool/controllers/network_controller.dart';
import 'package:picapool/controllers/product_controller.dart';
import 'package:picapool/controllers/sell_form_controller.dart';
import 'package:picapool/core/env.dart';
import 'package:picapool/firebase_options_new.dart';
import 'package:picapool/functions/assets/assets_controller.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/chats/chat_controller.dart';
import 'package:picapool/functions/feedback/feedback_controller.dart';
import 'package:picapool/functions/location/location_provider.dart';
import 'package:picapool/functions/network/connection_status_listener.dart';
import 'package:picapool/functions/notification/notification_service.dart';
import 'package:picapool/functions/offers/offers_controller.dart';
import 'package:picapool/functions/storage/storage_controller.dart';
import 'package:picapool/functions/tags/tag_controller.dart';
import 'package:picapool/functions/user/user_controller.dart';
import 'package:picapool/functions/vicinity/vicinity_controller.dart';
import 'package:picapool/screens/login_screen.dart';
import 'package:picapool/screens/personal_details.dart';
import 'package:picapool/utils/routes.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/bottom_navbar/common_bottom_navbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "new-picapool",
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put(NetworkController.getInstance());
  Get.put(StorageController());
  Get.put(UserController());
  Get.put(AuthController());
  Get.put(LocationController());
  Get.put(VicinityController());
  Get.put(OffersController());
  Get.put(ChatController());
  Get.put(FeedbackController());
  Get.put(AssetsController());
  Get.put(LiveOfferController());
  Get.put(ProductController());
  Get.put(TagController());
  Get.put(BrandController());
  Get.put(FormController());
  Get.put(CategoryController());

  await Env.load();

  NotificationService().requestPermission();
  FirebaseMessaging.onBackgroundMessage(handleNotification);
  NotificationService().handleTokenGeneration();
  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> handleNotification(RemoteMessage message) async {
  debugPrint('Notification opened the app: ${message.notification?.title}');
  debugPrint('Notification opened the app: ${message.data.toString()}');
  debugPrint('Notification opened the app: ${message.notification?.body}');
  // Handle navigation or other actions.
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final StorageController storageController = Get.find<StorageController>();

  @override
  void initState() {
    super.initState();
    ConnectionStatusListener.getInstance().initialize();
    if (Platform.isAndroid) {
      checkForUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: GetRoutes.routes,
      title: 'Picapool',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: appTheme.primaryColor,
        useMaterial3: true,
      ),
      home: GetBuilder(
          init: storageController,
          builder: (controller) {
            return _handleAuthState();
          }),
    );
  }

  Widget _handleAuthState() {
    debugPrint("INSIDE MAIN METHOD Auth: ${storageController.auth.value}");

    if (storageController.auth.value != null &&
        storageController.auth.value!.accessToken == null) {
      return const LoginScreen();
    } else if (storageController.user.value != null &&
        storageController.user.value!.name == null) {
      return const PersonalDetails();
    } else if (storageController.auth.value != null &&
        storageController.auth.value!.accessToken != null &&
        storageController.user.value != null &&
        storageController.user.value!.name != null) {
      return const NewBottomBar();
    } else {
      return const LoginScreen();
    }
  }

  void checkForUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        try {
          await InAppUpdate.performImmediateUpdate();
        } catch (e) {
          debugPrint('Immediate update failed: $e');
          await InAppUpdate.startFlexibleUpdate();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'An update is available. Please restart the app to complete the update.'),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }
}
