class AuthPhoneModel {
  final String phone;
  final String code;

  AuthPhoneModel({
    required this.phone,
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'mobile': phone,
      'otp': code,
    };
  }
}

class Authupdatemodel {
  int authId;
  String? googleToken;
  String? appleToken;
  AuthPhoneModel? phone;

  Authupdatemodel({
    required this.authId,
    this.googleToken,
    this.appleToken,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    
    return {
      'id': authId,
      if (googleToken != null) 'googleToken': googleToken,
      if (appleToken != null) 'appleToken': appleToken,
      if (phone != null) 'msgOTP': phone!.toJson(),
    };
  }
}
