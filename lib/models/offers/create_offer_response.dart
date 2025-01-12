// To parse this JSON data, do
//
//     final createOfferResponse = createOfferResponseFromJson(jsonString);

import 'dart:convert';

import 'package:picapool/models/offers/offer_chat_entity.dart';

CreateOfferResponse createOfferResponseFromJson(String str) => CreateOfferResponse.fromJson(json.decode(str));

String createOfferResponseToJson(CreateOfferResponse data) => json.encode(data.toJson());

class CreateOfferResponse {
    bool? success;
    CreatedOffer? data;
    String? message;

    CreateOfferResponse({
        this.success,
        this.data,
        this.message,
    });

    factory CreateOfferResponse.fromJson(Map<String, dynamic> json) => CreateOfferResponse(
        success: json["success"],
        data: json["data"] == null ? null : CreatedOffer.fromJson(json["data"]),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
    };
}

class CreatedOffer {
    int? id;
    String? name;
    int? radius;
    dynamic partnerId;
    int? userId;
    List<String>? images;
    String? desc;
    DateTime? createdAt;
    DateTime? updatedAt;
    DateTime? expiryAt;
    List<OfferChat>? chats;

    CreatedOffer({
        this.id,
        this.name,
        this.radius,
        this.partnerId,
        this.userId,
        this.images,
        this.desc,
        this.createdAt,
        this.updatedAt,
        this.expiryAt,
        this.chats,
    });

    factory CreatedOffer.fromJson(Map<String, dynamic> json) => CreatedOffer(
        id: json["id"],
        name: json["name"],
        radius: json["radius"],
        partnerId: json["partnerId"],
        userId: json["userId"],
        images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
        desc: json["desc"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        expiryAt: json["expiryAt"] == null ? null : DateTime.parse(json["expiryAt"]),
        chats: json["Chats"] == null ? [] : List<OfferChat>.from(json["Chats"]!.map((x) => OfferChat.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "radius": radius,
        "partnerId": partnerId,
        "userId": userId,
        "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
        "desc": desc,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "expiryAt": expiryAt?.toIso8601String(),
        "Chats": chats == null ? [] : List<dynamic>.from(chats!.map((x) => x.toJson())),
    };
}