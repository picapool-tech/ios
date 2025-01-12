// To parse this JSON data, do
//
//     final searchOffersResponse = searchOffersResponseFromJson(jsonString);

import 'dart:convert';

import 'package:picapool/models/offers/offer_chat_entity.dart';

SearchOffersResponse searchOffersResponseFromJson(String str) => SearchOffersResponse.fromJson(json.decode(str));

String searchOffersResponseToJson(SearchOffersResponse data) => json.encode(data.toJson());

class SearchOffersResponse {
    bool? success;
    List<SearchedOffer>? data;
    String? message;

    SearchOffersResponse({
        this.success,
        this.data,
        this.message,
    });

    factory SearchOffersResponse.fromJson(Map<String, dynamic> json) => SearchOffersResponse(
        success: json["success"],
        data: json["data"] == null ? [] : List<SearchedOffer>.from(json["data"]!.map((x) => SearchedOffer.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
    };
}

class SearchedOffer {
    int? id;
    String? name;
    dynamic radius;
    dynamic partnerId;
    int? userId;
    List<String>? images;
    String? desc;
    DateTime? createdAt;
    DateTime? updatedAt;
    DateTime? expiryAt;
    List<OfferChat>? chats;
    List<SearchedProduct>? products;

    SearchedOffer({
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
        this.products,
    });

    factory SearchedOffer.fromJson(Map<String, dynamic> json) => SearchedOffer(
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
        products: json["Products"] == null ? [] : List<SearchedProduct>.from(json["Products"]!.map((x) => SearchedProduct.fromJson(x))),
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
        "Products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
    };
}

class SearchedProduct {
    int? id;
    String? name;
    List<String>? images;
    String? description;
    int? mrp;
    int? offerPrice;
    String? email;
    String? phone;
    Map<String, String?>? attributes;
    DateTime? createdAt;
    DateTime? updatedAt;
    dynamic partnerId;
    int? userId;

    SearchedProduct({
        this.id,
        this.name,
        this.images,
        this.description,
        this.mrp,
        this.offerPrice,
        this.email,
        this.phone,
        this.attributes,
        this.createdAt,
        this.updatedAt,
        this.partnerId,
        this.userId,
    });

    factory SearchedProduct.fromJson(Map<String, dynamic> json) => SearchedProduct(
        id: json["id"],
        name: json["name"],
        images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
        description: json["description"],
        mrp: json["mrp"],
        offerPrice: json["offerPrice"],
        email: json["email"],
        phone: json["phone"],
        attributes: Map.from(json["attributes"]!).map((k, v) => MapEntry<String, String?>(k, v)),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        partnerId: json["partnerId"],
        userId: json["userId"],
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
        "attributes": Map.from(attributes!).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "partnerId": partnerId,
        "userId": userId,
    };
}
