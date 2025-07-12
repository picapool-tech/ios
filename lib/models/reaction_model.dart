import 'package:picapool/models/admin_model.dart';
import 'package:picapool/models/message_model.dart';

class Reaction {
  final int? id;
  final String reaction;
  final Message? message;
  final int? messageId;
  final List<int> userIds;
  final Admin? admin;
  final int? adminId;
  final int count;

  Reaction({
    this.id,
    required this.reaction,
    this.message,
    this.messageId,
    this.userIds = const [],
    this.admin,
    this.adminId,
    this.count = 0,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      id: json['id'],
      reaction: json['reaction'],
      message:
          json['message'] != null ? Message.fromJson(json['message']) : null,
      messageId: json['messageId'],
      userIds: json['userIds'] != null ? List<int>.from(json['userIds']) : [],
      admin: json['admin'] != null ? Admin.fromJson(json['admin']) : null,
      adminId: json['adminId'],
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reaction': reaction,
      'message': message?.toJson(),
      'messageId': messageId,
      'userId': userIds,
      'admin': admin?.toJson(),
      'adminId': adminId,
    };
  }
}
