import 'package:flutter/material.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/partner_model.dart';
import 'package:picapool/models/product_model.dart';
import 'package:picapool/models/tag_model.dart';
import 'package:picapool/models/user_model.dart';
import 'package:picapool/models/vicinity_offer_model.dart';

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
  final VicinityLocation? location;
  final Partner? partner;
  final int? partnerId;
  final User? user;
  final int? userId;
  final List<Chat>? chats;
  final List<Tag>? tags;
  final List<Product>? products;
  final int? radius;
  final bool top;
  final int? units;
  final int? maxUnits;

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
    this.radius,
    this.top = false,
    this.units,
    this.maxUnits,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    debugPrint("INSIDE OFFER.fromJSON function: $json");
    return Offer(
      id: json['id'],
      name: json['name'],
      images: List<String>.from(json['images']),
      desc: json['desc'],
      createdAt: DateTime.parse(
        json['createdAt'],
      ).toLocal(),
      expiryAt: DateTime.parse(json['expiryAt']).toLocal(),
      link: json['link'] ?? "",
      isVerified: json['isVerified'] ?? false,
      priority: json['priority'] ?? 1,
      isOnline: json['isOnline'] ?? false,
      location:
          json['loc'] != null ? VicinityLocation.fromJson(json['loc']) : null,
      partner:
          json['partner'] != null ? Partner.fromJson(json['partner']) : null,
      partnerId: json['partnerId'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      userId: json['userId'],
      chats: json['Chats'] != null
          ? (json['Chats'] as List).map((c) => Chat.fromJson(c)).toList()
          : null,
      tags: json['Tags'] != null
          ? (json['Tags'] as List).map((t) => Tag.fromJson(t)).toList()
          : null,
      products: json['Products'] != null
          ? (json['Products'] as List).map((p) => Product.fromJson(p)).toList()
          : null,
      radius: json['radius'],
      top: json['top'] ?? false,
      units: json['units'] as int?,
      maxUnits: json['maxUnits'] as int?,
    );
  }

  String get shareOfferString {
    return """
Spotted this deal on Picapool -- might be just what you need! *(This is within your 2km radius!)*

Title: _${name.replaceAll("- FROM BRANDS", "")}_
Details: _${desc.split('\n').take(3).join('\n')}${desc.split('\n').length > 3 ? '...' : ''}_

Check it out: "https://offer.picapool.com/offer/$id"

""";
  }

  /// Creates a copy of this Offer with the given fields replaced with new values.
  Offer copyWith({
    int? id,
    String? name,
    List<String>? images,
    String? desc,
    DateTime? createdAt,
    DateTime? expiryAt,
    String? link,
    bool? isVerified,
    int? priority,
    bool? isOnline,
    VicinityLocation? location,
    Partner? partner,
    int? partnerId,
    User? user,
    int? userId,
    List<Chat>? chats,
    List<Tag>? tags,
    List<Product>? products,
    int? radius,
    bool? top,
    int? units,
    int? maxUnits,
  }) {
    return Offer(
      id: id ?? this.id,
      name: name ?? this.name,
      images: images ?? this.images,
      desc: desc ?? this.desc,
      createdAt: createdAt ?? this.createdAt,
      expiryAt: expiryAt ?? this.expiryAt,
      link: link ?? this.link,
      isVerified: isVerified ?? this.isVerified,
      priority: priority ?? this.priority,
      isOnline: isOnline ?? this.isOnline,
      location: location ?? this.location,
      partner: partner ?? this.partner,
      partnerId: partnerId ?? this.partnerId,
      user: user ?? this.user,
      userId: userId ?? this.userId,
      chats: chats ?? this.chats,
      tags: tags ?? this.tags,
      products: products ?? this.products,
      radius: radius ?? this.radius,
      top: top ?? this.top,
      units: units ?? this.units,
      maxUnits: maxUnits ?? this.maxUnits,
    );
  }

  bool isOfferExpired() {
    var now = DateTime.now();

    return now.isAfter(expiryAt);
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
      'loc': location,
      'partner': partner?.toJson(),
      'partnerId': partnerId,
      'user': user?.toJson(),
      'userId': userId,
      'chats': chats?.map((c) => c.toJson()).toList(),
      'Tags': tags?.map((t) => t.toJson()).toList(),
      'Products': products?.map((p) => p.toJson()).toList(),
      'radius': radius,
      'top': top,
      'units': units,
      'maxUnits': maxUnits,
    };
  }

  /// Creates a new Offer with updated fields from the provided map.
  /// Useful for partial updates.
  Offer updateFromMap(Map<String, dynamic> updates) {
    // Convert any date strings to DateTime objects
    if (updates.containsKey('createdAt') && updates['createdAt'] is String) {
      updates['createdAt'] = DateTime.parse(updates['createdAt']).toLocal();
    }

    if (updates.containsKey('expiryAt') && updates['expiryAt'] is String) {
      updates['expiryAt'] = DateTime.parse(updates['expiryAt']).toLocal();
    }

    // Handle relationships
    if (updates.containsKey('loc') && updates['loc'] != null) {
      updates['location'] = VicinityLocation.fromJson(updates['loc']);
      updates.remove('loc');
    }

    if (updates.containsKey('partner') && updates['partner'] != null) {
      updates['partner'] = Partner.fromJson(updates['partner']);
    }

    if (updates.containsKey('user') && updates['user'] != null) {
      updates['user'] = User.fromJson(updates['user']);
    }

    // Handle array fields
    if (updates.containsKey('Chats') && updates['Chats'] != null) {
      updates['chats'] =
          (updates['Chats'] as List).map((c) => Chat.fromJson(c)).toList();
      updates.remove('Chats');
    }

    if (updates.containsKey('Tags') && updates['Tags'] != null) {
      updates['tags'] =
          (updates['Tags'] as List).map((t) => Tag.fromJson(t)).toList();
      updates.remove('Tags');
    }

    if (updates.containsKey('Products') && updates['Products'] != null) {
      updates['products'] = (updates['Products'] as List)
          .map((p) => Product.fromJson(p))
          .toList();
      updates.remove('Products');
    }

    return copyWith(
      id: updates['id'],
      name: updates['name'],
      images: updates['images'] != null
          ? List<String>.from(updates['images'])
          : null,
      desc: updates['desc'],
      createdAt: updates['createdAt'],
      expiryAt: updates['expiryAt'],
      link: updates['link'],
      isVerified: updates['isVerified'],
      priority: updates['priority'],
      isOnline: updates['isOnline'],
      location: updates['location'],
      partner: updates['partner'],
      partnerId: updates['partnerId'],
      user: updates['user'],
      userId: updates['userId'],
      chats: updates['chats'],
      tags: updates['tags'],
      products: updates['products'],
      radius: updates['radius'],
      top: updates['top'],
      units: updates['units'],
      maxUnits: updates['maxUnits'],
    );
  }
}
