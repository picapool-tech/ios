// To parse this JSON data, do
//
//     final getLiveOfferResponse = getLiveOfferResponseFromJson(jsonString);

import 'dart:convert';

import 'package:picapool/models/live_offer/live_offer_entity.dart';

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