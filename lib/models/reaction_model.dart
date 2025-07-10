import 'package:picapool/models/admin_model.dart';
import 'package:picapool/models/message_model.dart';
import 'package:picapool/models/user_model.dart';

class Reaction {
  final int? id;
  final String reaction;
  final Message? message;
  final int messageId;
  final User? user;
  final int? userId;
  final Admin? admin;
  final int? adminId;

  Reaction({
    this.id,
    required this.reaction,
    this.message,
    required this.messageId,
    this.user,
    this.userId,
    this.admin,
    this.adminId,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      id: json['id'],
      reaction: json['reaction'],
      message:
          json['message'] != null ? Message.fromJson(json['message']) : null,
      messageId: json['messageId'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      userId: json['userId'],
      admin: json['admin'] != null ? Admin.fromJson(json['admin']) : null,
      adminId: json['adminId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reaction': reaction,
      'message': message?.toJson(),
      'messageId': messageId,
      'user': user?.toJson(),
      'userId': userId,
      'admin': admin?.toJson(),
      'adminId': adminId,
    };
  }
}
