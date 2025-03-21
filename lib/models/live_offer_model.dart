import 'package:flutter/material.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/live_product_model.dart';
import 'package:picapool/models/user_model.dart';

class LiveOffer {
  final int id;
  final String? from;
  final String? to;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int seats;
  final User? user;
  final int? userId;
  final LivePartner? livePartner;
  final int? livePartnerId;
  final List<Chat>? chats;

  LiveOffer({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.seats,
    this.from,
    this.to,
    this.user,
    this.userId,
    this.livePartner,
    this.livePartnerId,
    this.chats,
  });

  factory LiveOffer.fromJson(Map<String, dynamic> json) {
    debugPrint("INSIDE LIVE OFFER JSON: $json");
    var liveOffer = LiveOffer(
      id: json['id'],
      from: json['fromAddress'],
      to: json['toAddress'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
      seats: json['seats'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      userId: json['userId'],
      livePartner: json['livePartner'] != null
          ? LivePartner.fromJson(json['livePartner'])
          : null,
      livePartnerId: json['livePartnerId'],
      chats: json['chats'] != null
          ? (json['chats'] as List).map((c) => Chat.fromJson(c)).toList()
          : null,
    );
    debugPrint("OUTSIDE LIVE OFFER JSON: $json");
    return liveOffer;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromAddress': from,
      'toAddress': to,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'seats': seats,
      'user': user?.toJson(),
      'userId': userId,
      'livePartner': livePartner?.toJson(),
      'livePartnerId': livePartnerId,
      'chats': chats?.map((c) => c.toJson()).toList(),
    };
  }
}
