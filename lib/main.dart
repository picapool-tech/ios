import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:picapool/common/widgets/dialog_widgets.dart';
import 'package:picapool/controllers/brand_controller.dart';
import 'package:picapool/controllers/category_controller.dart';
import 'package:picapool/controllers/live_offer_controller.dart';
import 'package:picapool/controllers/network_controller.dart';
import 'package:picapool/controllers/sell_form_controller.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/core/env.dart';
import 'package:picapool/features/assets/assets_controller.dart';
import 'package:picapool/features/auth/auth_controller.dart';
import 'package:picapool/features/auth/auth_state_manager.dart';
import 'package:picapool/features/buy_and_sell/products_controller.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/features/feedback/feedback_controller.dart';
import 'package:picapool/features/location/location_controller.dart';
import 'package:picapool/features/network/connection_status_listener.dart';
import 'package:picapool/features/notification/notification_service.dart';
import 'package:picapool/features/offers/offers_controller.dart';
import 'package:picapool/features/partners/partner_controller.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/features/tags/tag_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/features/vicinity/vicinity_controller.dart';
import 'package:picapool/firebase_options_new.dart';
import 'package:picapool/screens/auth_check_screen.dart';
import 'package:picapool/utils/routes.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/bottom_navbar/common_bottom_navbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "new-picapool",
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await checkingForDynamicLink();

  await Env.load();

  Get.put(StorageController(), permanent: true);
  Get.put(PicapoolApi(), permanent: true);

  Get.put(NetworkController.getInstance(), permanent: true);
  Get.put(AuthStateManager(), permanent: true);
  Get.lazyPut(() => UserController(), fenix: true);
  Get.lazyPut(() => AuthController(), fenix: true);
  Get.lazyPut(() => LocationController(), fenix: true);
  Get.lazyPut(() => VicinityController(), fenix: true);
  Get.lazyPut(() => OffersController(), fenix: true);
  Get.lazyPut(() => ChatController(), fenix: true);
  Get.lazyPut(() => FeedbackController(), fenix: true);
  Get.lazyPut(() => AssetsController(), fenix: true);
  Get.lazyPut(() => LiveOfferController(), fenix: true);
  Get.lazyPut(() => TagController(), fenix: true);
  Get.lazyPut(() => ProductsController(), fenix: true);
  Get.lazyPut(() => BrandController(), fenix: true);
  Get.lazyPut(() => FormController(), fenix: true);
  Get.lazyPut(() => CategoryController(), fenix: true);
  Get.lazyPut(() => PartnerController(), fenix: true);

  NotificationService().requestPermission();
  FirebaseMessaging.onBackgroundMessage(handleNotification);
  NotificationService().handleTokenGeneration();
  runApp(const MyApp());
}

Future<void> checkingForDynamicLink() async {
  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinksPlatform.instance.getInitialLink();

  if (initialLink != null) {
    handleDynamicLink(initialLink);
  }

  FirebaseDynamicLinksPlatform.instance.onLink
      .listen((PendingDynamicLinkData? pendingDynamicLinkData) {
    if (pendingDynamicLinkData != null) {
      handleDynamicLink(pendingDynamicLinkData);
    }
  });
}

void handleDynamicLink(PendingDynamicLinkData dynamicLinkData) {
  showPicaAlertDialog(
    title: "Dynamicy Link Detected",
    message: dynamicLinkData.link.toString(),
    confirmText: "Great",
    onConfirm: () {
      Get.back();
    },
  );
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
        Get.to(
          () => const NewBottomBar(
            currentIndex: 2,
          ),
        );
      }
    } else if (action == "openChatPage" ||
        message.notification!.title!.contains("New Message")) {
      Get.to(
        () => const NewBottomBar(
          currentIndex: 1,
        ),
      );
    }
  } else {
    if (message.notification!.title!.contains("New Message")) {
      Get.to(
        () => const NewBottomBar(
          currentIndex: 1,
        ),
      );
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final StorageController _storageController = Get.find<StorageController>();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: GetRoutes.routes,
      title: 'Picapool',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.light,
      home: AuthCheckScreen(),
      // GetBuilder<StorageController>(
      //     init: _storageController,
      //     builder: (controller) {
      //       debugPrint(
      //           "Main rebuild - Auth: ${_storageController.auth.value != null}, User: ${_storageController.user.value != null}");

      //       final auth = _storageController.auth.value;
      //       final user = _storageController.user.value;

      //       // Clear state for debugging - optional
      //       if (auth == null || auth.accessToken == null) {
      //         debugPrint("No valid auth token - showing login screen");
      //         return LoginScreenImp();
      //       }

      //       if (user == null) {
      //         debugPrint("No user data - showing login screen");
      //         return LoginScreenImp();
      //       }

      //       if (user.name == null || user.age == null) {
      //         debugPrint(
      //             "Missing user details - showing personal details screen");
      //         return const PersonalDetails();
      //       }

      //       if (user.username == null ||
      //           user.username!.isEmpty ||
      //           user.username!.contains("PIC@USERNAME") ||
      //           user.username!.contains(
      //             RegExp(
      //               r"^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$",
      //               dotAll: true,
      //             ),
      //           )) {
      //         debugPrint("Missing username - showing public profile screen");
      //         return const PublicProfile();
      //       }

      //       debugPrint("All conditions met - showing home screen");
      //       return const NewBottomBar();
      //     }),
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
                  'An update is available. Please restart the app to complete the update.',
                ),
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
}
