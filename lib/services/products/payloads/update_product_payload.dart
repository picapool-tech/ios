// To parse this JSON data, do
//
//     final updateProductPayload = updateProductPayloadFromJson(jsonString);

import 'dart:convert';

import 'package:picapool/services/products/entities/product_attributes_entity.dart';

UpdateProductPayload updateProductPayloadFromJson(String str) => UpdateProductPayload.fromJson(json.decode(str));

String updateProductPayloadToJson(UpdateProductPayload data) => json.encode(data.toJson());

class UpdateProductPayload {
    int? id;
    String? name;
    List<String>? images;
    String? description;
    int? mrp;
    int? offerPrice;
    String? email;
    String? phone;
    Attributes? attributes;
    int? partnerId;
    int? userId;
    List<int>? offerIds;

    UpdateProductPayload({
        this.id,
        this.name,
        this.images,
        this.description,
        this.mrp,
        this.offerPrice,
        this.email,
        this.phone,
        this.attributes,
        this.partnerId,
        this.userId,
        this.offerIds,
    });

    factory UpdateProductPayload.fromJson(Map<String, dynamic> json) => UpdateProductPayload(
        id: json["id"],
        name: json["name"],
        images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
        description: json["description"],
        mrp: json["mrp"],
        offerPrice: json["offerPrice"],
        email: json["email"],
        phone: json["phone"],
        attributes: json["attributes"] == null ? null : Attributes.fromJson(json["attributes"]),
        partnerId: json["partnerId"],
        userId: json["userId"],
        offerIds: json["offerIds"] == null ? [] : List<int>.from(json["offerIds"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
        "description": description,
        "mrp": mrp,
        "offerPrice": offerPrice,
        "email": email,
        "phone": phone,
        "attributes": attributes?.toJson(),
        "partnerId": partnerId,
        "userId": userId,
        "offerIds": offerIds == null ? [] : List<dynamic>.from(offerIds!.map((x) => x)),
    };
}
