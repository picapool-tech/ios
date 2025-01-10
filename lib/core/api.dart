import 'dart:convert';

import 'package:picapool/core/env_constants.dart';
import 'package:picapool/models/response_model.dart';
import 'package:http/http.dart' as http;

enum RequestMethod {
  post,
  get,
  patch,
  delete,
}

class PicapoolApi {
  static String baseUrl = APIConstants.apiUrl;

  Future<ResponseModel?> makeRequest({
    required String enpoint,
    required RequestMethod method,
    bool requireAccessToken = true,
    Object? body,
  }) async {
    try {      var accessToken = "";

      late http.Response response;
      var headers = (requireAccessToken)
          ? {'Authorization': 'Bearer $accessToken'}
          : null;

      var requestBody = (body != null) ? jsonEncode(body) : null;

      switch (method) {
        case RequestMethod.post:
          response = await http.post(Uri.parse("$baseUrl$enpoint"),
              headers: headers, body: requestBody);
          break;
        case RequestMethod.get:
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

      if (response.statusCode > 500) {
        return null;
      }

      var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
      return responseModel;
    } catch (e) {
      // todo all the errors here
    }
    return null;
  }
}
