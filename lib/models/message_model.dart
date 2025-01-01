import 'package:picapool/models/admin_model.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/reaction_model.dart';
import 'package:picapool/models/user_model.dart';

class Message {
  final int id;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final int? userId;
  final Admin? admin;
  final int? adminId;
  final int? chatId;
  final int? parentId;
  final List<Message>? children;
  final List<Reaction>? reactions;

  Message({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.userId,
    this.admin,
    this.adminId,
    this.chatId,
    this.parentId,
    this.children,
    this.reactions,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      userId: json['userId'],
      admin: json['admin'] != null ? Admin.fromJson(json['admin']) : null,
      adminId: json['adminId'],
      chatId: json['chatId'],
      parentId: json['parentId'],
      children: json['children'] != null
          ? (json['children'] as List).map((m) => Message.fromJson(m)).toList()
          : null,
      reactions: json['reactions'] != null
          ? (json['reactions'] as List)
              .map((r) => Reaction.fromJson(r))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user?.toJson(),
      'userId': userId,
      'admin': admin?.toJson(),
      'adminId': adminId,
      'chatId': chatId,
      'parentId': parentId,
      'children': children?.map((m) => m.toJson()).toList(),
      'reactions': reactions?.map((r) => r.toJson()).toList(),
    };
  }

  bool isSameDay(DateTime other) {
    return createdAt.year == other.year &&
        createdAt.month == other.month &&
        createdAt.day == other.day;
  }
}
