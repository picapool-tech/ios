import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:picapool/features/auth/auth_state_manager.dart';
import 'package:picapool/features/network/connection_status_listener.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/features/tokens/token_api.dart';

class AuthTokenService extends GetxController {
  final StorageController _storageController = Get.find<StorageController>();
  final AuthStateManager _authStateManager = Get.find<AuthStateManager>();
  final TokenApi _tokenApi = TokenApi();

  bool get isGuest => _storageController.isGuest.value;

  Future<String?> getAccessToken() async {
    if (_storageController.isGuest.value) {
      return null;
    }
    if (_storageController.auth.value == null) {
      await _storageController.loadAuth();
    }

    // String? accessToken = await _storageController.getAccessToken();
    // if (accessToken != null) {
    //   return await validateJWT(accessToken);
    // }

    debugPrint("Storage Auth: ${_storageController.auth.toJson()}");
    if (_storageController.auth.value != null &&
        _storageController.auth.value!.accessToken != null) {
      return await validateJWT(
        _storageController.auth.value!.accessToken!,
      );
    }
    await _storageController.clearAuth();
    await _storageController.clearUser();
    _authStateManager.refreshAuthState();
    return null;
  }

  Future<bool> isTokenExpired(String token) async {
    try {
      return Jwt.isExpired(token);
    } catch (e) {
      debugPrint('Error checking token expiry: $e');
      return true;
    }
  }

  Future<String?> validateJWT(String token) async {
    if (Jwt.isExpired(_storageController.auth.value!.accessToken!)) {
      if (_storageController.user.value == null) {
        debugPrint("User is null");
        return null;
      }

      if (!await ConnectionStatusListener.getInstance().checkConnection()) {
        debugPrint("No internet connection");
        return null;
      }

      final result = await _tokenApi.refreshAccessToken(
        refreshToken: _storageController.auth.value!.refreshToken!,
        oldAccessToken: _storageController.auth.value!.accessToken!,
      );

      return result.fold(
        (fail) {
          debugPrint(
              "Error while updating access token: ${fail.message} in storage controller.");
          _storageController.clearAuth();
          _storageController.clearUser();
          _authStateManager.refreshAuthState();
          return null;
        },
        (newAccessToken) async {
          var newAuth = _storageController.auth.value!
              .copyWith(accessToken: newAccessToken);
          await _storageController.saveAuth(newAuth);
          await _storageController.saveAccessToken(newAccessToken);
          _storageController.auth.value = newAuth;
          _storageController.update();
          debugPrint(
            "Getting access Token : $newAccessToken : ${_storageController.auth.value!.accessToken}",
          );
          return newAccessToken;
        },
      );
    } else {
      debugPrint("Access Token is not expired");
      return _storageController.auth.value!.accessToken;
    }
  }
}
