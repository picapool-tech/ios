import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:picapool/core/api_impl.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/models/response_model.dart';

class IdentityVerificationApi with PicapoolApiClass {
  FutureEither<ResponseModel> sendVerificaitionOtp({
    required int userId,
    required String email,
  }) async {
    final result = await api.makeRequest(
      useAltBaseUrl: true,
      altBaseUrl: "http://test-api.picapool.com/api",
      enpoint: APIEndpoints.identityVerificationOtp,
      method: RequestMethod.post,
      body: jsonEncode(
        {
          "userId": userId,
          "email": email,
        },
      ),
    );

    return result.fold(
      (error) => left(error),
      (responseModel) {
        return right(responseModel);
      },
    );
  }

  FutureEither<ResponseModel> verifyOtp({
    required int userId,
    required String otp,
  }) async {
    final result = await api.makeRequest(
      useAltBaseUrl: true,
      altBaseUrl: "http://test-api.picapool.com/api",
      enpoint: APIEndpoints.identityVerificationOtpVerify,
      method: RequestMethod.post,
      body: jsonEncode(
        {
          "userId": userId,
          "otp": otp,
        },
      ),
    );

    return result.fold(
      (error) => left(error),
      (responseModel) {
        return right(responseModel);
      },
    );
  }
}
