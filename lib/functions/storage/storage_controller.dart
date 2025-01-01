import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:picapool/models/auth_model.dart';
import 'package:picapool/models/user_model.dart';

class StorageController extends GetxController {
  final Rx<Auth?> _auth = Rx<Auth?>(null);
  final Rx<User?> _user = Rx<User?>(null);

  Auth? get auth => _auth.value;
  User? get user => _user.value;

  bool get hasAuth => _auth.value != null && _auth.value!.accessToken != null;
  bool get hasUser => _user.value != null;

  @override
  void onInit() {
    super.onInit();
    loadAuth();
    loadUser();
  }

  Future<void> saveAuth(Auth auth) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authData = jsonEncode(auth.toJson());
    await prefs.setString('auth', authData);
    _auth.value = auth;
    _user.value = auth.user;
  }

  Future<void> loadAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint("LOAD AUTH");
    String? authData = prefs.getString('auth');
    if (authData != null) {
      Map<String, dynamic> authMap = jsonDecode(authData);
      Auth auth = Auth.fromJson(authMap);
      _auth.value = auth;
      _user.value = auth.user;
    }
  }

  Future<void> clearAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth');
    _auth.value = null;
    _user.value = null;
  }

  Future<void> saveUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userData = jsonEncode(user.toJson());
    await prefs.setString('user', userData);
    _user.value = user;
  }

  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user');
    if (userData != null) {
      Map<String, dynamic> userMap = jsonDecode(userData);
      User user = User.fromJson(userMap);
      _user.value = user;
    }
  }

  Future<void> clearUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    _user.value = null;
  }
}
