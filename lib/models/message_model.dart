import 'package:picapool/models/admin_model.dart';
import 'package:picapool/models/reaction_model.dart';

class Message {
  final int id;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MessageUserModel? user;
  final int? userId;
  final Admin? admin;
  final int? adminId;
  final int? chatId;
  final int? parentId;
  final List<Message>? children;
  final List<Reaction> reactions;
  final MessageType type;
  ReadMessageData? readData;

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
    this.reactions = const [],
    required this.type,
    this.readData,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
      user:
          json['User'] != null ? MessageUserModel.fromJson(json['User']) : null,
      userId: json['userId'],
      admin: json['Admin'] != null ? Admin.fromJson(json['Admin']) : null,
      adminId: json['adminId'],
      chatId: json['chatId'],
      parentId: json['parentId'],
      children: json['children'] != null
          ? (json['children'] as List).map((m) => Message.fromJson(m)).toList()
          : null,
      reactions: json['Reactions'] != null
          ? (json['Reactions'] as List)
              .map((r) => Reaction.fromJson(r))
              .toList()
          : [],
      type: MessageType.fromString(json['messageType'] ?? 'user'),
    );
  }

  Map<String, int> get groupedReactions {
    return reactions.fold<Map<String, int>>({}, (acc, reaction) {
      acc[reaction.reaction] = (acc[reaction.reaction] ?? 0) + 1;
      return acc;
    });
  }

  bool isSameDay(DateTime other) {
    return createdAt.year == other.year &&
        createdAt.month == other.month &&
        createdAt.day == other.day;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'user': user?.toJson(),
      'userId': userId,
      'admin': admin?.toJson(),
      'adminId': adminId,
      'chatId': chatId,
      'parentId': parentId,
      'children': children?.map((m) => m.toJson()).toList(),
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'messageType': MessageType.toValue(type).toUpperCase(),
    };
  }
}

enum MessageType {
  user,
  system;

  static MessageType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'user':
        return MessageType.user;
      case 'system':
        return MessageType.system;
      default:
        throw ArgumentError('Invalid message type: $type');
    }
  }

  static String toValue(MessageType type) {
    switch (type) {
      case MessageType.user:
        return 'user';
      case MessageType.system:
        return 'system';
    }
  }
}

class MessageUserModel {
  String? pic;
  String? username;

  MessageUserModel({this.pic, this.username});

  factory MessageUserModel.fromJson(Map<String, dynamic> json) {
    return MessageUserModel(
      pic: json['pic'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pic': pic,
      'username': username,
    };
  }
}

class ReadMessageData {
  final int messageId;
  final int userId;
  final bool isRead;

  ReadMessageData({
    required this.messageId,
    required this.userId,
    this.isRead = false,
  });

  factory ReadMessageData.fromJson(Map<String, dynamic> json) {
    return ReadMessageData(
      messageId: json['messageId'],
      userId: json['userId'],
      isRead: json['isReadByAll'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'userId': userId,
      'isReadByAll': isRead,
    };
  }
}
