import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserLocationModel {
  String userId;
  String buildingName;
  String address;
  String type;
  LatLng? latLng;

  UserLocationModel({
    required this.userId,
    required this.buildingName,
    required this.address,
    required this.type,
    required this.latLng,
});

  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    return UserLocationModel(
      userId: json['userId'],
      buildingName: json['buildingName'],
      address: json['address'],
      type: json['type'],
      latLng: json['latLng'] != null
          ? LatLng(
              json['latLng']['latitude'],
              json['latLng']['longitude'],
            )
          : null, // Default value if latLng is null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'buildingName': buildingName,
      'address': address,
      'type': type,
      'latLng': latLng != null
          ? {
              'latitude': latLng!.latitude,
              'longitude': latLng!.longitude,
            }
          : null,
    };
  }


}

extension UserLocationModelExtension on UserLocationModel {
  String get fullAddress => "$buildingName, $address";
}
