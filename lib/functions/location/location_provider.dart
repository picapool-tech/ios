import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import 'package:picapool/functions/user/user_controller.dart';
import 'package:picapool/utils/permission_util.dart';

class LocationController extends GetxController {
  Rx<LocationState> state = LocationState().obs;
  final UserController _userController = Get.find<UserController>();
  final PermissionUtil _permissionUtil = PermissionUtil();

  // Request permission and fetch the current location
  Future<void> getLocation() async {
    if (state.value.isLoading) {
      return;
    }
    state(LocationState(isLoading: true));

    try {
      // Check if location services are enabled
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state(
          LocationState(
            isLoading: false,
            errorMessage: 'Location services are disabled.',
          ),
        );
        return;
      }

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
        desiredAccuracy: geo.LocationAccuracy.high,
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

  Future<bool> isLocationEnabled() async {
    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled() &&
          await _permissionUtil.isLocationPermissionGranted();
      debugPrint("Location service enabled: $serviceEnabled");
      return serviceEnabled;
    } catch (e) {
      debugPrint("Error checking location service: ${e.toString()}");
      return false;
    }
  }

  // Method to update location with new coordinates
  Future<void> updateLocation(Location location) async {
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
    try {
      if (_userController.user.value == null) {
        return;
      }
      await _userController.updateUser({
        "loc": {"lat": position.latitude, "lng": position.longitude}
      });
      debugPrint(
          "Updated user location: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      debugPrint("Error updating user location: ${e.toString()}");
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
