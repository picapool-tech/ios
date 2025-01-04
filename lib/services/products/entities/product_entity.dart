
import 'package:picapool/services/products/entities/product_attributes_entity.dart';

class ProductData {
    int? id;
    String? name;
    List<String>? images;
    String? description;
    int? mrp;
    int? offerPrice;
    String? email;
    String? phone;
    Attributes? attributes;
    DateTime? createdAt;
    DateTime? updatedAt;
    dynamic partnerId;
    int? userId;

    ProductData({
        this.id,
        this.name,
        this.images,
        this.description,
        this.mrp,
        this.offerPrice,
        this.email,
        this.phone,
        this.attributes,
        this.createdAt,
        this.updatedAt,
        this.partnerId,
        this.userId,
    });

    factory ProductData.fromJson(Map<String, dynamic> json) => ProductData(
        id: json["id"],
        name: json["name"],
        images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
        description: json["description"],
        mrp: json["mrp"],
        offerPrice: json["offerPrice"],
        email: json["email"],
        phone: json["phone"],
        attributes: json["attributes"] == null ? null : Attributes.fromJson(json["attributes"]),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        partnerId: json["partnerId"],
        userId: json["userId"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
        "description": description,
        "mrp": mrp,
        "offerPrice": offerPrice,
        "email": email,
        "phone": phone,
        "attributes": attributes?.toJson(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "partnerId": partnerId,
        "userId": userId,
    };
}