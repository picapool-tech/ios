// To parse this JSON data, do
//
//     final getAllProductResponse = getAllProductResponseFromJson(jsonString);

import 'dart:convert';

import 'package:picapool/services/products/entities/product_entity.dart';

GetAllProductResponse getAllProductResponseFromJson(String str) => GetAllProductResponse.fromJson(json.decode(str));

String getAllProductResponseToJson(GetAllProductResponse data) => json.encode(data.toJson());

class GetAllProductResponse {
    bool? success;
    List<ProductData>? data;
    String? message;

    GetAllProductResponse({
        this.success,
        this.data,
        this.message,
    });

    factory GetAllProductResponse.fromJson(Map<String, dynamic> json) => GetAllProductResponse(
        success: json["success"],
        data: json["data"] == null ? [] : List<ProductData>.from(json["data"]!.map((x) => ProductData.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
    };
}