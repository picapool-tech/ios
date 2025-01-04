// To parse this JSON data, do
//
//     final createProductResponse = createProductResponseFromJson(jsonString);

import 'dart:convert';

import 'package:picapool/services/products/entities/product_entity.dart';

CreateProductResponse createProductResponseFromJson(String str) => CreateProductResponse.fromJson(json.decode(str));

String createProductResponseToJson(CreateProductResponse data) => json.encode(data.toJson());

class CreateProductResponse {
    bool? success;
    ProductData? data;
    String? message;

    CreateProductResponse({
        this.success,
        this.data,
        this.message,
    });

    factory CreateProductResponse.fromJson(Map<String, dynamic> json) => CreateProductResponse(
        success: json["success"],
        data: json["data"] == null ? null : ProductData.fromJson(json["data"]),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
    };
}

