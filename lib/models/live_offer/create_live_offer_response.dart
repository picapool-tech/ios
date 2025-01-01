// To parse this JSON data, do
//
//     final createLiveOfferResponse = createLiveOfferResponseFromJson(jsonString);

import 'dart:convert';

CreateLiveOfferResponse createLiveOfferResponseFromJson(String str) => CreateLiveOfferResponse.fromJson(json.decode(str));

String createLiveOfferResponseToJson(CreateLiveOfferResponse data) => json.encode(data.toJson());

class CreateLiveOfferResponse {
    bool? success;
    LiveOffer? data;
    String? message;

    CreateLiveOfferResponse({
        this.success,
        this.data,
        this.message,
    });

    factory CreateLiveOfferResponse.fromJson(Map<String, dynamic> json) => CreateLiveOfferResponse(
        success: json["success"],
        data: json["data"] == null ? null : LiveOffer.fromJson(json["data"]),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
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
    int? chatId;

    LiveOffer({
        this.id,
        this.createdAt,
        this.updatedAt,
        this.expiryAt,
        this.seats,
        this.userId,
        this.livePartnerId,
        this.chatId,
    });

    factory LiveOffer.fromJson(Map<String, dynamic> json) => LiveOffer(
        id: json["id"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        expiryAt: json["expiryAt"] == null ? null : DateTime.parse(json["expiryAt"]),
        seats: json["seats"],
        userId: json["userId"],
        livePartnerId: json["livePartnerId"],
        chatId: json["chatId"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "expiryAt": expiryAt?.toIso8601String(),
        "seats": seats,
        "userId": userId,
        "livePartnerId": livePartnerId,
        "chatId": chatId,
    };
}
