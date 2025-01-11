// To parse this JSON data, do
//
//     final searchCabsPayload = searchCabsPayloadFromJson(jsonString);

import 'dart:convert';

SearchCabsPayload searchCabsPayloadFromJson(String str) => SearchCabsPayload.fromJson(json.decode(str));

String searchCabsPayloadToJson(SearchCabsPayload data) => json.encode(data.toJson());

class SearchCabsPayload {
    String? startTime;
    int? radius;
    From? from;

    SearchCabsPayload({
        this.startTime,
        this.radius,
        this.from,
    });

    factory SearchCabsPayload.fromJson(Map<String, dynamic> json) => SearchCabsPayload(
        startTime: json["startTime"],
        radius: json["radius"],
        from: json["from"] == null ? null : From.fromJson(json["from"]),
    );

    Map<String, dynamic> toJson() => {
        "startTime": startTime,
        "radius": radius,
        "from": from?.toJson(),
    };
}

class From {
    double? lat;
    double? lng;

    From({
        this.lat,
        this.lng,
    });

    factory From.fromJson(Map<String, dynamic> json) => From(
        lat: json["lat"]?.toDouble(),
        lng: json["lng"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
    };
}
