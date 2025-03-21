import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/controllers/network_controller.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/features/user/values/user_data_model_enum.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final NetworkController _networkController = Get.find<NetworkController>();

  void handleTokenGeneration() {
    _fcm.onTokenRefresh.listen((token) async {
      var userController = Get.find<UserController>();
      debugPrint("Token updated from fcm");
      if (userController.user != null) {
        if (userController.user!.fcmToken != token) {
          var storageController = Get.find<StorageController>();
          var backupUser = storageController.user.value;
          storageController.user.update((user) {
            user?.fcmToken = token;
          });
          await userController.updateUser(
            [UserField.fcmToken],
            previousUser: backupUser,
          );
        }
      }
    });
  }

  Future<void> requestPermission() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User denied permission');
    }
  }

  Future<String?> retrieveToken() async {
    if (_networkController.isConnected()) {
      return _fcm.getToken();
    }
    return null;
  }
}
