import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/screens/login/login_screen_imp.dart';
import 'package:picapool/screens/personal_details/personal_details.dart';
import 'package:picapool/screens/public_profile/public_profile.dart';
import 'package:picapool/widgets/bottom_navbar/common_bottom_navbar.dart';

enum AuthState {
  unknown,
  unauthenticated,
  needsPersonalDetails,
  needsUsername,
  authenticated
}

class AuthStateManager extends GetxController {
  final StorageController _storageController = Get.find<StorageController>();
  final _isInitialized = false.obs;
  final _authState = Rx<AuthState>(AuthState.unknown);

  AuthState get authState => _authState.value;
  bool get isInitialized => _isInitialized.value;

  // Get the appropriate widget based on auth state
  Widget getAuthStateScreen() {
    debugPrint('AuthStateManager: Current auth state: ${_authState.value}');
    switch (_authState.value) {
      case AuthState.unauthenticated:
        debugPrint('AuthStateManager: Returning LoginScreenImp');
        return LoginScreenImp();
      case AuthState.needsPersonalDetails:
        debugPrint('AuthStateManager: Returning PersonalDetails screen');
        return const PersonalDetails();
      case AuthState.needsUsername:
        debugPrint('AuthStateManager: Returning PublicProfile screen');
        return const PublicProfile();
      case AuthState.authenticated:
        debugPrint('AuthStateManager: Returning NewBottomBar');
        return const NewBottomBar();
      case AuthState.unknown:
        debugPrint('AuthStateManager: Returning loading screen');
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
    }
  }

  @override
  void onInit() {
    super.onInit();

    _checkAuthState(null);
  }

  void refreshAuthState() {
    _checkAuthState(null);
    update();
  }

  void _checkAuthState(_) {
    final auth = _storageController.auth.value;
    final user = _storageController.user.value;

    if (auth == null || auth.accessToken == null) {
      _authState.value = AuthState.unauthenticated;
    } else if (user == null) {
      _authState.value = AuthState.unauthenticated;
    } else if (user.name == null || user.age == null) {
      _authState.value = AuthState.needsPersonalDetails;
    } else if (_isInvalidUsername(user.username)) {
      _authState.value = AuthState.needsUsername;
    } else {
      _authState.value = AuthState.authenticated;
    }

    _isInitialized.value = true;
  }

  bool _isInvalidUsername(String? username) {
    return username == null ||
        username.isEmpty ||
        username.contains("PIC@USERNAME") ||
        username.contains(
          RegExp(
            r"^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$",
            dotAll: true,
          ),
        );
  }
}
