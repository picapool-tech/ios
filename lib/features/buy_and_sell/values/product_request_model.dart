import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picapool/features/buy_and_sell/values/common_details_model.dart';

class ProductRequestModel {
  final String name;
  final List<String> images;
  List<XFile> imagesFile;
  final String description;
  final double? mrp;
  final double offerPrice;
  final double? price;
  final String email;
  final String phone;
  final Map<String, dynamic> attributes;
  final int? partnerId;
  final int userId;
  final List<int> offerIds;
  final int stocks;

  ProductRequestModel({
    required this.name,
    required this.images,
    required this.description,
    this.mrp,
    required this.offerPrice,
    required this.email,
    required this.phone,
    required this.attributes,
    required this.price,
    this.partnerId,
    required this.userId,
    required this.offerIds,
    this.imagesFile = const [],
    this.stocks = 1,
  });

  factory ProductRequestModel.fromJson(Map<String, dynamic> json) {
    debugPrint("PRODUCT REQUEST MODEL : $json");
    return ProductRequestModel(
      name: json['name'] as String,
      images: List<String>.from(json['images']),
      description: json['description'] as String,
      offerPrice: double.parse(json['offerPrice']),
      email: json['email'] as String,
      phone: json['phone'] as String,
      attributes: json['attributes'] as Map<String, dynamic>,
      partnerId: json['partnerId'] as int?,
      userId: json['userId'] as int,
      offerIds: List<int>.from(json['offerIds'] ?? []),
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : null,
      stocks: json['stock'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'images': images,
      'description': description,
      'offerPrice': offerPrice,
      'email': email,
      'phone': phone,
      'attributes': attributes,
      if (partnerId != null) 'partnerId': partnerId,
      'userId': userId,
      'offerIds': offerIds,
      'price': price,
      'stock': stocks,
    };
  }

  Map<String, dynamic> toNewJson() {
    return {
      'name': name,
      'images': images,
      'description': description,
      'email': email,
      'phone': phone,
      'attributes': attributes,
      if (partnerId != null) 'partnerId': partnerId,
      'userId': userId,
      'offerIds': offerIds,
      'price': price,
      'stock': stocks,
    };
  }

  static ProductRequestModel getWithCommondDetails(
    CommonDetailsModel commonDetails, {
    required String name,
    required String description,
    required int userId,
    required List<int> offerIds,
    required String category,
  }) {
    var model = {
      'name': name,
      'description': description,
      'userId': userId,
      'offerIds': offerIds,
      ...commonDetails.toJsonRequired(),
      'attributes': {
        ...commonDetails.toJsonForAttributes(),
        'category': category,
      },
      'phone': "9100000000",
      'stock': 1,
    };
    return ProductRequestModel.fromJson(model);
  }
}
