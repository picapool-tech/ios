// To parse this JSON data, do
//
//     final getAllLiveOffersResponse = getAllLiveOffersResponseFromJson(jsonString);

import 'dart:convert';

import 'package:picapool/models/live_offer/live_offer_entity.dart';

GetAllLiveOffersResponse getAllLiveOffersResponseFromJson(String str) => GetAllLiveOffersResponse.fromJson(json.decode(str));

String getAllLiveOffersResponseToJson(GetAllLiveOffersResponse data) => json.encode(data.toJson());

class GetAllLiveOffersResponse {
    bool? success;
    List<LiveOffer>? data;
    String? message;

    GetAllLiveOffersResponse({
        this.success,
        this.data,
        this.message,
    });

    factory GetAllLiveOffersResponse.fromJson(Map<String, dynamic> json) => GetAllLiveOffersResponse(
        success: json["success"],
        data: json["data"] == null ? [] : List<LiveOffer>.from(json["data"]!.map((x) => LiveOffer.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
    };
}