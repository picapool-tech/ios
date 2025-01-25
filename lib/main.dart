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
import 'package:picapool/functions/partners/partner_controller.dart';
import 'package:picapool/functions/storage/storage_controller.dart';
import 'package:picapool/functions/user/user_controller.dart';
import 'package:picapool/functions/vicinity/vicinity_controller.dart';
import 'package:picapool/screens/login_screen.dart';
import 'package:picapool/screens/personal_details.dart';
import 'package:picapool/screens/public_profile.dart';
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

  Get.put(BrandController());
  Get.put(FormController());
  Get.put(CategoryController());
  Get.put(PartnerController());

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

  var action = message.data['action'];
  if (action != null) {
    if (action == 'openAlertsPage') {
      var offerId = message.data['offerId'];
      if (offerId != null) {
        Get.to(() => const NewBottomBar(
              currentIndex: 2,
            ));
      }
    } else if (action == "openChatPage" ||
        message.notification!.title!.contains("New Message")) {
      Get.to(() => const NewBottomBar(
            currentIndex: 1,
          ));
    }
  } else {
    if (message.notification!.title!.contains("New Message")) {
      Get.to(
        () => const NewBottomBar(
          currentIndex: 1,
        ),
      );
      // }
    }
  }
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
        },
      ),
    );
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

  @override
  void initState() {
    super.initState();
    ConnectionStatusListener.getInstance().initialize();
    if (Platform.isAndroid) {
      checkForUpdate();
    }
  }

  Widget _handleAuthState() {
    debugPrint("INSIDE MAIN METHOD Auth: ${storageController.auth.value}");
    final auth = storageController.auth.value;
    final user = storageController.user.value;

    if (auth == null || auth.accessToken == null) {
      return const LoginScreen();
    }

    if (user == null) {
      return const LoginScreen();
    }

    if (user.name == null || user.age == null) {
      return const PersonalDetails();
    }

    if (user.username == null ||
        user.username!.isEmpty ||
        user.username!.contains("PIC@USERNAME")) {
      return const PublicProfile();
    }

    return const NewBottomBar();
  }
}
