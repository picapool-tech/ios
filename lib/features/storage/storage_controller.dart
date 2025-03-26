import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/features/network/connection_status_listener.dart';
import 'package:picapool/models/auth_model.dart';
import 'package:picapool/models/chat_unread_model.dart';
import 'package:picapool/models/response_model.dart';
import 'package:picapool/models/tag_model.dart';
import 'package:picapool/models/user_model.dart';
import 'package:picapool/screens/login/login_screen_imp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageController extends GetxController {
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
    if (isGuest.value) {
      return null;
    }
    if (auth.value == null) {
      await loadAuth();
    }
    debugPrint("Storage Auth: ${auth.toJson()}");
    if (auth.value != null && auth.value!.accessToken != null) {
      if (Jwt.isExpired(auth.value!.accessToken!)) {
        if (user.value == null) {
          debugPrint("User is null");
          return null;
        }

        if (!await ConnectionStatusListener.getInstance().checkConnection()) {
          debugPrint("No internet connection");
          return null;
        }

        final result = await updateAccessToken(
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
            Get.offAll(() => LoginScreenImp());

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
    Get.offAll(() => LoginScreenImp());
    return null;
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
    debugPrint("LOADING USER FROM STORAGE CONTROLLER");
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
    if (!Get.currentRoute.contains("login")) {
      Get.offAll(() => LoginScreenImp());
    }
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
    debugPrint("Saving auth : ${auth.toJson()}");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authData = jsonEncode(auth.toJson());
    await prefs.setString('auth', authData);
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

  void setIsGuest(bool boolValue) {
    isGuest.value = boolValue;
  }

  FutureEither<String> updateAccessToken({
    required String accessToken,
    required String refreshToken,
    required int userId,
  }) async {
    debugPrint('REQUESTED FOR UPDATE ACCESS TOKEN');
    debugPrint('Refresh token: $refreshToken');
    try {
      final response = await http.post(
        Uri.parse("https://api.picapool.com/v2/auth/accessToken"),
        body: jsonEncode({
          "refreshToken": refreshToken,
        }),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken',
        },
      );
      debugPrint('UPDATE ACCESS TOKEN RESPONSE CODE : ${response.statusCode}');

      debugPrint('Response :  ${response.body}');
      var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
      if (responseModel.success) {
        String newAccessToken = responseModel.data['newAccessToken'] as String;
        debugPrint("New access TOken from server: $newAccessToken");
        return right(newAccessToken);
      }
      return left(
        Failure(message: responseModel.message, stackTrace: StackTrace.current),
      );
    } catch (e) {
      debugPrint('Error updating access token: $e');
      return left(
        Failure(
          message: "Not able to refresh the access token",
          stackTrace: StackTrace.fromString(
            e.toString(),
          ),
        ),
      );
    }
  }
}
