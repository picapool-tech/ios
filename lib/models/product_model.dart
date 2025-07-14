import 'package:flutter/material.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/tag_model.dart';

class Product {
  final int id;
  final String name;
  final List<String> images;
  final String description;
  final int? mrp;
  final int? offerPrice;
  final int? price;
  final String? email;
  final String? phone;
  final Map<String, dynamic>? attributes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? partnerId;
  final int? userId;
  final List<Offer> offers;
  final List<Tag> tags;

  Product({
    required this.id,
    required this.name,
    required this.images,
    required this.description,
    required this.price,
    this.mrp,
    this.offerPrice,
    this.email,
    this.phone,
    this.attributes,
    required this.createdAt,
    required this.updatedAt,
    this.partnerId,
    this.userId,
    required this.offers,
    required this.tags,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    debugPrint("PRODUCT JSON: $json");
    return Product(
      id: json['id'],
      name: json['name'],
      images: List<String>.from(json['images']),
      description: json['description'],
      mrp: json['mrp'],
      price: json['price'],
      offerPrice: json['offerPrice'],
      email: json['email'],
      phone: json['phone'],
      attributes: json['attributes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      partnerId: json['partnerId'],
      userId: json['userId'],
      offers: (json['Offers'] != null)
          ? (json['Offers'] as List).map((o) => Offer.fromJson(o)).toList()
          : [],
      tags: (json['tags'] != null)
          ? (json['tags'] as List).map((t) => Tag.fromJson(t)).toList()
          : [],
    );
  }

  bool isProductSold() {
    return attributes?['sold'] ?? false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'images': images,
      'description': description,
      'mrp': mrp,
      'offerPrice': offerPrice,
      'email': email,
      'phone': phone,
      'attributes': attributes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'partnerId': partnerId,
      'userId': userId,
      'Offers': offers.map((o) => o.toJson()).toList(),
      'Tags': tags.map((t) => t.toJson()).toList(),
      'price': price,
    };
  }
}
