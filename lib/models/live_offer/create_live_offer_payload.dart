// To parse this JSON data, do
//
//     final createLiveOfferPayload = createLiveOfferPayloadFromJson(jsonString);

import 'dart:convert';

CreateLiveOfferPayload createLiveOfferPayloadFromJson(String str) => CreateLiveOfferPayload.fromJson(json.decode(str));

String createLiveOfferPayloadToJson(CreateLiveOfferPayload data) => json.encode(data.toJson());

class CreateLiveOfferPayload {
    final String fromAddress;
    final String toAddress;
    final DateTime createdAt;
    final DateTime expiryAt;
    final int seats;

    CreateLiveOfferPayload({
        required this.fromAddress,
        required this.toAddress,
        required this.createdAt,
        required this.expiryAt,
        required this.seats,
    });

    factory CreateLiveOfferPayload.fromJson(Map<String, dynamic> json) => CreateLiveOfferPayload(
        fromAddress: json["fromAddress"] as String,
        toAddress: json["toAddress"] as String,
        createdAt: DateTime.parse(json["createdAt"]),
        expiryAt: DateTime.parse(json["expiryAt"]),
        seats: json["seats"] as int,
    );

    Map<String, dynamic> toJson() => {
        "fromAddress": fromAddress,
        "toAddress": toAddress,
        "createdAt": createdAt.toLocal().toIso8601String(),
        "expiryAt": expiryAt.toLocal().toIso8601String(),
        "seats": seats,
    };
}
