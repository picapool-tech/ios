import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:picapool/core/api_impl.dart';

import '../../core/core.dart';

class FeedbackApi with PicapoolApiClass {
  FutureEither sendFeedback({
    required String feedback,
  }) async {
    // Send feedback to the server
    try {
      final response = await api.makeRequest(
        enpoint: APIEndpoints.sendFeedback,
        method: RequestMethod.post,
        body: {'feedback': feedback},
      );

      return response.fold((error) => left(error), (responseModel) {
        if (responseModel.success) {
          return right(responseModel);
        } else {
          return left(Failure(
            message: responseModel.message,
            stackTrace: StackTrace.current,
          ));
        }
      });
    } catch (e) {
      debugPrint("Error on sendFeedback: $e");
      return left(Failure(
        message: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }
}
