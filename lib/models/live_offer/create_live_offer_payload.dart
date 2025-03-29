// To parse this JSON data, do
//
//     final createLiveOfferPayload = createLiveOfferPayloadFromJson(jsonString);

import 'dart:convert';

import 'package:picapool/models/vicinity_offer_model.dart';

CreateLiveOfferPayload createLiveOfferPayloadFromJson(String str) =>
    CreateLiveOfferPayload.fromJson(json.decode(str));

String createLiveOfferPayloadToJson(CreateLiveOfferPayload data) =>
    json.encode(data.toJson());

class CreateLiveOfferPayload {
  final String fromAddress;
  final String toAddress;
  final String createdAt;
  final String expiryAt;
  final int seats;
  final VicinityLocation? from;
  final VicinityLocation? to;

  CreateLiveOfferPayload({
    required this.fromAddress,
    required this.toAddress,
    required this.createdAt,
    required this.expiryAt,
    required this.seats,
    required this.from,
    required this.to,
  });

  factory CreateLiveOfferPayload.fromJson(Map<String, dynamic> json) =>
      CreateLiveOfferPayload(
        fromAddress: json["fromAddress"] as String,
        toAddress: json["toAddress"] as String,
        createdAt: json["createdAt"],
        expiryAt: json["expiryAt"],
        seats: json["seats"] as int,
        from: json['from'] != null
            ? VicinityLocation.fromJson(json['from'])
            : null,
        to: json['to'] != null ? VicinityLocation.fromJson(json['to']) : null,
      );

  Map<String, dynamic> toJson() => {
        "fromAddress": fromAddress,
        "toAddress": toAddress,
        "createdAt": createdAt,
        "expiryAt": expiryAt,
        "seats": seats,
        if (from != null) "from": from?.toJson(),
        if (to != null) "to": to?.toJson()
      };
}
