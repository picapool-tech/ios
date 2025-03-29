import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/features/auth/auth_state_manager.dart';
import 'package:picapool/screens/splash_screen/splash_screen.dart';

class AuthCheckScreen extends StatelessWidget {
  final AuthStateManager _authStateManager = Get.find<AuthStateManager>();

  AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthStateManager>(initState: (state) async {
      await Future.delayed(
        const Duration(milliseconds: 200),
      );
      _authStateManager.refreshAuthState();
    }, builder: (controller) {
      if (!_authStateManager.isInitialized ||
          controller.authState == AuthState.unknown) {
        return const SplashScreen();
      }

      return _authStateManager.getAuthStateScreen();
    });
  }
}
