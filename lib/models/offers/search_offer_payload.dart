// To parse this JSON data, do
//
//     final searchOfferPayload = searchOfferPayloadFromJson(jsonString);

import 'dart:convert';

SearchOfferPayload searchOfferPayloadFromJson(String str) => SearchOfferPayload.fromJson(json.decode(str));

String searchOfferPayloadToJson(SearchOfferPayload data) => json.encode(data.toJson());

class SearchOfferPayload {
    Loc? loc;
    int? radius;
    bool? chats;
    bool? products;

    SearchOfferPayload({
        this.loc,
        this.radius,
        this.chats,
        this.products,
    });

    factory SearchOfferPayload.fromJson(Map<String, dynamic> json) => SearchOfferPayload(
        loc: json["loc"] == null ? null : Loc.fromJson(json["loc"]),
        radius: json["radius"],
        chats: json["chats"],
        products: json["products"],
    );

    Map<String, dynamic> toJson() => {
        "loc": loc?.toJson(),
        "radius": radius,
        "chats": chats,
        "products": products,
    };
}

class Loc {
    double? lat;
    double? lng;

    Loc({
        this.lat,
        this.lng,
    });

    factory Loc.fromJson(Map<String, dynamic> json) => Loc(
        lat: json["lat"]?.toDouble(),
        lng: json["lng"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
    };
}
