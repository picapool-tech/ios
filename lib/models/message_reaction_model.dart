import 'package:picapool/models/message_read_model.dart';

class MessageReactionModel {
  final String reaction;
  final int userId;
  final MessageReadUserModel user;

  MessageReactionModel({
    required this.userId,
    required this.reaction,
    required this.user,
  });

  MessageReactionModel.fromJson(Map<String, dynamic> json)
      : userId = json['userId'],
        reaction = json['reaction'],
        user =
            MessageReadUserModel.fromJson(json['User'] as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    return {
      'reaction': reaction,
      'userId': userId,
      'User': user.toJson(),
    };
  }
}
