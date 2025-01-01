import 'dart:core';
import 'package:get/utils.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:picapool/utils/logger_helper.dart';

final GetStorage box = GetStorage();

Future<void> saveAccessToken(String accessToken) async {
  try {
    await box.write('accessToken', accessToken);
  } catch (e) {
    logger.printInfo(info: e.toString());
  }
}

Future<void> saveRefreshToken(String refreshToken) async {
  try {
    await box.write('refreshToken', refreshToken);
  } catch (e) {
    logger.printInfo(info: e.toString());
  }
}

Future<void> removeToken(String token) async {
  try {
    await box.remove(token);
  } catch (e) {
    logger.printInfo(info: e.toString());
  }
}

String? getToken(String tokenName) {
  try {
    // final String? token = box.read(tokenName);
    const String token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdXRoSWQiOjQsInRlbmFudCI6eyJ0eXBlIjoiVXNlciIsImlkIjoxMDR9LCJSb2xlcyI6W3siaWQiOjEsInJvbGUiOiJVc2VyIn1dLCJpYXQiOjE3MzUwNDc4NDQsImV4cCI6MTczNTEzNDI0NH0.ttUveH8-8p77VfVaBUGLHBE3lXX5-tMhPBEF7WQaZp8";
    return token;
  } catch (e) {
    logger.printInfo(info: e.toString());
    return null;
  }
}

bool? isTokenExpired(String tokenName) {
  final String? token = getToken(tokenName);
  {
    if (token != null) {
      if (Jwt.isExpired(token)) {
        return true;
      } else {
        return false;
      }
    }
    return null;
  }
}

Future<String?> getAccessToken() async {
  try {
    // TODO: Merge from Krishna's auth code
    // hardcoding for now
    final String? accessToken =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdXRoSWQiOjMsInRlbmFudCI6eyJ0eXBlIjoiVXNlciIsImlkIjoxMDd9LCJSb2xlcyI6W3siaWQiOjQsInJvbGUiOiJVc2VyIn1dLCJpYXQiOjE3MzE3Njc1ODcsImV4cCI6MTczMTg1Mzk4N30.hn4YBV5_bTuoQ1Zeh12AKUHwmuqy_DA5MAJhgmH6ZYg";
    // final String? token = getToken('accessToken');
    // if (token != null) {
    //   if (!Jwt.isExpired(token)) {
    //     return true;
    //   } else {
    //     final RefreshTokenResponse response =
    //         await AuthServices.refreshTokenService();
    //     if (response.success) {
    //       await saveAccessToken(response.data!.accessToken);
    //       await saveRefreshToken(response.data!.refreshToken);
    //       return true;
    //     } else {
    //       return false;
    //     }
    //   }
    // }
    return accessToken;
  } catch (e) {
    logger.printInfo(info: e.toString());
    return null;
  }
}

Future<void> rememberMe(bool? value) async {
  try {
    if (value!) {
      await box.write('rememberMe', true);
    } else {
      await box.write('rememberMe', false);
    }
  } catch (e) {
    logger.printInfo(info: e.toString());
  }
}

bool? checkRememberMe() {
  try {
    final bool? value = box.read('rememberMe');
    if (value != null) {
      if (value) {
        return value;
      } else {
        return value;
      }
    } else {
      return null;
    }
  } catch (e) {
    logger.printInfo(info: e.toString());
    return null;
  }
}

Future<void> initialOpen(bool newStart) async {
  try {
    await box.write('freshStart', newStart);
  } catch (e) {
    logger.printInfo(info: e.toString());
  }
}

bool readUser() {
  try {
    final bool? use = box.read('freshStart');
    if (use != null) {
      return true;
    }
    return false;
  } catch (e) {
    logger.printInfo(info: e.toString());
    return false;
  }
}

Future<void> storeResentSearch(List<String> searchTexts) async {
  await box.write('searchList', searchTexts);
}

List<String>? getResentSearches() {
  try {
    final Iterable<dynamic> list = box.read('searchList') as Iterable<dynamic>;
    return List<String>.from(list);
  } catch (e) {
    return null;
  }
}
