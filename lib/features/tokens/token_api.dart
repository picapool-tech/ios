import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/core/env_constants.dart';

class TokenApi {
  final Dio _dio = Dio();

  FutureEither<String> refreshAccessToken({
    required String refreshToken,
    String? oldAccessToken,
  }) async {
    debugPrint('REQUESTED FOR UPDATE ACCESS TOKEN');
    debugPrint('Refresh token: $refreshToken');

    try {
      // Prepare headers
      final Map<String, dynamic> headers = {
        'Content-Type': 'application/json',
      };

      // Add authorization header if we have an old token
      if (oldAccessToken != null) {
        headers['Authorization'] = 'Bearer $oldAccessToken';
      }

      // Make the request
      final response = await _dio.post(
        '${APIConstants.apiUrl}/auth/accessToken',
        data: {
          "refreshToken": refreshToken,
        },
        options: Options(headers: headers),
      );

      debugPrint('UPDATE ACCESS TOKEN RESPONSE STATUS: ${response.statusCode}');
      debugPrint("RESPONSE: ${response.data}");
      // Check for successful response
      if (response.statusCode! >= 200 && response.statusCode! < 300 && response.data != null) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final String newAccessToken = responseData['data']['newAccessToken'];
          debugPrint('New access token received successfully');
          return right(newAccessToken);
        } else {
          final String errorMessage =
              responseData['message'] ?? 'Unknown error refreshing token';
          debugPrint('Error refreshing token: $errorMessage');
          return left(
            Failure(
              message: errorMessage,
              stackTrace: StackTrace.current,
            ),
          );
        }
      } else {
        return left(
          Failure(
            message: 'Failed to refresh token. Status: ${response.statusCode}',
            stackTrace: StackTrace.current,
          ),
        );
      }
    } on DioException catch (e) {
      final String errorMessage = e.response?.data?['message'] ??
          e.message ??
          'Network error refreshing token';
      debugPrint('Dio error updating access token: $errorMessage');
      return left(
        Failure(
          message: errorMessage,
          stackTrace: StackTrace.current,
        ),
      );
    } catch (e) {
      debugPrint('Error updating access token: $e');
      return left(
        Failure(
          message: "Not able to refresh the access token",
          stackTrace: StackTrace.fromString(e.toString()),
        ),
      );
    }
  }
}
