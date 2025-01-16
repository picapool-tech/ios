import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:picapool/functions/auth/auth_api.dart';
import 'package:picapool/functions/notification/notification_service.dart';
import 'package:picapool/functions/storage/storage_controller.dart';
import 'package:picapool/functions/user/user_controller.dart';
import 'package:picapool/models/access_token_model.dart';
import 'package:picapool/models/auth_model.dart';
import 'package:picapool/models/login_model.dart';
import 'package:picapool/screens/login_screen.dart';
import 'package:picapool/screens/personal_details.dart';
import 'package:picapool/screens/public_profile.dart';
import 'package:picapool/widgets/bottom_navbar/common_bottom_navbar.dart';

class AuthController extends GetxController {
  final AuthApi _authApi = AuthApi();
  final StorageController _storageController = Get.find<StorageController>();
  final UserController _userController = Get.find<UserController>();

  // Use GetX reactive variables for the auth state
  var auth = Rx<Auth?>(null);
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var notLoading = false;

  // Check if a user is logged in and navigate accordingly.
  void checkForExistingUser() {
    debugPrint('Checking for existing user from auth ${auth.value?.toJson()}');
    debugPrint(
        'Checking for existing user from user ${_userController.user.value?.toJson()}');

    if (auth.value?.accessToken == null) {
      Get.to(() => const LoginScreen());
    } else if (_userController.user.value?.name == null) {
      Get.to(() => const PersonalDetails());
    } else if (_userController.user.value?.username == null) {
      Get.to(() => const PublicProfile());
    } else {
      Get.offAll(() => const NewBottomBar());
    }
  }

  Future<String?> getAccessToken() async {
    if (auth.value == null) {
      return null;
    }

    var accessToken = auth.value!.accessToken!;
    debugPrint("GETITNG ACCESS TOKEN : $accessToken");
    debugPrint("AUTH VALUE : ${auth.value?.toJson()}");
    if (Jwt.isExpired(accessToken)) {
      await _storageController.loadAuth();
      var tempAuth = _storageController.auth.value;
      if (tempAuth == null) {
        return null;
      }

      if (!Jwt.isExpired(tempAuth.accessToken!)) {
        auth.value = tempAuth;
        update();
        return tempAuth.accessToken;
      }

      debugPrint("JWT is expired");
      var newAccessToken = await _authApi.updateAccessToken(
        accessToken: accessToken,
        refreshToken: auth.value!.refreshToken!,
        userId: _userController.user.value!.id,
      );

      return newAccessToken.fold(
        (error) {
          logout();
          return null;
        },
        (newAccessToken) async {
          var newAuth = auth.value!.copyWith(accessToken: newAccessToken);
          await loadAndSaveAuth(newAuth);
          accessToken = newAccessToken;
          await _storageController.saveAccessToken(accessToken);
          return newAccessToken;
        },
      );
    }
    return accessToken;
  }

