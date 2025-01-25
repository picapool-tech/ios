import 'package:picapool/models/vicinity_offer_model.dart';

class PartnerRequestModel {
  final String? username;
  final bool? delivery;
  final List<int>? tags;
  final int radius;
  final VicinityLocation location;

  PartnerRequestModel({
    this.username,
    this.delivery,
    this.tags,
    required this.radius,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      if (username != null) 'username': username,
      if (delivery != null) 'delivery': delivery,
      if (tags != null) 'tags': tags,
      'radius': radius,
      'loc': location.toJson(),
    };
  }
}
