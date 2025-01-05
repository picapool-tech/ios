import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';
import 'package:picapool/functions/user/user_controller.dart';

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

class LocationController extends GetxController {
  Rx<LocationState> state = LocationState().obs;
  final UserController _userController = Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    // Initialize location on controller init
    getLocation();
  }

  // Request permission and fetch the current location
  Future<void> getLocation() async {
    // TODO: Set loading state before async operations
    state(LocationState(isLoading: true));

    try {
      // Check if location services are enabled
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state(LocationState(
          isLoading: false,
          errorMessage: 'Location services are disabled.',
        ));
        return;
      }

      // Check and request location permissions
      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          state(LocationState(
            isLoading: false,
            errorMessage: 'Location permission not granted.',
          ));
          return;
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        state(LocationState(
          isLoading: false,
          errorMessage: 'Location permissions are permanently denied.',
        ));
        
        Get.dialog(
          AlertDialog(
            title: const Text("Location Permission"),
            content: const Text(
              "Location permissions are permanently denied. Please enable them in settings.",
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
        return;
      }

      // Get current position
      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      // Update user location in background
      _updateUserLocation(position);

      // Get address
      final placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );

      // Update state with all information
      state(LocationState(
        isLoading: false,
        location: Location(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now(),
        ),
        locationName: placemarks.isNotEmpty ? placemarks.first : null,
      ));

    } catch (e) {
      debugPrint("Location Error: ${e.toString()}");
      state(LocationState(
        isLoading: false,
        errorMessage: 'Failed to get location',
      ));
    }
  }

  // Separate method to update user location
  Future<void> _updateUserLocation(geo.Position position) async {
    try {
      await _userController.updateUser({
        "loc": {
          "lat": position.latitude,
          "lng": position.longitude
        }
      });
      debugPrint("Updated user location: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      debugPrint("Error updating user location: ${e.toString()}");
    }
  }

  // Method to update location with new coordinates
  Future<void> updateLocation(Location location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      
      state(LocationState(
        location: location,
        locationName: placemarks.isNotEmpty ? placemarks.first : null,
      ));
    } catch (e) {
      debugPrint("Error updating location: ${e.toString()}");
      state(LocationState(
        location: location,
        errorMessage: 'Failed to get address',
      ));
    }
  }
}
