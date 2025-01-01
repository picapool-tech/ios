import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:picapool/functions/auth/auth_api.dart';
import 'package:picapool/functions/storage/storage_controller.dart';
import 'package:picapool/models/access_token_model.dart';
import 'package:picapool/models/auth_model.dart';
import 'package:picapool/models/login_model.dart';
import 'package:picapool/models/user_model.dart';
import 'package:picapool/screens/login_screen.dart';
import 'package:picapool/screens/otp_screen.dart';
import 'package:picapool/screens/personal_details.dart';
import 'package:picapool/screens/public_profile.dart';
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
    debugPrint("Past auth loading...");

    await _storageController.loadUser();
    debugPrint("Past user loading...");

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
  }

  Future<bool> loadAndSaveAuth(Auth authData, {int? userId}) async {
    try {
      var accessToken = authData.accessToken;
      var userData = await getUser(
        userId ?? authData.user!.id,
        ats: accessToken,
      );
      if (userData != null) {
        debugPrint('User : ${userData.toJson()}');
        authData.user?.update(userData.toJson());
        debugPrint('User from auth: ${authData.toJson()}');
      }

      auth.value = authData;
      auth.value!.user = userData;
      user.value = userData;
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
      (loginModel) async {
        postLoginAction(loginModel);
        // await loadAndSaveAuth(authData);
        // errorMessage.value = "";

        // checkForExistingUser();
      },
    );
    isLoading.value = false;
  }

  Future<void> loginWithOtp(String mobile, String otp) async {
    isLoading.value = true;
    update();
    final result = await _authApi.loginWithOtp(mobile, otp);

    await result.fold(
      (fail) {
        auth.value = null;
        user.value = null;
        errorMessage.value = fail.message;
        showErrorDialog(fail.message);
      },
      (loginModel) async {
        await postLoginAction(loginModel);
        debugPrint('User from otp: ${auth.value?.user?.toJson()}');
      },
    );

    isLoading.value = false;
    update();
  }

  Future<bool> postLoginAction(LoginModel loginModel) async {
    var accessToken =
        AccessTokenModel.fromJson(JwtDecoder.decode(loginModel.accessToken));
    debugPrint("After ACESSTOKEN MODEL : ${accessToken.toJson()}");
    var authData = Auth(
      id: accessToken.authId,
      accessToken: loginModel.accessToken,
      refreshToken: loginModel.refreshToken,
    );
    await loadAndSaveAuth(authData, userId: accessToken.tenant.id);
    debugPrint("After LOAD AND SAVE MODEL : ${user.toJson()}");

    // var user = await getUser(accessToken.tenant.id);
    // if (user != null) {
    //   authData.user = user;
    //   user = user;
    //   await loadAndSaveAuth(authData);
    //   await _storageController.saveUser(user);
    //   return true;
    // }

    errorMessage.value = "";
    checkForExistingUser();
    return false;
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
    update();

    try {
      var accessToken = await getAccessToken();
      final result = await _authApi.createUser(
        user.value!,
        accessToken!,
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
    update();
  }

  Future<void> updateUserData(User user) async {
    if (auth.value == null) {
      return;
    }
    auth.value!.copyWith(user: user);
    await _storageController.saveUser(user);
  }

  /// Updates the user data and stores it.
  Future<bool?> updateUser(Map<String, dynamic> updateValues) async {
    isLoading.value = true;
    update();

    try {
      var accessToken = await getAccessToken();
      final result = await _authApi.updateUser(
        updateValues,
        accessToken!,
      );

      isLoading.value = false;
      update();
      return result.fold(
        (fail) {
          errorMessage.value = fail.message;
          showErrorDialog(fail.message);
          return false;
        },
        (updatedUser) async {
          auth.value!.user!.update(updateValues);
          user.value!.update(updateValues);
          await loadAndSaveAuth(auth.value!);
          update();
          errorMessage.value = "";
          return true;
        },
      );
    } catch (e) {
      debugPrint('Update User Error: $e');
      showErrorDialog('Failed to update user. Please try again.');
      return false;
    } finally {
      isLoading.value = false;
      update();
    }
  }

  /// Logs out the user and clears the stored auth and user data.
  Future<void> logout() async {
    await _storageController.clearUser();
    await _storageController.clearAuth();
    auth.value = null;
    user.value = null;
    // update();
    // checkForExistingUser();
  }

  Future<String?> getAccessToken() async {
    if (auth.value == null) {
      return null;
    }
    var accessToken = auth.value!.accessToken!;
    debugPrint("GETITNG ACCESS TOKEN : $accessToken");
    debugPrint("AUTH VALUE : ${auth.value?.toJson()}");
    if (Jwt.isExpired(accessToken)) {
      debugPrint("JWT is expired");
      var newAccessToken = await _authApi.updateAccessToken(
        accessToken: accessToken,
        refreshToken: auth.value!.refreshToken!,
        userId: user.value!.id,
      );

      newAccessToken.fold((error) {
        logout();
        return accessToken;
      }, (newAccessToken) async {
        auth.value?.copyWith(accessToken: newAccessToken);
        await loadAndSaveAuth(auth.value!);
        return newAccessToken;
      });
    }
    return accessToken;
  }

  Future<User?> getUser(int id, {String? ats}) async {
    final at = await getAccessToken();
    if (at == null && ats == null) {
      logout();
      return null;
    }

    final result = await _authApi.getUser(userId: id, accessToken: ats ?? at!);

    return await result.fold(
      (fail) async {
        showErrorDialog(fail.message);
        return null;
      },
      (user) {
        return user;
      },
    );
  }

  // Check if a user is logged in and navigate accordingly.
  void checkForExistingUser() {
    debugPrint('Checking for existing user from auth ${auth.value?.toJson()}');
    debugPrint('Checking for existing user from user ${user.value?.toJson()}');

    if (auth.value?.accessToken == null) {
      Get.to(() => const LoginScreen());
    } else if (auth.value?.user?.name == null) {
      Get.to(() => const PersonalDetails());
    } else if (auth.value?.user?.username == null) {
      Get.to(() => const PublicProfile());
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
