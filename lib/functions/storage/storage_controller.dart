import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:picapool/functions/auth/auth_api.dart';
import 'package:picapool/models/auth_model.dart';
import 'package:picapool/models/tag_model.dart';
import 'package:picapool/models/user_model.dart';
import 'package:picapool/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageController extends GetxController {
  final AuthApi _authApi = AuthApi();

  var auth = Rx<Auth?>(null);
  var user = Rx<User?>(null);
  var tags = Rx<List<Tag>>([]);

  Future<void> clearAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth');
    auth.value = null;
  }

  Future<void> clearUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    user.value = null;
  }

  Future<String?> getAccessToken() async {
    await loadAuth();
    debugPrint("Storage Auth: ${auth.toJson()}");
    if (auth.value != null && auth.value!.accessToken != null) {
      if (Jwt.isExpired(auth.value!.accessToken!)) {
        if (user.value == null) {
          debugPrint("User is null");
          return null;
        }
        final result = await _authApi.updateAccessToken(
          accessToken: auth.value!.accessToken!,
          refreshToken: auth.value!.refreshToken!,
          userId: user.value!.id,
        );
        return result.fold(
          (fail) {
            debugPrint(
                "Error while updating access token: $fail in storage controller.");
            clearAuth();
            clearUser();
            Get.offAll(() => const LoginScreen());
            return null;
          },
          (newAccessToken) async {
            var newAuth = auth.value!.copyWith(accessToken: newAccessToken);
            await saveAuth(newAuth);
            await saveAccessToken(newAccessToken);
            auth.value = newAuth;
            update();
            debugPrint(
              "Getting access Token : $newAccessToken : ${auth.value!.accessToken}",
            );
            return newAccessToken;
          },
        );
      } else {
        debugPrint("Access Token is not expired");
        return auth.value!.accessToken;
      }
    }
    clearAuth();
    clearUser();
    Get.offAll(() => const LoginScreen());
    return null;
  }

  void initialize() async {
    await loadAuth();
    await loadUser();
    await loadTags();
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

  Future<List<Tag>> loadTags() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? tagsData = prefs.getStringList('tags');
    if (tagsData != null) {
      try {
        var tag = tagsData.map((tag) => Tag.fromJson(jsonDecode(tag))).toList();
        tags.value = tag;
        update();
        return tag;
      } catch (e) {
        debugPrint("Error while loading tags: $e");
        return [];
      }
    }
    return [];
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

  Future<void> logout() async {
    await clearAuth();
    await clearUser();
    Get.offAllNamed('/login');
  }

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> saveAccessToken(String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
  }

  Future<void> saveAuth(Auth auth) async {
    assert(auth.accessToken != null);
    debugPrint("Saving auth : ${auth.toJson()}");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authData = jsonEncode(auth.toJson());
    await loadAuth();
    await prefs.setString('auth', authData);
  }

  Future<void> saveTags(List<Tag> tags) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (tags.isEmpty) {
      return;
    }
    await prefs.setStringList(
      'tags',
      tags.map((tag) => jsonEncode(tag.toJson())).toList(),
    );
    debugPrint("Tags saved");
  }

  Future<void> saveUser(User user) async {
    debugPrint("Saving user: ${user.toJson()}");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userData = jsonEncode(user.toJson());
    await loadUser();
    await prefs.setString('user', userData);
  }
}
