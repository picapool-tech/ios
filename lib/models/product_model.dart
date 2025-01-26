import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/tag_model.dart';

class Product {
  final int id;
  final String name;
  final List<String> images;
  final String description;
  final int? mrp;
  final int? offerPrice;
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
    return Product(
      id: json['id'],
      name: json['name'],
      images: List<String>.from(json['images']),
      description: json['description'],
      mrp: json['mrp'],
      offerPrice: json['offerPrice'],
      email: json['email'],
      phone: json['phone'],
      attributes: json['attributes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      partnerId: json['partnerId'],
      userId: json['userId'],
      offers: (json['Offer'] != null)
          ? (json['Offer'] as List).map((o) => Offer.fromJson(o)).toList()
          : [],
      tags: (json['Tags'] != null)
          ? (json['Tags'] as List).map((t) => Tag.fromJson(t)).toList()
          : [],
    );
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
      'tags': tags.map((t) => t.toJson()).toList(),
    };
  }
}
