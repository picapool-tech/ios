import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:picapool/core/core.dart';
import 'package:picapool/core/env_constants.dart';
import 'package:picapool/features/network/connection_status_listener.dart';
import 'package:picapool/features/tokens/token_service.dart';
import 'package:picapool/models/response_model.dart';

class PicapoolApi {
  static String baseUrl = APIConstants.apiUrl;
  bool _hasRetired = false;
  final AuthTokenService _authTokenService = Get.find<AuthTokenService>();

  FutureEither<ResponseModel> makeRequest({
    required String enpoint,
    required RequestMethod method,
    bool requireAccessToken = true,
    Object? body,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      if (!await ConnectionStatusListener.getInstance().checkConnection()) {
        return left(
          Failure(
            message: "No Internet Connection",
            stackTrace: StackTrace.current,
            showError: false,
          ),
        );
      }

      String? accessToken;
      if (_authTokenService.isGuest) {
        return left(
          Failure(
            message: "Guest User",
            stackTrace: StackTrace.current,
            showError: false,
          ),
        );
      }
      if (requireAccessToken) {
        log("Getting Access Token from Storage", name: "Network Request");
        accessToken = await _authTokenService.getAccessToken();
      }

      log("ACCESS TOKEN : $accessToken", name: 'Network Request');

      if (requireAccessToken && accessToken == null) {
        return left(
          Failure(
            message: "No Access Token",
            stackTrace: StackTrace.current,
            showError: false,
          ),
        );
      }

      // if (!_hasRetired) {
      //   accessToken =
      //       "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdXRoSWQiOjIzMywidGVuYW50Ijp7InR5cGUiOiJVc2VyIiwiaWQiOjIyOX0sIlJvbGVzIjpbeyJpZCI6Mywicm9sZSI6IlVzZXIifV0sImlhdCI6MTczOTAzNzM0NCwiZXhwIjoxNzM5MTE4MzI4fQ.";
      // }

      debugPrint("using access token: $accessToken");
      log("Making request to $baseUrl$enpoint", name: "Network Request");

      late http.Response response;
      Map<String, String>? headers = (requireAccessToken)
          ? {
              'Authorization': 'Bearer ${accessToken!}',
              ...additionalHeaders ?? {},
            }
          : null;

      var requestBody = (body != null) ? jsonEncode(body) : null;

      log("Request Body: ${requestBody ?? "Empty"}", name: "Network Request");

      switch (method) {
        case RequestMethod.post:
          response = await http.post(
            Uri.parse("$baseUrl$enpoint"),
            headers: headers,
            body: requestBody,
          );
          break;
        case RequestMethod.getRequest:
          response = await http.get(
            Uri.parse("$baseUrl$enpoint"),
            headers: headers,
          );
          break;
        case RequestMethod.delete:
          response = await http.delete(
            Uri.parse("$baseUrl$enpoint"),
            headers: headers,
            body: requestBody,
          );
          break;
        case RequestMethod.patch:
          response = await http.patch(
            Uri.parse("$baseUrl$enpoint"),
            headers: headers,
            body: requestBody,
          );
          break;
      }

      log("Response: ${response.body}", name: "Network Request");

      if (response.statusCode > 500) {
        return left(
          Failure(message: "Server Error", stackTrace: StackTrace.current),
        );
      }

      if (response.statusCode == 401) {
        debugPrint("GETTING ACCESS TOKEN AGAIN");
        var newAccessToken = await _authTokenService.getAccessToken();
        if (newAccessToken == null || newAccessToken == accessToken) {
          return left(
            Failure(
              message: "Unauthorized",
              stackTrace: StackTrace.current,
              showError: false,
            ),
          );
        }

        if (_hasRetired) {
          _hasRetired = false;
          return left(
            Failure(
              message: "Unauthorized",
              stackTrace: StackTrace.current,
              showError: false,
            ),
          );
        }

        _hasRetired = true;

        var response = await makeRequest(
          enpoint: enpoint,
          method: method,
          body: body,
          additionalHeaders: additionalHeaders,
        );

        if (response.isLeft()) {
          return left(
            Failure(
              message: "Unauthorized",
              stackTrace: StackTrace.current,
              showError: false,
            ),
          );
        }

        return response;
      }

      if (response.statusCode < 200 && response.statusCode > 300) {
        return left(
          Failure(message: "Server Error", stackTrace: StackTrace.current),
        );
      }

      var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
      _hasRetired = false;
      return right(responseModel);
    } catch (e) {
      // todo all the errors here
      log("ERROR ON NETWORK REQUEST: $e with Stacktrace : ${StackTrace.current}",
          name: "Network Request");

      return left(
        Failure(message: "$e", stackTrace: StackTrace.current),
      );
    }
  }
}

enum RequestMethod {
  post,
  getRequest,
  patch,
  delete,
}
