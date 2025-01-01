// {
//   "authId": 2,
//   "tenant": {
//     "type": "User",
//     "id": 102
//   },
//   "Roles": [
//     {
//       "id": 1,
//       "role": "User"
//     }
//   ],
//   "iat": 1735749188,
//   "exp": 1735835588
// }
import 'package:flutter/material.dart';
import 'package:picapool/models/role_model.dart';

class AccessTokenModel {
  final int authId;
  final TenantModel tenant;
  final Role role;

  AccessTokenModel({
    required this.authId,
    required this.tenant,
    required this.role,
  });

  factory AccessTokenModel.fromJson(Map<String, dynamic> json) {
    debugPrint("AccessTokenModel.fromJson: $json");
    return AccessTokenModel(
      authId: json['authId'],
      tenant: TenantModel.fromJson(json['tenant']),
      role: Role.fromJson(json['Roles'][0]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authId': authId,
      'tenant': tenant.toJson(),
      'Roles': [role.toJson()],
    };
  }
}

class TenantModel {
  final String role;
  final int id;

  TenantModel({
    required this.role,
    required this.id,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      role: json['type'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': role,
      'id': id,
    };
  }
}
