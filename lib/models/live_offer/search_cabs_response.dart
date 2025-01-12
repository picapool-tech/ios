// To parse this JSON data, do
//
//     final searchCabsResponse = searchCabsResponseFromJson(jsonString);

import 'dart:convert';

List<SearchCabsResponse> searchCabsResponseFromJson(String str) => List<SearchCabsResponse>.from(json.decode(str).map((x) => SearchCabsResponse.fromJson(x)));

String searchCabsResponseToJson(List<SearchCabsResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SearchCabsResponse {
    int? id;
    String? fromAddress;
    String? toAddress;
    DateTime? expiryAt;
    int? seats;
    dynamic userId;
    dynamic livePartnerId;

    SearchCabsResponse({
        this.id,
        this.fromAddress,
        this.toAddress,
        this.expiryAt,
        this.seats,
        this.userId,
        this.livePartnerId,
    });

    factory SearchCabsResponse.fromJson(Map<String, dynamic> json) => SearchCabsResponse(
        id: json["id"],
        fromAddress: json["fromAddress"],
        toAddress: json["toAddress"],
        expiryAt: json["expiryAt"] == null ? null : DateTime.parse(json["expiryAt"]),
        seats: json["seats"],
        userId: json["userId"],
        livePartnerId: json["livePartnerId"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "fromAddress": fromAddress,
        "toAddress": toAddress,
        "expiryAt": expiryAt?.toIso8601String(),
        "seats": seats,
        "userId": userId,
        "livePartnerId": livePartnerId,
    };
}
