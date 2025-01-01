import 'package:picapool/models/auth_model.dart';

class Role {
  final int id;
  final String role;

  Role({
    required this.id,
    required this.role,

  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
    };
  }
}
