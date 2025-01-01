// To parse this JSON data, do
//
//     final getLiveOfferResponse = getLiveOfferResponseFromJson(jsonString);

import 'dart:convert';

GetLiveOfferResponse getLiveOfferResponseFromJson(String str) => GetLiveOfferResponse.fromJson(json.decode(str));

String getLiveOfferResponseToJson(GetLiveOfferResponse data) => json.encode(data.toJson());

class GetLiveOfferResponse {
    bool? success;
    LiveOffer? liveOffer;
    String? message;

    GetLiveOfferResponse({
        this.success,
        this.liveOffer,
        this.message,
    });

    factory GetLiveOfferResponse.fromJson(Map<String, dynamic> json) => GetLiveOfferResponse(
        success: json["success"],
        liveOffer: json["data"] == null ? null : LiveOffer.fromJson(json["data"]),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": liveOffer?.toJson(),
        "message": message,
    };
}

class LiveOffer {
    int? id;
    DateTime? createdAt;
    DateTime? updatedAt;
    DateTime? expiryAt;
    int? seats;
    dynamic userId;
    int? livePartnerId;

    LiveOffer({
        this.id,
        this.createdAt,
        this.updatedAt,
        this.expiryAt,
        this.seats,
        this.userId,
        this.livePartnerId,
    });

    factory LiveOffer.fromJson(Map<String, dynamic> json) => LiveOffer(
        id: json["id"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        expiryAt: json["expiryAt"] == null ? null : DateTime.parse(json["expiryAt"]),
        seats: json["seats"],
        userId: json["userId"],
        livePartnerId: json["livePartnerId"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "expiryAt": expiryAt?.toIso8601String(),
        "seats": seats,
        "userId": userId,
        "livePartnerId": livePartnerId,
    };
}
