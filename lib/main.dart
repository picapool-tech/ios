import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/controllers/live_offer_controller.dart';
import 'package:picapool/controllers/network_controller.dart';
import 'package:picapool/controllers/product_controller.dart';
import 'package:picapool/firebase_options_new.dart';
import 'package:picapool/functions/assets/assets_controller.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/chats/chat_controller.dart';
import 'package:picapool/functions/feedback/feedback_controller.dart';
import 'package:picapool/functions/location/location_provider.dart';
import 'package:picapool/functions/notification/notification_service.dart';
import 'package:picapool/functions/offers/offers_controller.dart';
import 'package:picapool/functions/storage/storage_controller.dart';
import 'package:picapool/functions/tags/tag_controller.dart';
import 'package:picapool/functions/user/user_controller.dart';
import 'package:picapool/functions/vicinity/vicinity_controller.dart';
import 'package:picapool/screens/login_screen.dart';
import 'package:picapool/screens/personal_details.dart';
import 'package:picapool/widgets/bottom_navbar/common_bottom_navbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "new-picapool",
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
  Get.put(NetworkController());
  Get.put(TagController());

  NotificationService().requestPermission();
  FirebaseMessaging.onBackgroundMessage(handleNotification);
  NotificationService().handleTokenGeneration();
  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> handleNotification(RemoteMessage message) async {
  debugPrint('Notification opened the app: ${message.data}');
  // Handle navigation or other actions.
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    listenNotification();

    return GetMaterialApp(
      title: 'Picapool',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
        textSelectionTheme:
            const TextSelectionThemeData(cursorColor: Color(0xffffffff)),
      ),
      home: _handleAuthState(authController),
    );
  }

  listenNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received in foreground: ${message.notification?.title}');
      // You can show a dialog, toast, or in-app UI here.
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked while in background: ${message.data}');
      // Handle navigation or other actions.
    });
  }

  Widget _handleAuthState(AuthController authController) {
    final UserController userController = Get.find<UserController>();
    debugPrint("INSIDE MAIN METHOD Auth: ${authController.auth.value}");
    if (authController.auth.value == null ||
        authController.auth.value!.accessToken == null) {
      return const LoginScreen();
    } else if (userController.user.value == null ||
        userController.user.value!.name == null) {
      return const PersonalDetails();
    } else {
      return const NewBottomBar();
    }
  }
}
