// To parse this JSON data, do
//
//     final getSingleProductResponse = getSingleProductResponseFromJson(jsonString);

import 'dart:convert';

import 'package:picapool/services/products/entities/product_entity.dart';

GetSingleProductResponse getSingleProductResponseFromJson(String str) => GetSingleProductResponse.fromJson(json.decode(str));

String getSingleProductResponseToJson(GetSingleProductResponse data) => json.encode(data.toJson());

class GetSingleProductResponse {
    bool? success;
    ProductData? data;
    String? message;

    GetSingleProductResponse({
        this.success,
        this.data,
        this.message,
    });

    factory GetSingleProductResponse.fromJson(Map<String, dynamic> json) => GetSingleProductResponse(
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
