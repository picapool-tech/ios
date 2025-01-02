import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:picapool/core/core.dart';
import 'package:picapool/models/response_model.dart';
import 'package:picapool/models/user_model.dart';

class UserApi {
  FutureEither<bool> updateUser(
      Map<String, dynamic> updateValues, String accessToken) async {
    try {
      const String url = "https://api.picapool.com/v2/user/update";

      debugPrint("Updated Values: $updateValues");

      debugPrint("Access token : $accessToken");
      // var body = {

      //     ...updateValues,

      // };

      debugPrint(updateValues.toString());

      http.Response response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: jsonEncode(updateValues),
      );

      var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
      debugPrint('User Updated: ${response.body}');
      if (responseModel.success) {
        return right(true);
      } else {
        debugPrint(
            'Update User Error: ${response.statusCode} with response ${response.body}');
        return left(
          Failure(
            message: responseModel.message,
            stackTrace: StackTrace.current,
          ),
        );
      }
    } catch (e) {
      debugPrint('Update User Error: $e');
      return left(
        Failure(
          message: "Failed to update user details. Please try again.",
          stackTrace: StackTrace.fromString(
            e.toString(),
          ),
        ),
      );
    }
  }

  FutureEither<User> getUser(
      {required int userId, required String accessToken}) async {
    try {
      var response = await http.get(
        Uri.parse('https://api.picapool.com/v2/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );
      int statusCode = response.statusCode;
      if (statusCode >= 200 && statusCode <= 300) {
        var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
        debugPrint("getUser Response: ${response.body}");
        if (responseModel.success) {
          var user = User.fromJson(responseModel.data);
          return right(user);
        } else {
          return left(
            Failure(
              message: responseModel.message,
              stackTrace: StackTrace.current,
            ),
          );
        }
      } else {
        debugPrint(
          'Not able to get the user : status code $statusCode',
        );

        return left(
          Failure(
            message:
                "Not able to get the user : status code ${response.statusCode} with me",
            stackTrace: StackTrace.current,
          ),
        );
      }
    } catch (e) {
      debugPrint('Get User Error: $e');
      return left(
        Failure(
          message: "Not able to get the user : status code $e",
          stackTrace: StackTrace.current,
        ),
      );
    }
  }
}
