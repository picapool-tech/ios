import 'dart:convert';
import 'dart:developer';

import 'package:fpdart/fpdart.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:picapool/core/core.dart';
import 'package:picapool/core/env_constants.dart';
import 'package:picapool/functions/network/connection_status_listener.dart';
import 'package:picapool/functions/storage/storage_controller.dart';
import 'package:picapool/models/response_model.dart';

class PicapoolApi {
  static String baseUrl = APIConstants.apiUrl;
  final StorageController _storageController = Get.find<StorageController>();

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
      if (_storageController.isGuest.value) {
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
        accessToken = await _storageController.getAccessToken();
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

      if (response.statusCode < 200 && response.statusCode > 300) {
        return left(
          Failure(message: "Server Error", stackTrace: StackTrace.current),
        );
      }

      var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
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
