// To parse this JSON data, do
//
//     final createProductPayload = createProductPayloadFromJson(jsonString);

import 'dart:convert';

import 'package:picapool/services/products/entities/product_attributes_entity.dart';

CreateProductPayload createProductPayloadFromJson(String str) =>
    CreateProductPayload.fromJson(json.decode(str));

String createProductPayloadToJson(CreateProductPayload data) =>
    json.encode(data.toJson());

class CreateProductPayload {
  String? name;
  List<String>? images;
  String? description;
  int? mrp;
  int? offerPrice;
  String? email;
  String? phone;
  Attributes? attributes;
  int? userId;
  List<int>? offerIds;
  int? price;

  CreateProductPayload({
    this.name,
    this.images,
    this.description,
    this.mrp,
    this.offerPrice,
    this.email,
    this.phone,
    this.attributes,
    this.userId,
    this.offerIds,
    this.price,
  });

  factory CreateProductPayload.fromJson(Map<String, dynamic> json) =>
      CreateProductPayload(
        name: json["name"],
        images: json["images"] == null
            ? []
            : List<String>.from(json["images"]!.map((x) => x)),
        description: json["description"],
        mrp: json["mrp"],
        offerPrice: json["offerPrice"],
        price: json["price"],
        email: json["email"],
        phone: json["phone"],
        attributes: json["attributes"] == null
            ? null
            : Attributes.fromJson(json["attributes"]),
        userId: json["userId"],
        offerIds: json["offerIds"] == null
            ? []
            : List<int>.from(json["offerIds"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "images":
            images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
        "description": description,
        "mrp": mrp,
        "offerPrice": offerPrice,
        "email": email,
        "phone": phone,
        "attributes": attributes?.toJson(),
        "userId": userId,
        "offerIds":
            offerIds == null ? [] : List<dynamic>.from(offerIds!.map((x) => x)),
        "price": price,
      };
}
