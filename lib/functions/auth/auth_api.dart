import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/models/login_model.dart';
import 'package:picapool/models/response_model.dart';
import 'package:picapool/models/user_model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthApi {
  FutureEither<LoginModel> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['profile', 'email'],
      forceCodeForRefreshToken: true,
    );
    try {
      final GoogleSignInAccount? account = await googleSignIn.signIn();

      if (account == null) {
        throw Exception('No account found');
      }

      final GoogleSignInAuthentication googleAuth =
          await account.authentication;
      log('Google Token: ${googleAuth.idToken}');

      final http.Response response =
          await _sendGoogleTokenToServer(googleAuth.idToken!);

      debugPrint('Google Sign-In Response : $response');
      var responseModel = ResponseModel.fromJson(jsonDecode(response.body));

      if (responseModel.success) {
        return right(LoginModel.fromJson(responseModel.data));
      } else {
        return left(
          Failure(
            message: responseModel.message,
            stackTrace: StackTrace.current,
          ),
        );
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return left(
        Failure(
          message: "Failed to sign in with Google. Please try again.",
          stackTrace: StackTrace.fromString(e.toString()),
        ),
      );
    }
  }

  FutureEither<LoginModel> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      log('Apple Token: ${appleCredential.identityToken}');

      final oAuthProvider = firebase.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      var user = await firebase.FirebaseAuth.instance.signInWithCredential(
        oAuthProvider,
      );

      user.user?.displayName;

      var name = oAuthProvider.appleFullPersonName?.toString();
      log("APPLE USER NAME: $name");

      final http.Response response =
          await _sendAppleTokenToServer(appleCredential.identityToken!);

      final int statusCode = response.statusCode;

      debugPrint('Apple Sign-In Response Status Code: $statusCode');

      if (statusCode >= 200 && statusCode < 300) {
        var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
        if (responseModel.success) {
          var loginModel = LoginModel.fromJson(responseModel.data);
          loginModel.name = name;
          return right(loginModel);
        } else {
          return left(
            Failure(
              message: responseModel.message,
              stackTrace: StackTrace.current,
            ),
          );
        }
      } else {
        return left(
          Failure(
            message: "Not able to sign in with apple : status code $statusCode",
            stackTrace: StackTrace.current,
          ),
        );
      }
    } catch (e) {
      debugPrint("ERROR IN APPLE SIGN IN : $e");
      return left(
        Failure(
            message: "Failed to sign in with Apple. Please try again.",
            stackTrace: StackTrace.fromString(e.toString())),
      );
    }
  }

  Future<http.Response> _sendGoogleTokenToServer(String googleToken) async {
    const String url = 'https://api.picapool.com/v2/auth/login/User';

    var body = {
      "googleToken": googleToken,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    log('Google Sign-In Response: ${response.body}');

    return response;
  }

  Future<http.Response> _sendAppleTokenToServer(String appleToken) async {
    const String url = 'https://api.picapool.com/v2/auth/login/User';

    var body = {
      "appleToken": appleToken,
    };

    http.Response response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    log('Apple Sign-In Response: ${response.body}');

    return response;
  }

  FutureEither<LoginModel> loginWithOtp(String mobile, String otp) async {
    const String url = 'https://api.picapool.com/v2/auth/login/User';

    var body = {
      // 'authInfo': {
      'msgOTP': {
        'mobile': mobile,
        'otp': otp,
      }
      // }
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    log('OTP Sign-In Response: ${response.body}');

    final int statusCode = response.statusCode;

    debugPrint('OTP Sign-In Response Status Code: $statusCode');

    if (statusCode >= 200 && statusCode < 300) {
      var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
      if (responseModel.success) {
        return right(LoginModel.fromJson(responseModel.data));
      } else {
        return left(
          Failure(
            message: responseModel.message,
            stackTrace: StackTrace.current,
          ),
        );
      }
    } else {
      return left(
        Failure(
          message: "Not able to sign in with otp : Status Code $statusCode",
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  FutureEither<User> createUser(User user, String accessToken) async {
    try {
      const String url = "https://api.picapool.com/v2/user";
      var body = {
        "name": user.name,
        "bio": user.bio,
        "pic": user.pic,
        "tagList": [],
      };
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      int statusCode = response.statusCode;
      if (statusCode >= 200 && statusCode < 300) {
        debugPrint('User Created: ${response.body}');
        var user = jsonDecode(response.body);
        return right(user);
      } else if (JwtDecoder.isExpired(accessToken)) {
        return left(
          Failure(
            message: "Access token expired",
            stackTrace: StackTrace.current,
          ),
        );
      } else {
        return left(
          Failure(
            message: "Not able to create the user : status code $statusCode",
            stackTrace: StackTrace.current,
          ),
        );
      }
    } catch (e) {
      debugPrint('Create User Error: $e');
      return left(
        Failure(
          message: "Failed to create user. Please try again.",
          stackTrace: StackTrace.fromString(
            e.toString(),
          ),
        ),
      );
    }
  }

  // FutureEither<Auth> verifyOtp(String phoneNumber, String otp) async {
  //   String url =
  //       'https://api.picapool.com/v2/otp/verify?otp=$otp&mobile=${phoneNumber}';
  //   try {
  //     final response = await http.get(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     if (response.statusCode == 200) {
  //       final responseBody = response.body;
  //       if (responseBody.contains('"type":"success"')) {}
  //       // else {
  //       //   setState(() {
  //       //     _isOtpIncorrect = true;
  //       //   });

  //       //   ScaffoldMessenger.of(context).showSnackBar(
  //       //     const SnackBar(content: Text('Incorrect OTP. Please try again.')),
  //       //   );
  //       // }
  //     } else {
  //       // ScaffoldMessenger.of(context).showSnackBar(
  //       //   const SnackBar(
  //       //       content: Text('Failed to verify OTP. Please try again.')),
  //       // );
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     // ScaffoldMessenger.of(context).showSnackBar(
  //     //   const SnackBar(
  //     //       content: Text('An error occurred. Please try again later.')),
  //     // );
  //   }
  // }

  // FutureEither<String> refreshAccessToken(String refreshToken) {
  //   try {
  //     const String url = "https://api.picapool.com/v2/auth/refresh";
  //     var body = {
  //       "refreshToken": refreshToken,
  //     };
  //     http.Response response = await http.post(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(body),
  //     );
  //     int statusCode = response.statusCode;
  //     if (statusCode >= 200 && statusCode < 300) {
  //       debugPrint('User Created: ${response.body}');
  //       var user = jsonDecode(response.body);
  //       return right(user);
  //     } else {
  //       return left(
  //         Failure(
  //           message: "Not able to create the user : status code $statusCode",
  //           stackTrace: StackTrace.current,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint('Create User Error: $e');
  //     return left(
  //       Failure(
  //         message: "Failed to create user. Please try again.",
  //         stackTrace: StackTrace.fromString(e.toString()),
  //       ),
  //     );

  FutureEither<String> updateAccessToken({
    required String accessToken,
    required String refreshToken,
    required int userId,
  }) async {
    debugPrint('REQUESTED FOR UPDATE ACCESS TOKEN');
    debugPrint('Refresh token: $refreshToken');
    try {
      final response = await http.post(
        Uri.parse("https://api.picapool.com/v2/auth/accessToken"),
        body: jsonEncode({
          "refreshToken": refreshToken,
        }),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken',
        },
      );
      debugPrint('UPDATE ACCESS TOKEN RESPONSE CODE : ${response.statusCode}');

      debugPrint('Response :  ${response.body}');
      var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
      if (responseModel.success) {
        String newAccessToken = responseModel.data['newAccessToken'] as String;
        debugPrint("New access TOken from server: $newAccessToken");
        return right(newAccessToken);
      }
      return left(
        Failure(message: responseModel.message, stackTrace: StackTrace.current),
      );
    } catch (e) {
      debugPrint('Error updating access token: $e');
      return left(
        Failure(
          message: "Not able to refresh the access token",
          stackTrace: StackTrace.fromString(
            e.toString(),
          ),
        ),
      );
    }
  }
}
