// import 'package:flutter/material.dart';
// // import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
//     as bg;
// import 'package:geocoding/geocoding.dart';
// import 'package:get/get.dart';

// class LocationService extends GetxService {
//   @override
//   void onInit() {
//     super.onInit();
//     _configureBackgroundGeolocation();
//   }

//   void _configureBackgroundGeolocation() {
//     bg.BackgroundGeolocation.onLocation((bg.Location location) {
//       double lat = location.coords.latitude;
//       double lng = location.coords.longitude;
//       _updateLocation(lat, lng);
//     });

//     bg.BackgroundGeolocation.ready(bg.Config(
//       desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
//       distanceFilter: 10.0,
//       stopOnTerminate: false,
//       startOnBoot: true,
//       enableHeadless: true,
//     )).then((bg.State state) {
//       if (!state.enabled) {
//         bg.BackgroundGeolocation.start();
//       }
//     });
//   }

//   Future<void> _updateLocation(double lat, double lng) async {
//     // Call your method to update the location
//     await getAddressFromLatLng(lat: lat, lng: lng);
//   }

//   Future<void> getAddressFromLatLng(
//       {required double lat, required double lng}) async {
//     List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
//     if (placemarks.isNotEmpty) {
//       Placemark place = placemarks.first;
//       String address =
//           "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";

//       // Update the state with the new location
//       state.value = state.value.copyWith(locationName: address);
//       debugPrint("Added location name");
//     } else {
//       state.value = state.value.copyWith(locationName: "Unknown location");
//     }
//   }
// }
