// To parse this JSON data, do
//
//     final createOfferPayload = createOfferPayloadFromJson(jsonString);

import 'dart:convert';

import 'package:picapool/models/offers/location_entity.dart';

CreateOfferPayload createOfferPayloadFromJson(String str) => CreateOfferPayload.fromJson(json.decode(str));

String createOfferPayloadToJson(CreateOfferPayload data) => json.encode(data.toJson());

class CreateOfferPayload {
    String? name;
    List<String>? images;
    String? desc;
    String? expiryAt;
    // int? partnerId;
    int? userId;
    List<int>? productIds;
    List<int>? tagIds;
    Loc? loc;
    int? dist;

    CreateOfferPayload({
        this.name,
        this.images,
        this.desc,
        this.expiryAt,
        // this.partnerId,
        this.userId,
        this.productIds,
        this.tagIds,
        this.loc,
        this.dist,
    });

    factory CreateOfferPayload.fromJson(Map<String, dynamic> json) => CreateOfferPayload(
        name: json["name"],
        images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
        desc: json["desc"],
        expiryAt: json["expiryAt"] == null ? null : json["expiryAt"],
        // partnerId: json["partnerId"],
        userId: json["userId"],
        productIds: json["productIds"] == null ? [] : List<int>.from(json["productIds"]!.map((x) => x)),
        tagIds: json["tagIds"] == null ? [] : List<int>.from(json["tagIds"]!.map((x) => x)),
        loc: json["loc"] == null ? null : Loc.fromJson(json["loc"]),
        dist: json["dist"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
        "desc": desc,
        "expiryAt": expiryAt,
        // "partnerId": partnerId,
        "userId": userId,
        "productIds": productIds == null ? [] : List<dynamic>.from(productIds!.map((x) => x)),
        "tagIds": tagIds == null ? [] : List<dynamic>.from(tagIds!.map((x) => x)),
        "loc": loc?.toJson(),
        "dist": dist,
    };
}


