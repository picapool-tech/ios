import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/features/auth/auth_state_manager.dart';

class AuthCheckScreen extends StatelessWidget {
  final AuthStateManager _authStateManager = Get.find<AuthStateManager>();

  AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthStateManager>(initState: (state) {
      _authStateManager.refreshAuthState();
    }, builder: (controller) {
      if (!_authStateManager.isInitialized) {
        return Scaffold(
          body: Center(
            child: Image.asset("assets/images/ic_launcher.png"),
          ),
        );
      }

      return _authStateManager.getAuthStateScreen();
    });
  }
}
