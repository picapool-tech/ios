import 'package:geocoding/geocoding.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/product_model.dart';
import 'package:picapool/models/tag_model.dart';

class Partner {
  final int id;
  final String? username;
  final String? ownername;
  final String? pic;
  final String? link;
  final bool? delivery;
  final String? email;
  final String? phone;
  final Location? location;
  final List<Tag>? tags;
  final List<Product>? products;
  final List<Offer>? offers;

  Partner({
    required this.id,
    this.username,
    this.ownername,
    this.pic,
    this.link,
    this.delivery,
    this.email,
    this.phone,
    this.location,
    this.tags,
    this.products,
    this.offers,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'],
      username: json['username'],
      ownername: json['ownername'],
      pic: json['pic'],
      link: json['link'],
      delivery: json['delivery'],
      email: json['email'],
      phone: json['phone'],
      location: json['location'] != null
          ? Location(
              latitude: json['location']['lng'],
              longitude: json['location']['lng'],
              timestamp: DateTime.now())
          : null,
      tags: json['tags'] != null
          ? List<Tag>.from(json['tags'].map((tag) => Tag.fromJson(tag)))
          : null,
      products: json['products'] != null
          ? List<Product>.from(
              json['products'].map((product) => Product.fromJson(product)))
          : null,
      offers: json['offers'] != null
          ? List<Offer>.from(
              json['offers'].map((offer) => Offer.fromJson(offer)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'ownername': ownername,
        'pic': pic,
        'link': link,
        'delivery': delivery,
        'email': email,
        'phone': phone,
        'location': (location != null)
            ? {
                'loc': location!.latitude,
                'lng': location!.longitude,
              }
            : null,
        'tags': tags?.map((tag) => tag.toJson()).toList(),
        'products': products?.map((product) => product.toJson()).toList(),
        'offers': offers?.map((offer) => offer.toJson()).toList(),
      };
}
