// making this class to just store the accessToken and refreshToken with isNew flag
// when the user logs in. This class is used in the auth_controller.dart file.
// The main purpose of using this model is to separate the data storing logic from the
//  Auth model.

class LoginModel {
  final String accessToken;
  final String refreshToken;
  final bool isNew;

  LoginModel({
    required this.accessToken,
    required this.refreshToken,
    required this.isNew,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      isNew: json['isNew'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'isNew': isNew,
    };
  }
}
