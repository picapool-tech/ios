// To parse this JSON data, do
//
//     final updateProductResponse = updateProductResponseFromJson(jsonString);

import 'dart:convert';

import 'package:picapool/services/products/entities/product_entity.dart';

UpdateProductResponse updateProductResponseFromJson(String str) => UpdateProductResponse.fromJson(json.decode(str));

String updateProductResponseToJson(UpdateProductResponse data) => json.encode(data.toJson());

class UpdateProductResponse {
    bool? success;
    ProductData? data;
    String? message;

    UpdateProductResponse({
        this.success,
        this.data,
        this.message,
    });

    factory UpdateProductResponse.fromJson(Map<String, dynamic> json) => UpdateProductResponse(
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
