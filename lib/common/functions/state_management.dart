import 'package:flutter/material.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/screens/login/login_screen_imp.dart';
import 'package:picapool/screens/personal_details/personal_details.dart';
import 'package:picapool/screens/public_profile/public_profile.dart';
import 'package:picapool/widgets/main_screen.dart';
// import 'package:picapool/widgets/bottom_navbar/common_bottom_navbar.dart';

Widget handleAuthState(StorageController storageController) {
  debugPrint("INSIDE MAIN METHOD Auth: ${storageController.auth.value}");

  final auth = storageController.auth.value;
  final user = storageController.user.value;

  if (auth == null || auth.accessToken == null) {
    return LoginScreenImp();
  }

  if (user == null) {
    return LoginScreenImp();
  }

  if (user.name == null || user.age == null) {
    return const PersonalDetails();
  }

  if (user.username == null ||
      user.username!.isEmpty ||
      user.username!.contains("PIC@USERNAME")) {
    return const PublicProfile();
  }

  return const MainScreen();
}
