import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:picapool/models/auth_model.dart';
import 'package:picapool/models/user_model.dart';

class StorageController extends GetxController {
  @override
  void onInit() {
    super.onInit();

    loadAuth();
    loadUser();
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
    String? userData = prefs.getString('user');
    if (userData != null) {
      Map<String, dynamic> userMap = jsonDecode(userData);
      User user = User.fromJson(userMap);
      return user;
    }
    return null;
  }

  Future<void> clearUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  Future<String?> getAccessToken() async {
    var auth = await loadAuth();
    if (auth != null) {
      return auth.accessToken;
    }
    return null;
  }
}
