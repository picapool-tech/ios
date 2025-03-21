import 'package:picapool/models/chat_model.dart';

class ChatUnreadModel {
  final int chatId;
  final LastMessageModel? lastMessageModel;

  ChatUnreadModel({
    required this.chatId,
    required this.lastMessageModel,
  });

  factory ChatUnreadModel.fromJson(Map<String, dynamic> json) {
    return ChatUnreadModel(
      chatId: json['chatId'],
      lastMessageModel: (json['lastMessageModel'] != null)
          ? LastMessageModel.fromJson(json['lastMessageModel'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'lastMessageModel': lastMessageModel?.toJson(),
    };
  }
}
