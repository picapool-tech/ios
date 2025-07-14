class VicinityLocation {
  final double lat;
  final double long;

  VicinityLocation({
    required this.lat,
    required this.long,
  });

  factory VicinityLocation.fromJson(Map<String, dynamic> json) {
    return VicinityLocation(
      lat: json['lat'],
      long: json['lng'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "lat": lat,
      "lng": long,
    };
  }
}

class VicinityOffer {
  final String name;
  final List<String> images;
  final String desc;
  final DateTime expiryAt;
  int? partnerID;
  final int userId;
  final List<String> productIds;
  final List<int> tagIds;
  final VicinityLocation location;
  final double distance;
  final int? price;

  VicinityOffer({
    required this.name,
    required this.images,
    required this.desc,
    required this.expiryAt,
    required this.userId,
    required this.location,
    this.price,
    this.partnerID,
    this.productIds = const [],
    this.tagIds = const [],
    required this.distance,
  });

  factory VicinityOffer.fromJson(Map<String, dynamic> json) {
    return VicinityOffer(
      name: json['name'],
      images: (json['images']) ? List<String>.from(json['images']) : [],
      desc: json['desc'],
      expiryAt: DateTime.parse(json['expiryAt']),
      userId: json['userId'],
      productIds: (json['productIds'] != null)
          ? List<String>.from(json['productIds'])
          : [],
      partnerID: json['partnerId'],
      tagIds: (json['tagIds']) ? List<int>.from(json['tags']) : [],
      location: VicinityLocation.fromJson(json['loc']),
      distance: json['dist'] ?? 500,
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'images': images,
      'desc': desc,
      'expiryAt': expiryAt.toUtc().toIso8601String(),
      'userId': userId,
      'productIds': productIds,
      'tagIds': tagIds,
      'loc': location.toJson(),
      'dist': distance,
      if(price != null) 'price': price,
    };
  }
}
