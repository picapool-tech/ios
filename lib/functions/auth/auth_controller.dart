import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:picapool/functions/auth/auth_api.dart';
import 'package:picapool/functions/storage/storage_controller.dart';
import 'package:picapool/models/auth_model.dart';
import 'package:picapool/models/user_model.dart';
import 'package:picapool/screens/login_screen.dart';
import 'package:picapool/screens/otp_screen.dart';
import 'package:picapool/screens/personal_details.dart';
import 'package:picapool/widgets/bottom_navbar/common_bottom_navbar.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  final AuthApi _authApi = AuthApi();
  final StorageController _storageController = Get.find<StorageController>();

  // Use GetX reactive variables for the auth state
  var auth = Rx<Auth?>(null);
  var user = Rx<User?>(null);
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var notLoading = false;

  @override
  void onInit() {
    super.onInit();
    _loadUserOnStartup();
  }

  /// Load user and auth data from storage at startup.
  Future<void> _loadUserOnStartup() async {
    await _storageController.loadAuth();
    await _storageController.loadUser();

    final storageState = _storageController;
    auth.value = storageState.auth;
    user.value = storageState.user;
  }

  /// Handle Google login and store auth and user data.
  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    final result = await _authApi.signInWithGoogle();

    await result.fold(
      (fail) {
        auth.value = null;
        user.value = null;
        errorMessage.value = fail.message;
        showErrorDialog(fail.message);
      },
      (authData) async {
        errorMessage.value = "";
        await loadAndSaveAuth(authData);
        checkForExistingUser();
      },
    );
    isLoading.value = false;
  }

  Future<bool> loadAndSaveAuth(Auth authData) async {
    try {
      var userData =
          await getUser(authData.user!.id, ats: authData.accessToken);
      if (userData != null) {
        debugPrint('User from auth: ${userData.toJson()}');
        authData.user?.update(userData.toJson());
        debugPrint('User from auth: ${authData.toJson()}');
      }

      auth.value = authData;
      user.value = authData.user;
      await _storageController.saveAuth(auth.value!);
      await _storageController.saveUser(user.value!);
      return true;
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }

  /// Handle Apple login and store auth and user data.
  Future<void> loginWithApple() async {
    isLoading.value = true;
    final result = await _authApi.signInWithApple();

    await result.fold(
      (fail) {
        auth.value = null;
        user.value = null;
        errorMessage.value = fail.message;
        showErrorDialog(fail.message);
      },
      (authData) async {
        await loadAndSaveAuth(authData);
        errorMessage.value = "";

        checkForExistingUser();
      },
    );
    isLoading.value = false;
  }

  Future<void> loginWithOtp(String mobile, String otp) async {
    isLoading.value = true;
    notLoading = true;
    final result = await _authApi.loginWithOtp(mobile, otp);

    await result.fold(
      (fail) {
        auth.value = null;
        user.value = null;
        errorMessage.value = fail.message;
        showErrorDialog(fail.message);
      },
      (authData) async {
        await loadAndSaveAuth(authData);
        errorMessage.value = "";
        Get.offAll(() => const NewBottomBar());
        debugPrint('User from otp: ${auth.value?.user?.toJson()}');
      },
    );

    isLoading.value = false;
    notLoading = false;
  }

  Future<void> sendOtp(String phoneNumber) async {
    isLoading.value = true;

    final String url = 'https://api.picapool.com/v2/otp?mobile=$phoneNumber';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: '{}', // Sending an empty JSON object as the body
      );

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 201) {
        Get.to(() => OtpScreen(phoneNumber: phoneNumber));
      } else {
        Get.snackbar(
          'Error',
          'Failed to send OTP. Please try again.',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      showErrorDialog("An error occurred. Please try again later.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String phoneNumber) async {}

  Future<void> createUser() async {
    isLoading.value = true;

    try {
      final result = await _authApi.createUser(
        user.value!,
        auth.value!.accessToken!,
      );

      await result.fold(
        (fail) async {
          errorMessage.value = fail.message;
          var userData = await getUser(user.value!.id);
          auth.value!.user!.update(userData!.toJson());
          user.value!.update(userData.toJson());

          await _storageController.saveUser(user.value!);
          await _storageController.saveAuth(auth.value!);

          showErrorDialog(fail.message);
        },
        (createdUser) async {
          errorMessage.value = "";
          auth.value!.user!.update(createdUser.toJson());
          user.value!.update(createdUser.toJson());
          await _storageController.saveUser(user.value!);
          await _storageController.saveAuth(auth.value!);
        },
      );
    } catch (e) {
      debugPrint('Create User Error: $e');
      showErrorDialog('Failed to create user. Please try again.');
    }

    isLoading.value = false;
  }

  Future<void> updateUserData(User user) async {
    if (auth.value == null) {
      return;
    }
    auth.value!.copyWith(user: user);
    await _storageController.saveUser(user);
  }

  /// Updates the user data and stores it.
  Future<void> updateUser(Map<String, dynamic> updateValues) async {
    isLoading.value = true;

    try {
      final result = await _authApi.updateUser(
        updateValues,
        auth.value!.accessToken!,
      );

      await result.fold(
        (fail) {
          errorMessage.value = fail.message;
          showErrorDialog(fail.message);
        },
        (updatedUser) async {
          auth.value!.user!.update(updateValues);
          await loadAndSaveAuth(auth.value!);
          errorMessage.value = "";
        },
      );
    } catch (e) {
      debugPrint('Update User Error: $e');
      showErrorDialog('Failed to update user. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Logs out the user and clears the stored auth and user data.
  Future<void> logout() async {
    await _storageController.clearUser();
    await _storageController.clearAuth();
    auth.value = null;
    user.value = null;
  }

  Future<User?> getUser(int id, {String? ats}) async {
    final at = auth.value?.accessToken;
    if (at == null && ats == null) {
      return null;
    }

    final result = await _authApi.getUser(userId: id, accessToken: ats ?? at!);

    return await result.fold(
      (fail) async {
        if (_isTokenExpired()) {
          var update = await updateAccessToken();
          if (update) {
            return getUser(id);
          }
        }
        showErrorDialog(fail.message);
        return null;
      },
      (user) {
        return user;
      },
    );
  }

  bool _isTokenExpired() {
    if (auth.value == null || auth.value!.accessToken == null) {
      return true;
    }
    return JwtDecoder.isExpired(auth.value!.accessToken!);
  }

  /// Check if a user is logged in and navigate accordingly.
  void checkForExistingUser() {
    debugPrint('Checking for existing user ${auth.value?.toJson()}');
    debugPrint('Checking for existing user ${user.value?.toJson()}');

    if (auth.value == null || auth.value!.accessToken == null) {
      Get.to(() => const LoginScreen());
    } else if (user.value == null || user.value!.name == null) {
      Get.to(() => const PersonalDetails());
    } else {
      Get.offAll(() => const NewBottomBar());
    }
  }

  /// Show error dialog for failed operations.
  void showErrorDialog(String errorMessage) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: const Text("Error"),
        content: Text(errorMessage),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> updateAccessToken() async {
    debugPrint('REQUESTED FOR UPDATE ACCESS TOKEN');
    String rt = auth.value!.refreshToken!;
    String at = auth.value!.accessToken!;
    var userId = user.value?.id;
    debugPrint('Refresh token: $rt');
    if (userId == null) {
      return false;
    }

    final response = await http.post(
      Uri.parse("https://api.picapool.com/v2/auth/accessToken"),
      body: jsonEncode({
        "refreshToken": rt,
      }),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $at',
      },
    );
    debugPrint('UPDATE ACCESS TOKEN RESPONSE CODE : ${response.statusCode}');

    if (response.statusCode < 300) {
      String newAccessToken = response.body;
      debugPrint('New Access Token: $newAccessToken');

      auth.value!.copyWith(accessToken: newAccessToken);

      await _storageController.saveAuth(auth.value!);
      return true;
    } else if (response.statusCode == 401) {
      logout();
      return false;
    } else {
      logout();
      return false;
    }
  }
}
