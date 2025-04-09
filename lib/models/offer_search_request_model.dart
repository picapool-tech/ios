import 'package:picapool/models/vicinity_offer_model.dart';

class OfferSearchRequestModel {
  final VicinityLocation? loc;
  final int? radius;
  final bool? chats;
  final bool? products;
  final bool? top;
  final List<int>? tagIds;
  final bool? priority;

  OfferSearchRequestModel({
    this.top,
    this.tagIds,
    this.loc,
    this.radius,
    this.chats,
    this.products,
    this.priority,
  });

  factory OfferSearchRequestModel.fromJson(Map<String, dynamic> json) {
    return OfferSearchRequestModel(
      loc: json['loc'] != null ? VicinityLocation.fromJson(json['loc']) : null,
      radius: json['radius'],
      chats: json['chats'],
      products: json['products'],
      top: json['top'],
      tagIds: json['tagIds'] != null ? List<int>.from(json['tagIds']) : null,
      priority: json['priority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loc': loc?.toJson(),
      if (radius != null) 'radius': radius,
      if (chats != null) 'chats': chats,
      if (products != null) 'products': products,
      if (tagIds != null) 'tagIds': tagIds,
      if (top != null) 'top': top,
      if (priority != null) 'priority': priority,
    };
  }
}
