import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:picapool/features/auth/auth_state_manager.dart';
import 'package:picapool/models/auth_model.dart';
import 'package:picapool/models/chat_unread_model.dart';
import 'package:picapool/models/tag_model.dart';
import 'package:picapool/models/user_location_model.dart';
import 'package:picapool/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageController extends GetxController {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Rx<Auth?> auth = Rx<Auth?>(null);
  Rx<User?> user = Rx<User?>(null);
  Rx<List<Tag>> tags = Rx<List<Tag>>([]);
  var isGuest = false.obs;

  Future<void> clearAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth');
    auth.value = null;
    update();
  }

  Future<void> clearUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    user.value = null;
    update();
  }

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken;
    if (prefs.containsKey("accessToken")) {
      accessToken = prefs.getString("accessToken");
      if (accessToken != null) {
        // we will migrate the access token to secure storage here
        await _secureStorage.write(key: "accessToken", value: accessToken);

        await prefs.remove("accessToken");
      }
    }
    accessToken ??= await _secureStorage.read(key: "accessToken");
    if (accessToken == null) {
      return null;
    }

    return accessToken;
  }

  Future<Map<int, ChatUnreadModel>> getLastReadMessagesWithChatId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint("LOADING LAST MESSAGE FROM STORAGE CONTROLLER");
    String? messageData = prefs.getString("message");
    if (messageData == null) {
      return {};
    }

    Map<String, dynamic> jsonData = jsonDecode(messageData);
    Map<int, ChatUnreadModel> readChat = {};
    jsonData.forEach((key, value) {
      readChat[int.parse(key)] = ChatUnreadModel.fromJson(value);
    });

    return readChat;
  }

  void initialize() async {
    await loadAuth();
    await loadUser();
    await loadTags();
  }

  Future<Auth?> loadAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    debugPrint("LOAD AUTH");
    String? authData;

    if (prefs.containsKey("auth")) {
      authData = prefs.getString('auth');
      if (authData != null) {
        // we will migrate the auth data to secure storage here
        await _secureStorage.write(key: 'auth', value: authData);

        // and will remove it from shared preferences
        await prefs.remove('auth');
      }
    }

    // if not, we will read from secure storage
    authData ??= await _secureStorage.read(key: 'auth');
    log("HERE IS THE AUTH DATA -> $authData");

    if (authData == null) {
      debugPrint("No auth data found in secure storage");
      return null;
    }

    Map<String, dynamic> authMap = jsonDecode(authData);
    log("HERE IS JSON DECODE FOR AUTH DATA -> $authMap");
    try {
      auth.value =
          Auth.fromJson(authMap, customMessage: "FROM STORAGE CONTROLLER");
      log("HERE CHECK VALUE OF THIS.AUTH HERE -> $auth");

      update();
      return auth.value;
    } catch (e) {
      log("FOUND EXCEPTION IN CONVERTING AUTH FROM JSON -> $e");
    }

    return auth.value;
  }

  Future<List<Tag>> loadTags() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? tagsData = prefs.getStringList('tags');
    if (tagsData != null) {
      try {
        var tag = tagsData.map((tag) => Tag.fromJson(jsonDecode(tag))).toList();
        tags.value = tag;
        tags.refresh();
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
    String? userData;
    if (prefs.containsKey('user')) {
      userData = prefs.getString('user');
      if (userData != null) {
        // we will migrate the user data to secure storage here
        await _secureStorage.write(key: 'user', value: userData);

        // and will remove it from shared preferences
        await prefs.remove('user');
      }
    }

    userData ??= await _secureStorage.read(key: 'user');

    debugPrint("LOADING USER FROM STORAGE CONTROLLER");
    // String? userData = prefs.getString('user');
    if (userData == null) {
      return null;
    }

    Map<String, dynamic> userMap = jsonDecode(userData);
    User user = User.fromJson(userMap);
    this.user.value = user;
    update();
    return user;
  }

  Future<List<UserLocationModel>> loadUserLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? locationsData = prefs.getStringList('userLocations');
    if (locationsData != null) {
      try {
        var locations = locationsData
            .map((location) => UserLocationModel.fromJson(jsonDecode(location)))
            .toList();
        return locations;
      } catch (e) {
        debugPrint("Error while loading user locations: $e");
        return [];
      }
    }
    return [];
  }

  Future<void> logout() async {
    await clearAuth();
    await clearUser();
    try {
      var manager = Get.find<AuthStateManager>();
      manager.refreshAuthState();
    } catch (e) {
      debugPrint(
          "Error refreshing auth state during logout: $e"); // Handle error
    }
  }

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> saveAccessToken(String accessToken) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    await _secureStorage.write(key: "accessToken", value: accessToken);
    // await prefs.setString('accessToken', accessToken);
  }

  Future<void> saveAuth(Auth auth) async {
    debugPrint("Saving auth : ${auth.toJson()}");
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    String authData = jsonEncode(auth.toJson());
    // await prefs.setString('auth', authData);
    await _secureStorage.write(key: 'auth', value: authData);
    await loadAuth();
  }

  /// Saves the last read messages for each chat to persistent storage.
  ///
  /// @param chatReadMessage Map of chat IDs to their unread message information
  /// @return true if saving was successful, false otherwise
  Future<bool> saveLastReadMessagesWithChatId(
      Map<int, ChatUnreadModel>? chatReadMessage) async {
    if (chatReadMessage == null) {
      debugPrint("Cannot save null chat read message data");
      return false;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> jsonSafeMap = {};
      chatReadMessage.forEach((key, value) {
        jsonSafeMap[key.toString()] = value.toJson();
      });

      debugPrint("AFTER JSON_SAFE_MAP: $jsonSafeMap");
      final String readData = jsonEncode(jsonSafeMap);
      debugPrint("AFTER READ DATA: $readData");
      final bool success = await prefs.setString('message', readData);

      if (success) {
        debugPrint(
            "Successfully saved read status for ${chatReadMessage.length} chats");
      } else {
        debugPrint("Failed to save chat read message data");
      }

      return success;
    } catch (e) {
      debugPrint("Error saving chat read message data: $e");
      return false;
    }
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
    await prefs.setString('user', userData);
    await loadUser();
  }

  Future<void> saveUserLocations(List<UserLocationModel> locations) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (locations.isEmpty) {
      return;
    }
    await prefs.setStringList(
      'userLocations',
      locations.map((location) => jsonEncode(location.toJson())).toList(),
    );
  }

  void setIsGuest(bool boolValue) {
    isGuest.value = boolValue;
  }
}
