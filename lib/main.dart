import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/firebase_options.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/chats/chat_controller.dart';
import 'package:picapool/functions/location/location_provider.dart';
import 'package:picapool/functions/offers/offers_controller.dart';
import 'package:picapool/functions/storage/storage_controller.dart';
import 'package:picapool/functions/vicinity/vicinity_api.dart';
import 'package:picapool/functions/vicinity/vicinity_controller.dart';
import 'package:picapool/screens/login_screen.dart';
import 'package:picapool/screens/personal_details.dart';
import 'package:picapool/widgets/bottom_navbar/common_bottom_navbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(StorageController());
  Get.put(AuthController());
  Get.put(LocationController());
  Get.put(VicinityController());
  Get.put(OffersController());
  Get.put(ChatController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return GetMaterialApp(
      title: 'Picapool',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textSelectionTheme:
            const TextSelectionThemeData(cursorColor: Color(0xffffffff)),
      ),
      home: Obx(() => _handleAuthState(authController)),
    );
  }

  Widget _handleAuthState(AuthController authController) {
    if (authController.auth.value == null ||
        authController.auth.value!.accessToken == null) {
      return const LoginScreen();
    } else if (authController.user.value == null ||
        authController.user.value!.name == null) {
      return const PersonalDetails();
    } else {
      return const NewBottomBar();
    }
  }
}
