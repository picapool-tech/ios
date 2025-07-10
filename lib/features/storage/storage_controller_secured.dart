import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/models/auth_model.dart';
import 'package:picapool/models/tag_model.dart';
import 'package:picapool/models/user_location_model.dart';
import 'package:picapool/models/user_model.dart';

class StorageController extends GetxController {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _authKey = "auth";
  static const String _userKey = "user";
  static const String _tagsKey = "tags";
  static const String _userLocationsKey = "userLocation";

  Rx<Auth?> auth = Rx<Auth?>(null);
  Rx<User?> user = Rx<User?>(null);
  Rx<List<Tag>> tags = Rx<List<Tag>>([]);

  FutureVoid clearAuth() async {
    await _secureStorage.delete(key: _authKey);
    auth.value = null;
    update();
  }

  FutureVoid clearUser() async {
    await _secureStorage.delete(key: _userKey);
    user.value = null;
    update();
  }

  void initialize() async {
    await loadAuth();
    await loadUser();
    await loadTags();
  }

  Future<Auth?> loadAuth() async {
    debugPrint("Load Auth");
    return _loadData(
        key: _authKey, fromJson: Auth.fromJson, debugMessage: "LOAD AUTH");
  }

  Future<List<Tag>> loadTags() async {
    String? tagsData = await _secureStorage.read(key: _tagsKey);

    if (tagsData == null) {
      return [];
    }

    try {
      List<dynamic> jsonList = jsonDecode(tagsData);
      var tagList = jsonList.map((json) => Tag.fromJson(json)).toList();
      tags.value = tagList;
      update();
      return tagList;
    } catch (e) {
      debugPrint("Error while loading tags: $e");
      return [];
    }
  }

  Future<User?> loadUser() async {
    debugPrint("Load User");
    return _loadData(
        key: _userKey, fromJson: User.fromJson, debugMessage: "LOAD USER");
  }

  Future<T?> _loadData<T>({
    required String key,
    String debugMessage = "LOADING DATA FROM STORAGE CONTROLLER",
    required T Function(Map<String, dynamic>) fromJson,
    bool updateState = true,
  }) async {
    debugPrint(debugMessage);
    String? data = await _secureStorage.read(key: key);
    if (data == null) {
      return null;
    }

    try {
      Map<String, dynamic> jsonData = jsonDecode(data);
      T result = fromJson(jsonData);
      if (updateState) {
        _updateState<T>(result);
      }
      return result;
    } catch (e) {
      debugPrint("Error loading data: $e");
      return null;
    }
  }

  Future<bool> _saveData<T>({
    required String key,
    required T data,
    required Map<String, dynamic> Function(T) toJson,
    bool updateState = true,
  }) async {
    try {
      String jsonData = jsonEncode(toJson(data));
      await _secureStorage.write(key: key, value: jsonData);

      if (updateState) {
        _updateState<T>(data);
      }
      return true;
    } catch (e) {
      debugPrint("Error saving data: $e");
      return false;
    }
  }

  void _updateState<T>(T result) {
    if (result is Auth) {
      auth.value = result;
    } else if (result is User) {
      user.value = result;
    } else if (result is List<Tag>) {
      tags.value = result;
    }
    update();
  }
}
