import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:picapool/common/widgets/dialog_widgets.dart';
import 'package:picapool/core/reactive_loading.dart';
import 'package:picapool/features/auth/authUpdateModel/authUpdateModel.dart';
import 'package:picapool/features/auth/auth_api.dart';
import 'package:picapool/features/auth/auth_state_manager.dart';
import 'package:picapool/features/auth/values/enums.dart';
import 'package:picapool/features/notification/notification_service.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/features/tokens/token_service.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/features/user/values/user_data_model_enum.dart';
import 'package:picapool/models/access_token_model.dart';
import 'package:picapool/models/auth_model.dart';
import 'package:picapool/models/login_model.dart';

class AuthController extends GetxController
    with ReactiveLoading<AuthLoadingEnum> {
  final AuthApi _authApi = AuthApi();
  final StorageController _storageController = Get.find<StorageController>();
  final AuthStateManager _authStateManager = Get.find<AuthStateManager>();
  final UserController _userController = Get.find<UserController>();
  final AuthTokenService _authTokenService = Get.find<AuthTokenService>();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  Auth? get auth => _storageController.auth.value;

  Future<void> handleFCMToken() async {
    debugPrint("handle fcm token");
    var fcm = await NotificationService().retrieveToken();
    if (_userController.user == null || fcm == null) {
      return;
    }
    if (_userController.user!.fcmToken == null ||
        _userController.user!.fcmToken != fcm) {
      debugPrint("UPDATED FCM TOKEN");
      var backupUser = _storageController.user.value;
      _storageController.user.update((user) {
        user?.fcmToken = fcm;
      });
      await _userController.updateUser(
        [UserField.fcmToken],
        previousUser: backupUser,
      );
    }
  }

  Future<bool> loadAndSaveAuth(
    Auth authData, {
    int? userId,
    String? name,
  }) async {
    try {
      var accessToken = await _authTokenService.getAccessToken();
      var userData = await _userController.getUser(
        userId ?? _userController.user!.id,
        accessToken: accessToken ?? authData.accessToken!,
      );

      if (userData == null) {
        return false;
      }

      await _storageController.saveUser(userData);

      await handleFCMToken();

      var userAuth = userData.auth;
      if (userAuth != null) {
        debugPrint('User Auth: ${userAuth.toJson()}');
        authData = authData.update(userAuth.toJson());
      }

      await _storageController.saveAuth(authData);
      _storageController.refresh();
      return true;
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }

  /// Handle Apple login and store auth and user data.
  Future<void> loginWithApple() async {
    startLoading(AuthLoadingEnum.apple);
    final result = await _authApi.signInWithApple();

    await result.fold(
      (fail) {
        // auth.value = null;
        _storageController.clearAuth();
        // _userController.user.value = null;
        _storageController.clearUser();
        errorMessage.value = fail.message;
        if (fail.showError) {
          showErrorDialog(fail.message);
        }
      },
      (loginModel) async {
        await postLoginAction(loginModel);
        debugPrint("Apple Post login completed");
      },
    );
    stopLoading(AuthLoadingEnum.apple);
  }

  /// Handle Google login and store auth and user data.
  Future<void> loginWithGoogle() async {
    startLoading(AuthLoadingEnum.google);
    final result = await _authApi.signInWithGoogle();

    await result.fold(
      (fail) {
        // auth.value = null;
        // _userController.user.value = null;
        _storageController.clearAuth();
        _storageController.clearUser();
        debugPrint(fail.message);
        if (fail.showError) {
          showErrorDialog(fail.message);
        }
      },
      (loginModel) async {
        await postLoginAction(loginModel);
        debugPrint("Google Post login completed");
      },
    );
    stopLoading(AuthLoadingEnum.google);
  }

  Future<void> loginWithOtp(String mobile, String otp) async {
    isLoading.value = true;
    startLoading(AuthLoadingEnum.phone);
    update();
    final result = await _authApi.loginWithOtp(mobile, otp);

    await result.fold(
      (fail) {
        _storageController.clearAuth();
        _storageController.clearUser();
        errorMessage.value = fail.message;
        if (fail.showError) {
          showErrorDialog(fail.message);
        }
      },
      (loginModel) async {
        await postLoginAction(loginModel, mobile: mobile);
        debugPrint('User from otp: ${_userController.user?.toJson()}');
      },
    );

    isLoading.value = false;
    stopLoading(AuthLoadingEnum.phone);
    update();
  }

  /// Updates the user data and stores it.
  /// Logs out the user and clears the stored auth and user data.
  Future<void> logout() async {
    await _storageController.clearUser();
    await _storageController.clearAuth();
    _authStateManager.refreshAuthState();
  }

  @override
  void onInit() {
    super.onInit();
    initializeLoadingStates(AuthLoadingEnum.values);
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
    await _storageController.saveAccessToken(loginModel.accessToken);

    await loadAndSaveAuth(
      authData,
      userId: accessToken.tenant.id,
      name: loginModel.name,
    );

    debugPrint("After LOAD AND SAVE MODEL : ${_userController.user?.toJson()}");

    errorMessage.value = "";
    isLoading.value = false;
    update();

    await Future.delayed(const Duration(milliseconds: 100));
    _authStateManager.refreshAuthState();

    return false;
  }

  @override
  void refresh() {
    _storageController.auth.refresh();
    _storageController.user.refresh();
  }

  Future<bool> sendOtp(String phoneNumber) async {
    startLoading(AuthLoadingEnum.phone);
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
      stopLoading(AuthLoadingEnum.phone);
      update();
    }
  }

  /// Show error dialog for failed operations.
  void showErrorDialog(String errorMessage) {
    showPicaAlertDialog(
      message: errorMessage,
      confirmText: "Ok",
      onConfirm: () {
        Get.back();
      },
    );
  }

  Future<bool> updatePhoneNumber({
    required String phoneNumber,
    required String code,
  }) async {
    isLoading.value = true;
    update();

    var accessToken = await _authTokenService.getAccessToken();
    if (accessToken == null) {
      isLoading.value = true;
      update();
      return false;
    }
    debugPrint("USERID FOR UPDATE PHONE NUMBER : ${_userController.user!.id}");

    try {
      final result = await _authApi.updateAuth(
        updateValue: Authupdatemodel(
          authId: _storageController.auth.value!.id!,
          phone: AuthPhoneModel(
            phone: phoneNumber,
            code: code,
          ),
        ),
      );

      isLoading(false);
      update();

      return await result.fold(
        (fail) {
          errorMessage.value = fail.message;
          if (fail.showError) {
            showErrorDialog(fail.message);
          }
          return false;
        },
        (responseModel) async {
          if (responseModel.success) {
            debugPrint(
                "Phone number updated successfully : ${responseModel.data}");
            Auth newAuth = auth!.copyWith(mobile: phoneNumber);
            _storageController.saveAuth(newAuth);
            return true;
          } else {
            showErrorDialog(responseModel.message);
            return false;
          }
        },
      );
    } catch (e) {
      debugPrint('Error: $e : ${StackTrace.current}');
      showErrorDialog("An error occurred. Please try again later.");
      return false;
    }
  }

  Future<bool> verifyOtp(
      {required String phoneNumber, required String otp}) async {
    startLoading(AuthLoadingEnum.verifyOtp);
    update();

    var result = await _authApi.verifyOtp(phoneNumber: phoneNumber, otp: otp);

    stopLoading(AuthLoadingEnum.verifyOtp);
    update();
    return result.fold((error) {
      if (error.showError) {
        showErrorDialog(error.message);
      }
      return false;
    }, (isVerified) {
      return isVerified;
    });
  }
}
