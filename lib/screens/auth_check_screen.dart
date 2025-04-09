import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/features/auth/auth_state_manager.dart';
import 'package:picapool/screens/splash_screen/splash_screen.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final AuthStateManager _authStateManager = Get.find<AuthStateManager>();
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }

    return GetBuilder<AuthStateManager>(
        initState: (state) async {},
        builder: (controller) {
          if (!_authStateManager.isInitialized ||
              controller.authState == AuthState.unknown) {
            return const SplashScreen();
          }

          return _authStateManager.getAuthStateScreen();
        });
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  FutureVoid _initializeApp() async {
    _authStateManager.refreshAuthState();

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }
}
