import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:picapool/models/response_model.dart';

import '../../core/core.dart';
import "package:http/http.dart" as http;

class FeedbackApi {
  FutureEither sendFeedback({
    required String accessToken,
    required String feedback,
  }) async {
    // Send feedback to the server
    try {
      final response =
          await http.post(Uri.parse('https://api.picapool.com/v2/feedback'),
              body: jsonEncode(
                {'feedback': feedback},
              ),
              headers: {'Authorization': "Bearer $accessToken"});

      var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
      if (responseModel.success) {
        return right(responseModel);
      } else {
        return left(Failure(
          message: responseModel.message,
          stackTrace: StackTrace.current,
        ));
      }
    } catch (e) {
      debugPrint("Error on sendFeedback: $e");
      return left(Failure(
        message: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }
}
