// To parse this JSON data, do
//
//     final createLiveOfferPayload = createLiveOfferPayloadFromJson(jsonString);

import 'dart:convert';

CreateLiveOfferPayload createLiveOfferPayloadFromJson(String str) => CreateLiveOfferPayload.fromJson(json.decode(str));

String createLiveOfferPayloadToJson(CreateLiveOfferPayload data) => json.encode(data.toJson());

class CreateLiveOfferPayload {
    LiveOffer? liveOffer;
    LocationData? locationData;

    CreateLiveOfferPayload({
        this.liveOffer,
        this.locationData,
    });

    factory CreateLiveOfferPayload.fromJson(Map<String, dynamic> json) => CreateLiveOfferPayload(
        liveOffer: json["liveOffer"] == null ? null : LiveOffer.fromJson(json["liveOffer"]),
        locationData: json["locationData"] == null ? null : LocationData.fromJson(json["locationData"]),
    );

    Map<String, dynamic> toJson() => {
        "liveOffer": liveOffer?.toJson(),
        "locationData": locationData?.toJson(),
    };
}

class LiveOffer {
    DateTime? expiryAt;
    int? seats;
    int? livePartnerId;

    LiveOffer({
        this.expiryAt,
        this.seats,
        this.livePartnerId,
    });

    factory LiveOffer.fromJson(Map<String, dynamic> json) => LiveOffer(
        expiryAt: json["expiryAt"] == null ? null : DateTime.parse(json["expiryAt"]),
        seats: json["seats"],
        livePartnerId: json["livePartnerId"],
    );

    Map<String, dynamic> toJson() => {
        "expiryAt": expiryAt?.toIso8601String(),
        "seats": seats,
        "livePartnerId": livePartnerId,
    };
}

class LocationData {
    From? from;
    From? to;

    LocationData({
        this.from,
        this.to,
    });

    factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
        from: json["from"] == null ? null : From.fromJson(json["from"]),
        to: json["to"] == null ? null : From.fromJson(json["to"]),
    );

    Map<String, dynamic> toJson() => {
        "from": from?.toJson(),
        "to": to?.toJson(),
    };
}

class From {
    int? latitude;
    int? longitude;

    From({
        this.latitude,
        this.longitude,
    });

    factory From.fromJson(Map<String, dynamic> json) => From(
        latitude: json["latitude"],
        longitude: json["longitude"],
    );

    Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
    };
}
