import 'package:flutter/material.dart';
import 'package:picapool/models/admin_model.dart';
import 'package:picapool/models/live_offer_model.dart';
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
  final List<LastMessageModel>? messages;
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
    debugPrint("Here I am in Chat.fromJson $json");
    return Chat(
      id: json['id'],
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
      isMain: json['isMain'],
      status: json['status'],
      offer: json['Offer'] != null ? Offer.fromJson(json['Offer']) : null,
      offerId: json['offerId'],
      liveOfferId: json['liveOfferId'],
      users: (json['Users'] ?? json['users']) != null
          ? (json['Users'] ?? json['users'] as List)
              .map((u) => User.fromJson(u))
              .toList()
              .cast<User>() 
          : null,
      messages: (json['Messages'] ?? json['messages']) != null
          ? (json['Messages'] ?? json['messages'] as List)
              .map((m) => LastMessageModel.fromJson(m))
              .toList()
              .cast<LastMessageModel>()
          : null,
      admins: json['Admins'] != null
          ? (json['Admins'] as List).map((a) => Admin.fromJson(a)).toList()
          : null,
      liveOffer: json['LiveOffer'] != null
          ? LiveOffer.fromJson(json['LiveOffer'])
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
      'Users': users?.map((u) => u.toJson()).toList(),
      'Admins': admins?.map((a) => a.toJson()).toList(),
    };
  }
}

class LastMessageModel {
  final String content;
  final String? admin;
  final MessageModalUser? user;

  LastMessageModel({
    required this.content,
    required this.admin,
    required this.user,
  });

  factory LastMessageModel.fromJson(Map<String, dynamic> json) {
    debugPrint("INSIDE LAST MESSAGE MODAL: $json");
    return LastMessageModel(
      content: json['content'],
      admin: json['Admin'],
      user: (json['User'] != null)
          ? MessageModalUser.fromJson(json['User'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'Admin': admin,
      'User': user?.toJson(),
    };
  }
}

class MessageModalUser {
  final String username;

  MessageModalUser({required this.username});

  factory MessageModalUser.fromJson(Map<String, dynamic> json) {
    return MessageModalUser(
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
    };
  }
}
