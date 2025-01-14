import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;

class PermissionUtil {
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Show dialog directing to enable location services
      await Get.dialog(
        AlertDialog(
          title: const Text("Location Services Disabled"),
          content: const Text(
            "Location services are disabled. Please enable them in settings.",
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Get.back();
              },
              child: const Text("Go to Settings"),
            ),
          ],
        ),
      );
      return false;
    }

    // Check and request location permissions
    var permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        // Show custom dialog to request permission
        bool request = await _showPermissionDialog(
          title: 'Location Permission',
          content: 'This app requires access to your location.',
          permission: Permission.locationWhenInUse,
        );
        return request;
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      // Show dialog directing to app settings
      await _showPermanentlyDeniedDialog(
        title: 'Location Permission',
        content:
            'Location permissions are permanently denied. Please enable them in settings.',
      );
      return false;
    }

    return true; // Assuming permission is granted if none of the conditions above are met
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

  Future<bool> requestPhotoPermission() async {
    PermissionStatus status = await Permission.photos.status;

    if (status.isDenied) {
      // Show custom dialog to request permission
      bool request = await _showPermissionDialog(
        title: 'Photo Permission',
        content: 'This app requires access to your photos.',
        permission: Permission.photos,
      );
      return request;
    } else if (status.isPermanentlyDenied) {
      // Show dialog directing to app settings
      await _showPermanentlyDeniedDialog(
        title: 'Photo Permission',
        content:
            'Photo permissions are permanently denied. Please enable them in settings.',
      );
      return false;
    }

    return status.isGranted;
  }

  Future<bool> requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;

    if (status.isDenied) {
      // Show custom dialog to request permission
      bool request = await _showPermissionDialog(
        title: 'Camera Permission',
        content: 'This app requires access to your camera.',
        permission: Permission.camera,
      );
      return request;
    } else if (status.isPermanentlyDenied) {
      // Show dialog directing to app settings
      await _showPermanentlyDeniedDialog(
        title: 'Camera Permission',
        content:
            'Camera permissions are permanently denied. Please enable them in settings.',
      );
      return false;
    }

    return status.isGranted;
  }

  Future<bool> isLocationPermissionGranted() async {
    return await Permission.location.isGranted;
  }

  Future<bool> isPhotoPermissionGranted() async {
    return await Permission.photos.isGranted ||
        await Permission.photos.isLimited;
  }

  Future<bool> isCameraPermissionGranted() async {
    return await Permission.camera.isGranted;
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
