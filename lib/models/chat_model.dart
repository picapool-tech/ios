import 'package:picapool/models/admin_model.dart';
import 'package:picapool/models/live_offer_model.dart';
import 'package:picapool/models/message_model.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/user_model.dart';

class Chat {
  final int id;
  final DateTime updatedAt;
  final bool isMain;
  final Map<String, dynamic>? status;
  final Offer? offer;
  final int? offerId;
  final LiveOffer? liveOffer;
  final int? liveOfferId;
  final List<Message>? messages;
  final List<User>? users;
  final List<Admin>? admins;

  Chat({
    required this.id,
    required this.updatedAt,
    required this.isMain,
    this.status,
    this.offer,
    this.offerId,
    this.liveOffer,
    this.liveOfferId,
    this.messages,
    this.users,
    this.admins,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      updatedAt: DateTime.parse(json['updatedAt']),
      isMain: json['isMain'],
      status: json['status'],
      offer: json['offer'] != null ? Offer.fromJson(json['offer']) : null,
      offerId: json['offerId'],
      liveOffer: json['liveOffer'] != null
          ? LiveOffer.fromJson(json['liveOffer'])
          : null,
      liveOfferId: json['liveOfferId'],
      messages: json['Messages'] != null
          ? (json['Messages'] as List).map((m) => Message.fromJson(m)).toList()
          : null,
      users: json['users'] != null
          ? (json['users'] as List).map((u) => User.fromJson(u)).toList()
          : null,
      admins: json['admins'] != null
          ? (json['admins'] as List).map((a) => Admin.fromJson(a)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'updatedAt': updatedAt.toIso8601String(),
      'isMain': isMain,
      'status': status,
      'offer': offer?.toJson(),
      'offerId': offerId,
      'liveOffer': liveOffer?.toJson(),
      'liveOfferId': liveOfferId,
      'messages': messages?.map((m) => m.toJson()).toList(),
      'users': users?.map((u) => u.toJson()).toList(),
      'admins': admins?.map((a) => a.toJson()).toList(),
    };
  }
}
