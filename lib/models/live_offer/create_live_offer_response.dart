// To parse this JSON data, do
//
//     final createLiveOfferResponse = createLiveOfferResponseFromJson(jsonString);

import 'dart:convert';

import 'package:picapool/models/chat_model.dart';

CreateLiveOfferResponse createLiveOfferResponseFromJson(String str) => CreateLiveOfferResponse.fromJson(json.decode(str));

String createLiveOfferResponseToJson(CreateLiveOfferResponse data) => json.encode(data.toJson());

class CreateLiveOfferResponse {
    bool? success;
    CreatedLiveOffer? data;
    String? message;

    CreateLiveOfferResponse({
        this.success,
        this.data,
        this.message,
    });

    factory CreateLiveOfferResponse.fromJson(Map<String, dynamic> json) => CreateLiveOfferResponse(
        success: json["success"],
        data: json["data"] == null ? null : CreatedLiveOffer.fromJson(json["data"]),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
    };
}

class CreatedLiveOffer {
    int? id;
    String? fromAddress;
    String? toAddress;
    DateTime? createdAt;
    DateTime? updatedAt;
    DateTime? expiryAt;
    int? seats;
    dynamic userId;
    dynamic livePartnerId;
    List<Chat>? chats;

    CreatedLiveOffer({
        this.id,
        this.fromAddress,
        this.toAddress,
        this.createdAt,
        this.updatedAt,
        this.expiryAt,
        this.seats,
        this.userId,
        this.livePartnerId,
        this.chats,
    });

    factory CreatedLiveOffer.fromJson(Map<String, dynamic> json) => CreatedLiveOffer(
        id: json["id"],
        fromAddress: json["fromAddress"],
        toAddress: json["toAddress"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        expiryAt: json["expiryAt"] == null ? null : DateTime.parse(json["expiryAt"]),
        seats: json["seats"],
        userId: json["userId"],
        livePartnerId: json["livePartnerId"],
        chats: json["Chats"] == null ? [] : List<Chat>.from(json["Chats"]!.map((x) => Chat.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "fromAddress": fromAddress,
        "toAddress": toAddress,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "expiryAt": expiryAt?.toIso8601String(),
        "seats": seats,
        "userId": userId,
        "livePartnerId": livePartnerId,
        "Chats": chats == null ? [] : List<dynamic>.from(chats!.map((x) => x.toJson())),
    };
}

// class Chat {
//     int? id;
//     bool? isMain;

//     Chat({
//         this.id,
//         this.isMain,
//     });

//     factory Chat.fromJson(Map<String, dynamic> json) => Chat(
//         id: json["id"],
//         isMain: json["isMain"],
//     );

//     Map<String, dynamic> toJson() => {
//         "id": id,
//         "isMain": isMain,
//     };
// }
