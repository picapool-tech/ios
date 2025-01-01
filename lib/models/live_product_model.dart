import 'package:picapool/models/auth_model.dart';
import 'package:picapool/models/live_offer/create_live_offer_payload.dart';
import 'package:picapool/models/vehicle_model.dart';

class LivePartner {
  final int id;
  final String? name;
  final String? pic;
  final String? location;
  final String? fcmToken;
  final Auth? auth;
  final int? authId;
  final Vehicle? vehicle;
  final int? vehicleId;
  final List<LiveOffer>? liveOffers;

  LivePartner({
    required this.id,
    this.name,
    this.pic,
    this.location,
    this.fcmToken,
    this.auth,
    this.authId,
    this.vehicle,
    this.vehicleId,
    this.liveOffers,
  });

  factory LivePartner.fromJson(Map<String, dynamic> json) {
    return LivePartner(
      id: json['id'],
      name: json['name'],
      pic: json['pic'],
      location: json['location'],
      fcmToken: json['fcmToken'],
      auth: json['auth'] != null ? Auth.fromJson(json['auth']) : null,
      authId: json['authId'],
      vehicle:
          json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
      vehicleId: json['vehicleId'],
      liveOffers: json['liveOffers'] != null
          ? (json['liveOffers'] as List)
              .map((lo) => LiveOffer.fromJson(lo))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pic': pic,
      'location': location,
      'fcmToken': fcmToken,
      'auth': auth?.toJson(),
      'authId': authId,
      'vehicle': vehicle?.toJson(),
      'vehicleId': vehicleId,
      'liveOffers': liveOffers?.map((lo) => lo.toJson()).toList(),
    };
  }
}
