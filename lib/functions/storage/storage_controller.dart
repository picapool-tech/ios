import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:picapool/functions/auth/auth_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:picapool/models/auth_model.dart';
import 'package:picapool/models/user_model.dart';

class StorageController extends GetxController {
  final AuthApi _authApi = AuthApi();

  var auth = Rx<Auth?>(null);
  var user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  void initialize() async {
    await loadAuth();
    await loadUser();
  }

  Future<void> saveAuth(Auth auth) async {
    assert(auth.accessToken != null);
    debugPrint("Saving auth : ${auth.toJson()}");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authData = jsonEncode(auth.toJson());
    await prefs.setString('auth', authData);
  }

  Future<Auth?> loadAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint("LOAD AUTH");
    String? authData = prefs.getString('auth');
    if (authData != null) {
      Map<String, dynamic> authMap = jsonDecode(authData);
      Auth auth = Auth.fromJson(authMap);
      this.auth.value = auth;
      update();
      return auth;
    }
    return null;
  }

  Future<void> clearAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth');
  }

  Future<void> saveUser(User user) async {
    debugPrint("Saving user: ${user.toJson()}");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userData = jsonEncode(user.toJson());
    await prefs.setString('user', userData);
  }

  Future<User?> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint("LOAD USER");
    String? userData = prefs.getString('user');
    if (userData != null) {
      Map<String, dynamic> userMap = jsonDecode(userData);
      User user = User.fromJson(userMap);
      this.user.value = user;
      update();
      return user;
    }
    return null;
  }

  Future<void> clearUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  Future<String?> getAccessToken() async {
    var storageAuth = await loadAuth();
    if (storageAuth != null && storageAuth.accessToken != null) {
      if (Jwt.isExpired(storageAuth.accessToken!)) {
        final result = await _authApi.updateAccessToken(
          accessToken: storageAuth.accessToken!,
          refreshToken: storageAuth.refreshToken!,
          userId: user.value!.id,
        );
        return result.fold(
          (fail) {
            clearAuth();
            clearUser();
            Get.offAllNamed('/login');
            return null;
          },
          (newAccessToken) async {
            var newAuth = storageAuth.copyWith(accessToken: newAccessToken);
            await saveAuth(newAuth);
            auth.value = storageAuth;
            return newAccessToken;
          },
        );
      }
      return storageAuth.accessToken;
    }
    return null;
  }
}
