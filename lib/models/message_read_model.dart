class MessageReadModel {
  final int userId;
  final DateTime readAt;
  final MessageReadUserModel user;

  MessageReadModel({
    required this.userId,
    required this.readAt,
    required this.user,
  });

  MessageReadModel.fromJson(Map<String, dynamic> json)
      : userId = json['userId'] as int,
        readAt = DateTime.parse(json['readAt'] as String),
        user =
            MessageReadUserModel.fromJson(json['User'] as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'readAt': readAt.toIso8601String(),
      'user': user.toJson(),
    };
  }
}

class MessageReadUserModel {
  final String name;
  final int id;

  MessageReadUserModel({
    required this.name,
    required this.id,
  });

  MessageReadUserModel.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        id = json['id'] as int;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
    };
  }
}
