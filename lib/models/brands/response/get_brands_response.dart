// To parse this JSON data, do
//
//     final getBrandsResposne = getBrandsResposneFromJson(jsonString);

import 'dart:convert';

import 'package:picapool/models/brands/entities/brand_entity.dart';

GetBrandsResposne getBrandsResposneFromJson(String str) => GetBrandsResposne.fromJson(json.decode(str));

String getBrandsResposneToJson(GetBrandsResposne data) => json.encode(data.toJson());

class GetBrandsResposne {
    bool? success;
    List<Brand>? data;
    String? message;

    GetBrandsResposne({
        this.success,
        this.data,
        this.message,
    });

    factory GetBrandsResposne.fromJson(Map<String, dynamic> json) => GetBrandsResposne(
        success: json["success"],
        data: json["data"] == null ? [] : List<Brand>.from(json["data"]!.map((x) => Brand.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
    };
}
