import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import 'package:picapool/common/widgets/dialog_widgets.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/features/user/values/user_data_model_enum.dart';
import 'package:picapool/utils/permission_util.dart';

class LocationController extends GetxController {
  Rx<LocationState> state = LocationState().obs;
  final UserController _userController = Get.find<UserController>();
  final PermissionUtil _permissionUtil = PermissionUtil();
  bool _isUpdating = false;
  geo.Position? prevLocation;
  bool isUserProvidedLocation = false;

  Future<void> getLocation({bool fromInit = false}) async {
    // Check if location services are enabled
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    debugPrint("Location service enabled: $serviceEnabled");
    if (!serviceEnabled) {
      showDialog(
        title: "Location Services is disabled",
        message:
            "Please enable location services to show offers near your vicinity.",
        onConfirm: () async {
          Get.back();
          debugPrint("Opening location settings...");
          await geo.Geolocator.openLocationSettings();
        },
        onDeny: () {
          debugPrint("Closing location settings dialog...");
          Get.back();
        },
        confirmText: "Open settings",
        denyText: "Cancel",
      );
      state(
        LocationState(
          isLoading: false,
          errorMessage: 'Location services are disabled.',
        ),
      );
      return;
    }

    state(LocationState(isLoading: true));

    try {
      // Check and request location permissions
      var status = await _permissionUtil.isLocationPermissionGranted();
      if (!status) {
        status = await _permissionUtil.requestLocationPermission();
        if (!status) {
          state(
            LocationState(
              isLoading: false,
              errorMessage: 'Location permission denied.',
            ),
          );
          return;
        }
      }

      // Get current position
      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings:
            const geo.LocationSettings(accuracy: geo.LocationAccuracy.high),
      );
      // Update user location in background

      _updateUserLocation(position);

      // Get address
      List<Placemark> placemarks = [];
      try {
        placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
      } catch (e) {
        placemarks = [];
      }

      // Update state with all information
      state(
        LocationState(
          isLoading: false,
          location: Location(
            latitude: position.latitude,
            longitude: position.longitude,
            timestamp: DateTime.now(),
          ),
          errorMessage: "",
          locationName: placemarks.isNotEmpty ? placemarks.first : null,
        ),
      );
      update();
    } catch (e) {
      debugPrint("Location Error: ${e.toString()}");
      state(
        LocationState(
          isLoading: false,
          errorMessage: 'Failed to get location',
        ),
      );
      update();
    }
  }

  init() {
    getLocation(fromInit: true);
  }

  Future<bool> isLocationEnabled() async {
    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled() &&
          await _permissionUtil.isLocationPermissionGranted();
      debugPrint(
          "Location service enabled: $serviceEnabled : ${await geo.Geolocator.isLocationServiceEnabled()} : ${await _permissionUtil.isLocationPermissionGranted()}");
      return serviceEnabled;
    } catch (e) {
      debugPrint("Error checking location service: ${e.toString()}");
      return false;
    }
  }

  // Request permission and fetch the current location
  void showDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    required VoidCallback onDeny,
    required String confirmText,
    required String denyText,
  }) {
    showPicaAlertDialog(
      message: message,
      confirmText: confirmText,
      onConfirm: onConfirm,
      cancelText: "Cancel",
      onCancel: onDeny,
    );
  }

  // Method to update location with new coordinates
  Future<void> updateLocation(
    Location location, {
    bool isUserSelected = false,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      state(
        LocationState(
          isLoading: false,
          location: location,
          locationName: placemarks.isNotEmpty ? placemarks.first : null,
          errorMessage: "",
        ),
      );

      isUserProvidedLocation = isUserSelected;
      update();
    } catch (e) {
      debugPrint("Error updating location: ${e.toString()}");
      state(
        LocationState(
          isLoading: false,
          location: location,
          errorMessage: 'Failed to get address',
        ),
      );
      update();
    }
  }

  // Separate method to update user location
  Future<void> _updateUserLocation(geo.Position position) async {
    if (prevLocation == position) {
      return;
    }

    prevLocation = position;

    if (_isUpdating) {
      return;
    }

    try {
      if (_userController.user == null) {
        return;
      }
      while (_userController.user == null) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      _isUpdating = true;

      var isUpdated = await _userController.updateUser(
        [UserField.location],
        customExecution: (userField) {
          return MapEntry(
            "loc",
            {
              "lat": position.latitude,
              "lng": position.longitude,
            },
          );
        },
      );
      if (isUpdated) {
        debugPrint(
            "Updated user location: ${position.latitude}, ${position.longitude}");
      } else {
        debugPrint("Location is not updated");
      }
    } catch (e) {
      debugPrint("Error updating user location: ${e.toString()}");
    } finally {
      _isUpdating = false;
    }
  }
}

class LocationState {
  final Location? location;
  final bool isLoading;
  final String? errorMessage;
  final Placemark? locationName;

  LocationState({
    this.location,
    this.isLoading = false,
    this.errorMessage,
    this.locationName,
  });

  LocationState copyWith({
    Location? location,
    bool? isLoading,
    String? errorMessage,
    Placemark? locationName,
  }) {
    return LocationState(
      location: location ?? this.location,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      locationName: locationName ?? this.locationName,
    );
  }
}
