import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  Future<bool> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.status;
    if (status.isDenied) {
      // Show custom dialog to request permission
      bool request = await _showPermissionDialog(
        title: 'Location Permission',
        content: 'This app requires access to your location.',
        permission: Permission.locationWhenInUse,
      );
      return request;
    } else if (status.isPermanentlyDenied) {
      // Show dialog directing to app settings
      await _showPermanentlyDeniedDialog(
        title: 'Location Permission',
        content:
            'Location permissions are permanently denied. Please enable them in settings.',
      );
      return false;
    }

    return status.isGranted;
  }

  Future<bool> requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isDenied) {
      // Show custom dialog to request permission
      bool request = await _showPermissionDialog(
        title: 'Notification Permission',
        content: 'This app requires access to send you notifications.',
        permission: Permission.notification,
      );
      return request;
    } else if (status.isPermanentlyDenied) {
      // Show dialog directing to app settings
      await _showPermanentlyDeniedDialog(
        title: 'Notification Permission',
        content:
            'Notification permissions are permanently denied. Please enable them in settings.',
      );
      return false;
    }

    return status.isGranted;
  }

  Future<bool> isLocationPermissionGranted() async {
    return await Permission.location.isGranted;
  }

  /// Checks if notification permission is granted
  Future<bool> isNotificationPermissionGranted() async {
    return await Permission.notification.isGranted;
  }

  /// Displays a custom permission request dialog
  Future<bool> _showPermissionDialog({
    required String title,
    required String content,
    required Permission permission,
  }) async {
    bool granted = false;

    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Cancel
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              granted = await permission.request().isGranted;
              Get.back(); // Close dialog
            },
            child: const Text('Allow'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    return granted;
  }

  Future<void> _showPermanentlyDeniedDialog({
    required String title,
    required String content,
  }) async {
    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Cancel
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Get.back(); // Close dialog
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
