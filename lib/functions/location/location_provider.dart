import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/user/user_controller.dart';

class LocationState {
  final Location? location;
  final bool isLoading;
  final String? errorMessage;
  final String? locationName;

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
    String? locationName,
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
  // Reactive state variable
  Rx<LocationState> state = LocationState().obs;
  final UserController _userController = Get.find<UserController>();

  // Request permission and fetch the current location
  Future<void> getLocation() async {
    state.value = state.value.copyWith(isLoading: true);

    bool serviceEnabled;
    geo.LocationPermission permission;

    try {
      // Check if location services are enabled
      serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("Location Service is disabled");
        state.value = state.value.copyWith(
          isLoading: false,
          errorMessage: 'Location services are disabled.',
        );
      }

      // Check and request location permissions
      permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          debugPrint("Location permission not granted");
          state.value = state.value.copyWith(
            isLoading: false,
            errorMessage: 'Location permission not granted.',
          );
          return;
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        debugPrint("Location permission permanently denied");

        state.value = state.value.copyWith(
          isLoading: false,
          errorMessage:
              'Location permissions are permanently denied, we cannot request permissions.',
        );
        Get.dialog(
          AlertDialog.adaptive(
            title: const Text("Location Permission"),
            content: const Text(
              "Location permissions are permanently denied, we cannot request permissions.\nClick on 'Go to Settings' to enable location permissions.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
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

      // Get the current location
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      try {
        await _userController.updateUser(
          {
            "loc": {"lat": position.latitude, "lng": position.longitude}
          },
        );
        debugPrint(
            "Updated user location {lat: ${position.latitude}, long: ${position.longitude}}");
      } catch (e) {
        debugPrint("UPDATING USER LOCATION ERROR : ${e.toString()}");
      }

      debugPrint("Location: ${position.latitude}, ${position.longitude}");

      // Get address from lat and lng
      await getAddressFromLatLng(
        lat: position.latitude,
        lng: position.longitude,
      );

      // Print the location for debugging
      debugPrint("Location: ${position.latitude}, ${position.longitude}");

      // Update state with location and timestamp
      state.value = state.value.copyWith(
        location: Location(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now(),
        ),
        isLoading: false,
      );
    } catch (e) {
      // Handle any errors
      debugPrint("USER LOCATION FETCH ERROR: ${e.toString()}");
      state.value = state.value.copyWith(
        isLoading: false,
        errorMessage: 'Failed to get location: ${e.toString()}',
      );
    }
  }

  Future<void> getAddressFromLatLng({
    required double lat,
    required double lng,
  }) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address =
            "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";

        state.value = state.value.copyWith(locationName: address);
        debugPrint("Added location name");
      } else {
        state.value = state.value.copyWith(locationName: "Unknown location");
      }
    } catch (e) {
      debugPrint(e.toString());
      state.value = state.value.copyWith(
        locationName: "Failed to get address: ${e.toString()}",
      );
    }
  }

  Future<void> updateLocation(Location location) async {
    state.value = state.value.copyWith(location: location);
    await getAddressFromLatLng(
      lat: location.latitude,
      lng: location.longitude,
    );
  }
}