  Future<void> handleFCMToken() async {
    debugPrint("handle fcm token");
    var fcm = await NotificationService().retrieveToken();
    if (_userController.user.value == null || fcm == null) {
      return;
    }
    if (_userController.user.value!.fcmToken == null) {
      debugPrint("UPDATED FCM TOKEN");
      await _userController.updateUser({
        "fcmToken": fcm,
      });
    } else {
      if (_userController.user.value!.fcmToken != fcm) {
        debugPrint(
            "UPDATED FROM PREV FCM TOKEN : ${_userController.user.value!.fcmToken} to $fcm");
        await _userController.updateUser({
          "fcmToken": fcm,
        });
      }
    }
  }

// TODO: need to rethink of this approach to limit the api call for getUser
  Future<bool> loadAndSaveAuth(Auth authData,
      {int? userId, String? name}) async {
    try {
      var accessToken = await getAccessToken();
      var userData = await _userController.getUser(
        userId ?? _userController.user.value!.id,
        accessToken: accessToken ?? authData.accessToken!,
      );

      if (userData != null) {
        debugPrint('User from laod and auth: ${userData.toJson()}');
        if (name != null) {
          debugPrint("Found username");
          await _userController.updateUser({
            "name": name,
          });
          userData.name = name;
        }

        _userController.setUser(userData);

        handleFCMToken();
        var userAuth = userData.auth;
        if (userAuth != null) {
          authData.update(
            userAuth.toJson(),
          );
        }
      }
      auth.value = authData;
      await _storageController.saveAuth(auth.value!);
      await _storageController.saveUser(_userController.user.value!);
      update();
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
        _userController.user.value = null;
        errorMessage.value = fail.message;
        showErrorDialog(fail.message);
      },
      (loginModel) async {
        postLoginAction(loginModel);
        // await loadAndSaveAuth(authData);
        // errorMessage.value = "";

        // checkForExistingUser();
      },
    );
    isLoading.value = false;
    update();
  }

  /// Handle Google login and store auth and user data.
  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    update();
    final result = await _authApi.signInWithGoogle();

    await result.fold(
      (fail) {
        auth.value = null;
        _userController.user.value = null;
        debugPrint(fail.message);
        showErrorDialog(fail.message);
      },
      (loginModel) async {
        postLoginAction(loginModel);
        // errorMessage.value = "";
        // debugPrint("From LOGIN WITH GOOGLE : ${authData.toJson()}");
        // await loadAndSaveAuth(authData);
        // checkForExistingUser();
      },
    );
    isLoading.value = false;
    update();
  }

  Future<void> loginWithOtp(String mobile, String otp) async {
    isLoading.value = true;
    update();
    final result = await _authApi.loginWithOtp(mobile, otp);

    await result.fold(
      (fail) {
        auth.value = null;
        _userController.user.value = null;
        errorMessage.value = fail.message;
        showErrorDialog(fail.message);
      },
      (loginModel) async {
        await postLoginAction(loginModel, mobile: mobile);
        debugPrint('User from otp: ${_userController.user.value?.toJson()}');
      },
    );

    isLoading.value = false;
    update();
  }

  /// Updates the user data and stores it.

  /// Logs out the user and clears the stored auth and user data.
  Future<void> logout() async {
    await _storageController.clearUser();
    await _storageController.clearAuth();

    auth.value = null;
    update();
    _userController.clear();
    Get.offAll(() => const LoginScreen());
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserOnStartup();
  }

  Future<bool> postLoginAction(LoginModel loginModel, {String? mobile}) async {
    var accessToken =
        AccessTokenModel.fromJson(JwtDecoder.decode(loginModel.accessToken));
    debugPrint("After ACESSTOKEN MODEL : ${accessToken.toJson()}");
    var authData = Auth(
      id: accessToken.authId,
      accessToken: loginModel.accessToken,
      refreshToken: loginModel.refreshToken,
      mobile: mobile,
    );
    await _storageController.saveAuth(authData);
    await loadAndSaveAuth(authData,
        userId: accessToken.tenant.id, name: loginModel.name);
    await _storageController.saveAccessToken(loginModel.accessToken);
    debugPrint("After LOAD AND SAVE MODEL : ${_userController.user.toJson()}");

    errorMessage.value = "";
    isLoading.value = false;
    update();
    checkForExistingUser();
    return false;
  }

  Future<bool> sendOtp(String phoneNumber) async {
    isLoading.value = true;
    update();

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
        isLoading.value = false;
        update();
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to send OTP. Please try again.',
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error: $e');
      showErrorDialog("An error occurred. Please try again later.");
      return false;
    } finally {
      isLoading.value = false;
      update();
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

  Future<void> verifyOtp(String phoneNumber) async {}

  /// Load user and auth data from storage at startup.
  Future<void> _loadUserOnStartup() async {
    auth.value =
        _storageController.auth.value ??= await _storageController.loadAuth();
    debugPrint("loading auth controller from storage!.");
    update();
  }

  // Future<bool> updateAccessToken() async {
  //   debugPrint('REQUESTED FOR UPDATE ACCESS TOKEN');
  //   String rt = auth.value!.refreshToken!;
  //   String at = auth.value!.accessToken!;
  //   var userId = user.value?.id;
  //   debugPrint('Refresh token: $rt');
  //   if (userId == null) {
  //     return false;
  //   }

  //   final response = await http.post(
  //     Uri.parse("https://api.picapool.com/v2/auth/accessToken"),
  //     body: jsonEncode({
  //       "refreshToken": rt,
  //     }),
  //     headers: {
  //       "Content-Type": "application/json",
  //       'Authorization': 'Bearer $at',
  //     },
  //   );
  //   debugPrint('UPDATE ACCESS TOKEN RESPONSE CODE : ${response.statusCode}');

  //   if (response.statusCode < 300) {
  //     String newAccessToken = response.body;
  //     debugPrint('New Access Token: $newAccessToken');

  //     auth.value!.copyWith(accessToken: newAccessToken);

  //     await _storageController.saveAuth(auth.value!);
  //     return true;
  //   } else if (response.statusCode == 401) {
  //     logout();
  //     return false;
  //   } else {
  //     logout();
  //     return false;
  //   }
  // }
}
