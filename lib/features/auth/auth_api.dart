import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:picapool/core/api_impl.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/core/env_constants.dart';
import 'package:picapool/features/auth/authUpdateModel/authUpdateModel.dart';
import 'package:picapool/features/auth/values/auth_request_body.dart';
import 'package:picapool/models/login_model.dart';
import 'package:picapool/models/response_model.dart';
import 'package:picapool/models/user_model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthApi with PicapoolApiClass {
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

  FutureEither<LoginModel> loginWithOtp(String mobile, String otp) async {
    // const String url = 'https://api.picapool.com/v2/auth/login/User';

    var body = {
      'msgOTP': {
        'mobile': mobile,
        'otp': otp,
      }
    };

    var authRequestBody = AuthRequestBody(
      phoneOtp: MsgOtp(
        phoneNumber: mobile,
        otp: otp,
      ),
    );

    var result = await _login(authRequestBody);

    return result;

    // final response = await http.post(
    //   Uri.parse(url),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode(body),
    // );

    // log('OTP Sign-In Response: ${re.body}');

    // final int statusCode = response.statusCode;

    // debugPrint('OTP Sign-In Response Status Code: $statusCode');

    // if (statusCode >= 200 && statusCode < 300) {
    //   var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
    //   if (responseModel.success) {
    //     return right(LoginModel.fromJson(responseModel.data));
    //   } else {
    //     return left(
    //       Failure(
    //         message: responseModel.message,
    //         stackTrace: StackTrace.current,
    //       ),
    //     );
    //   }
    // } else {
    //   return left(
    //     Failure(
    //       message: "Not able to sign in with otp : Status Code $statusCode",
    //       stackTrace: StackTrace.current,
    //     ),
    //   );
    // }
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

      var authRequestBody =
          AuthRequestBody(appleToken: appleCredential.identityToken!);
      final result = await _login(authRequestBody);
      return result.fold((error) => left(error), (loginModel) {
        loginModel.name = name;
        return right(loginModel);
      });

      // if (statusCode >= 200 && statusCode < 300) {
      //   var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
      //   if (responseModel.success) {
      //     var loginModel = LoginModel.fromJson(responseModel.data);
      //     loginModel.name = name;
      //     return right(loginModel);
      //   } else {
      //     return left(
      //       Failure(
      //         message: responseModel.message,
      //         stackTrace: StackTrace.current,
      //       ),
      //     );
      //   }
      // } else {
      //   return left(
      //     Failure(
      //       message: "Not able to sign in with apple : status code $statusCode",
      //       stackTrace: StackTrace.current,
      //     ),
      //   );
      // }
    } catch (e) {
      debugPrint("ERROR IN APPLE SIGN IN : $e");
      return left(
        Failure(
            message: "Failed to sign in with Apple. Please try again.",
            stackTrace: StackTrace.fromString(e.toString())),
      );
    }
  }

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

      log("DISPLAY NAME: ${account.displayName}");

      var authRequestBody = AuthRequestBody(googleToken: googleAuth.idToken!);

      var result = await _login(authRequestBody);
      return result.fold((error) => left(error), (loginModel) {
        loginModel.name = account.displayName;
        return right(loginModel);
      });

      // final response = await _sendGoogleTokenToServer(googleAuth.idToken!);

      // debugPrint('Google Sign-In Response : $response');
      // var responseModel = ResponseModel.fromJson(jsonDecode(response.body));

      // if (responseModel.success) {
      //   var loginModel = LoginModel.fromJson(responseModel.data);
      //   loginModel.name = account.displayName;
      //   return right(loginModel);
      // } else {
      //   return left(
      //     Failure(
      //       message: responseModel.message,
      //       stackTrace: StackTrace.current,
      //     ),
      //   );
      // }
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

  FutureEither<ResponseModel> updateAuth({
    required Authupdatemodel updateValue,
  }) async {
    try {
      debugPrint("UPDATE AUTH REQUEST: ${updateValue.toJson()}");
      debugPrint("${APIConstants.apiUrl}${APIEndpoints.updateAuth}");

      var response = await api.makeRequest(
        enpoint: APIEndpoints.updateAuth,
        method: RequestMethod.patch,
        body: updateValue.toJson(),
      );

      return response.fold((error) => left(error), (responseModel) {
        return right(responseModel);
      });
    } catch (e) {
      debugPrint(
          "ERROR IN UPDATE AUTH: $e : with stackTrace : ${StackTrace.current}");
      debugPrint('UPDATE AUTH ERROR: ${StackTrace.fromString(e.toString())}');
      return left(
        Failure(
          message: "Failed to update auth. Please try again.",
          stackTrace: StackTrace.fromString(e.toString()),
        ),
      );
    }
  }

  FutureEither<bool> verifyOtp(
      {required String phoneNumber, required String otp}) async {
    var result = await api.makeRequest(
      enpoint: APIEndpoints.verifyOtp(phoneNumber: phoneNumber, otp: otp),
      method: RequestMethod.getRequest,
    );

    return result.fold(
      (error) => left(error),
      (responseModel) {
        return right(responseModel.success);
      },
    );
  }

  FutureEither<LoginModel> _login(AuthRequestBody authModel) async {
    var result = await api.makeRequest(
      enpoint: APIEndpoints.userLogin,
      method: RequestMethod.post,
      body: authModel.toJson(),
      requireAccessToken: false,
    );

    return result.fold((error) => left(error), (responseModel) {
      debugPrint("HERE IN THE LOGIN THING: ${responseModel.toJson()}");
      return right(
        LoginModel.fromJson(responseModel.data),
      );
    });
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
}
