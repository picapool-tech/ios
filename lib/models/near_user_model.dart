import 'package:geocoding/geocoding.dart';

class NearUserModel {
  final String username;

  final Location location;

  NearUserModel({
    required this.username,
    required this.location,
  });

  factory NearUserModel.fromJson(Map<String, dynamic> json) {
    return NearUserModel(
      username: json['username'],
      location: Location(
        latitude: json['lat'],
        longitude: json['lng'],
        timestamp: DateTime.timestamp(),
      ),
    );
  }
}
