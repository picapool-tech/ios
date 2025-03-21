class AuthRequestBody {
  final String? appleToken;
  final String? googleToken;
  final MsgOtp? phoneOtp;

  AuthRequestBody({
    this.appleToken,
    this.googleToken,
    this.phoneOtp,
  });

  Map<String, dynamic> toJson() {
    return {
      if (appleToken != null) 'appleToken': appleToken,
      if (googleToken != null) 'googleToken': googleToken,
      if (phoneOtp != null) 'msgOTP': phoneOtp?.toJson(),
    };
  }
}

class MsgOtp {
  final String phoneNumber;
  final String otp;

  MsgOtp({
    required this.phoneNumber,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'mobile': phoneNumber,
      'otp': otp,
    };
  }
}
