import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/partner_model.dart';
import 'package:picapool/models/product_model.dart';
import 'package:picapool/models/tag_model.dart';
import 'package:picapool/models/user_model.dart';

class Offer {
  final int id;
  final String name;
  final List<String> images;
  final String desc;
  final DateTime createdAt;
  final DateTime expiryAt;
  final String link;
  final bool isVerified;
  final int priority;
  final bool isOnline;
  final String? location;
  final Partner? partner;
  final int? partnerId;
  final User? user;
  final int? userId;
  final List<Chat>? chats;
  final List<Tag>? tags;
  final List<Product>? products;

  Offer({
    required this.id,
    required this.name,
    required this.images,
    required this.desc,
    required this.createdAt,
    required this.expiryAt,
    this.link = "",
    this.isVerified = false,
    this.priority = 1,
    this.isOnline = false,
    this.location,
    this.partner,
    this.partnerId,
    this.user,
    this.userId,
    this.chats,
    this.tags,
    this.products,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      name: json['name'],
      images: List<String>.from(json['images']),
      desc: json['desc'],
      createdAt: DateTime.parse(json['createdAt']),
      expiryAt: DateTime.parse(json['expiryAt']),
      link: json['link'] ?? "",
      isVerified: json['isVerified'] ?? false,
      priority: json['priority'] ?? 1,
      isOnline: json['isOnline'] ?? false,
      location: json['location'] ?? "",
      partner:
          json['partner'] != null ? Partner.fromJson(json['partner']) : null,
      partnerId: json['partnerId'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      userId: json['creatorId'],
      chats: json['chats'] != null
          ? (json['chats'] as List).map((c) => Chat.fromJson(c)).toList()
          : null,
      tags: json['tags'] != null
          ? (json['tags'] as List).map((t) => Tag.fromJson(t)).toList()
          : null,
      products: json['products'] != null
          ? (json['products'] as List).map((p) => Product.fromJson(p)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'images': images,
      'desc': desc,
      'createdAt': createdAt.toIso8601String(),
      'expiryAt': expiryAt.toIso8601String(),
      'link': link,
      'isVerified': isVerified,
      'priority': priority,
      'isOnline': isOnline,
      'location': location,
      'partner': partner?.toJson(),
      'partnerId': partnerId,
      'user': user?.toJson(),
      'userId': userId,
      'chats': chats?.map((c) => c.toJson()).toList(),
      'tags': tags?.map((t) => t.toJson()).toList(),
      'products': products?.map((p) => p.toJson()).toList(),
    };
  }
}
