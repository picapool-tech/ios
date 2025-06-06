import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:picapool/core/core.dart';
import 'package:picapool/core/env_constants.dart';
import 'package:picapool/features/network/connection_status_listener.dart';
import 'package:picapool/features/tokens/token_service.dart';
import 'package:picapool/models/response_model.dart';
import 'package:picapool/utils/image_utils.dart';

class PicapoolApi {
  static String baseUrl = APIConstants.apiUrl;
  bool _hasRetired = false;
  final AuthTokenService _tokenService = Get.find<AuthTokenService>();
  late final dio.Dio _dio;

  PicapoolApi() {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: dio.Headers.jsonContentType,
      responseType: dio.ResponseType.json,
    ));

    // Add interceptor for logging
    _dio.interceptors.add(dio.LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  FutureEither<ResponseModel> makeRequest({
    String? altBaseUrl,
    required String enpoint,
    required RequestMethod method,
    bool requireAccessToken = true,
    bool useAltBaseUrl = false,
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
      if (_tokenService.isGuest) {
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
        accessToken = await _tokenService.getAccessToken();
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

      // Configure headers
      Map<String, dynamic> headers = {};
      if (requireAccessToken && accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      // Configure options
      dio.Options options = dio.Options(headers: headers);
      debugPrint("body: $body");
      if (useAltBaseUrl) {
        _dio.options.baseUrl = altBaseUrl ?? baseUrl;
      } else {
        _dio.options.baseUrl = baseUrl;
      }

      dio.Response response;
      try {
        switch (method) {
          case RequestMethod.post:
            response = await _dio.post(enpoint, data: body, options: options);
            break;
          case RequestMethod.getRequest:
            response = await _dio.get(enpoint, options: options);
            break;
          case RequestMethod.delete:
            response = await _dio.delete(enpoint, data: body, options: options);
            break;
          case RequestMethod.patch:
            response = await _dio.patch(enpoint, data: body, options: options);
            break;
        }

        ResponseModel responseModel;
        try {
          responseModel = ResponseModel.fromJson(response.data);
        } catch (e) {
          responseModel = ResponseModel(
            message: "",
            success: response.statusCode == 200,
            data: response.data,
          );
        }

        _hasRetired = false;
        return right(responseModel);
      } on dio.DioException catch (e) {
        if (e.response?.statusCode == 401) {
          debugPrint("GETTING ACCESS TOKEN AGAIN");
          var newAccessToken = await _tokenService.getAccessToken();
          if (newAccessToken == null || newAccessToken == accessToken) {
            return left(
              Failure(
                message: "Session expired. Please login again.",
                stackTrace: StackTrace.current,
                showError: true,
              ),
            );
          }

          if (_hasRetired) {
            _hasRetired = false;
            return left(
              Failure(
                message: "Authentication failed. Please login again.",
                stackTrace: StackTrace.current,
                showError: true,
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
                message: "Authentication failed after retry.",
                stackTrace: StackTrace.current,
                showError: true,
              ),
            );
          }

          return response;
        } else if (e.response != null) {
          // Server returned error response
          final statusCode = e.response?.statusCode;
          final responseData = e.response?.data;

          if (statusCode != null && statusCode >= 500) {
            return left(
              Failure(
                message: "Server Error: Please try again later.",
                stackTrace: StackTrace.current,
                showError: true,
                errorCode: statusCode,
              ),
            );
          }

          String errorMessage = "Request failed";
          if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['message'] ??
                responseData['error'] ??
                "Unknown error occurred";
          }

          return left(
            Failure(
              message: errorMessage,
              stackTrace: StackTrace.current,
              showError: true,
              errorCode: statusCode,
            ),
          );
        } else if (e.type == dio.DioExceptionType.connectionTimeout) {
          return left(
            Failure(
              message: "Connection timeout. Please check your internet.",
              stackTrace: StackTrace.current,
              showError: true,
            ),
          );
        } else if (e.type == dio.DioExceptionType.receiveTimeout) {
          return left(
            Failure(
              message: "Server took too long to respond.",
              stackTrace: StackTrace.current,
              showError: true,
            ),
          );
        } else if (e.type == dio.DioExceptionType.sendTimeout) {
          return left(
            Failure(
              message: "Request timeout. Please try again.",
              stackTrace: StackTrace.current,
              showError: true,
            ),
          );
        } else if (e.type == dio.DioExceptionType.cancel) {
          return left(
            Failure(
              message: "Request was cancelled.",
              stackTrace: StackTrace.current,
              showError: false,
            ),
          );
        } else {
          return left(
            Failure(
              message: "Network error: ${e.message}",
              stackTrace: StackTrace.current,
              showError: true,
            ),
          );
        }
      }
    } catch (e) {
      // Handle non-Dio exceptions
      log("CRITICAL ERROR ON NETWORK REQUEST: $e with Stacktrace: ${StackTrace.current}",
          name: "Network Request");

      String errorMessage = "An unexpected error occurred";

      if (e is SocketException) {
        errorMessage = "Network connection error. Please check your internet.";
      } else if (e is FormatException) {
        errorMessage = "Data format error. Please contact support.";
      } else if (e is dio.DioException &&
          e.type == dio.DioExceptionType.badResponse) {
        errorMessage = "Error parsing server response.";
      }

      return left(
        Failure(
          message: errorMessage,
          stackTrace: StackTrace.current,
          showError: true,
          originalError: e,
        ),
      );
    }
  }

  FutureEither<String> uploadFile({
    required File file,
    XFile? pickedFile,
    required String uploadPath,
    required String fileName,
    bool requireAccessToken = true,
    bool compressImage = true,
    Map<String, String>? additionalFields,
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
      if (requireAccessToken) {
        if (_tokenService.isGuest) {
          return left(
            Failure(
              message: "Guest User",
              stackTrace: StackTrace.current,
              showError: false,
            ),
          );
        }

        accessToken = await _tokenService.getAccessToken();
        if (accessToken == null) {
          return left(
            Failure(
              message: "No Access Token",
              stackTrace: StackTrace.current,
              showError: false,
            ),
          );
        }
      }

      // If needed, compress the image
      File fileToUpload = file;
      if (compressImage &&
          file.lengthSync() > 1000000 &&
          file.path.endsWith(
              RegExp(r'\.(jpg|jpeg|png)$', caseSensitive: false).pattern)) {
        fileToUpload = ImageUtils.compressAndResizeImage(file);
      }

      // Determine content type based on file extension
      String ext = path.extension(fileToUpload.path).toLowerCase();
      String mimeType = 'application/octet-stream'; // Default content type

      if (ext == '.jpg' || ext == '.jpeg') {
        mimeType = 'image/jpeg';
      } else if (ext == '.png') {
        mimeType = 'image/png';
      } else if (ext == '.pdf') {
        mimeType = 'application/pdf';
      }

      // Create FormData
      dio.FormData formData = dio.FormData();

      // Add file
      formData.files.add(
        MapEntry(
          'file',
          await dio.MultipartFile.fromFile(
            fileToUpload.path,
            contentType: MediaType.parse(mimeType),
          ),
        ),
      );

      // Add key field for S3 path
      formData.fields.add(MapEntry('key', '$uploadPath/$fileName'));

      // Add any additional fields
      additionalFields?.forEach((key, value) {
        formData.fields.add(MapEntry(key, value));
      });

      // Configure headers
      Map<String, dynamic> headers = {};
      if (requireAccessToken && accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      // Make the request
      dio.Response response = await _dio.post(
        '/s3/upload',
        data: formData,
        options: dio.Options(headers: headers),
      );

      var responseModel = ResponseModel.fromJson(response.data);

      if (!responseModel.success) {
        return left(
          Failure(
            message: responseModel.message,
            stackTrace: StackTrace.current,
          ),
        );
      }

      var url = responseModel.data['url'];
      return right(url);
    } catch (e) {
      debugPrint('Error uploading file: $e');

      String errorMessage = "Failed to upload file";
      if (e is dio.DioException) {
        if (e.response != null) {
          errorMessage = e.response?.data?['message'] ?? errorMessage;
        } else if (e.type == dio.DioExceptionType.connectionTimeout) {
          errorMessage = "Connection timeout during upload";
        }
      }

      return left(
        Failure(
          message: errorMessage,
          stackTrace: StackTrace.current,
          originalError: e,
        ),
      );
    }
  }

  /// Uploads multiple files in a single request
  /// Returns a list of URLs for the uploaded files
  FutureEither<List<String>> uploadMultipleFiles({
    required List<File> files,
    required String uploadPath,
    String? fileNamePrefix,
    bool requireAccessToken = true,
    bool compressImage = true,
    Map<String, String>? additionalFields,
  }) async {
    log("Starting uploadMultipleFiles with ${files.length} files",
        name: "FileUpload");
    try {
      // Early return for empty list
      if (files.isEmpty) {
        log("No files to upload, returning empty list", name: "FileUpload");
        return right([]);
      }

      log("Checking internet connection", name: "FileUpload");
      if (!await ConnectionStatusListener.getInstance().checkConnection()) {
        log("No internet connection available", name: "FileUpload");
        return left(
          Failure(
            message: "No Internet Connection",
            stackTrace: StackTrace.current,
            showError: false,
          ),
        );
      }

      // Get access token once (shared for all files)
      String? accessToken;
      if (requireAccessToken) {
        log("Access token required, checking authentication",
            name: "FileUpload");
        if (_tokenService.isGuest) {
          log("Upload rejected: Guest user", name: "FileUpload");
          return left(
            Failure(
              message: "Guest User",
              stackTrace: StackTrace.current,
              showError: false,
            ),
          );
        }

        accessToken = await _tokenService.getAccessToken();
        log("Retrieved access token: ${accessToken != null ? 'Success' : 'Failed'}",
            name: "FileUpload");
        if (accessToken == null) {
          log("Upload rejected: No access token available", name: "FileUpload");
          return left(
            Failure(
              message: "No Access Token",
              stackTrace: StackTrace.current,
              showError: false,
            ),
          );
        }
      }

      // Process all files at once using functional programming
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final prefix = fileNamePrefix ?? 'upload';
      log("Using file prefix: $prefix with timestamp: $timestamp",
          name: "FileUpload");

      // Create single FormData instance for entire batch
      log("Creating FormData for batch upload", name: "FileUpload");
      final dio.FormData formData = dio.FormData();

      // Add all files to FormData (using iterable mapping instead of loops)
      log("Processing ${files.length} files for upload to path: $uploadPath",
          name: "FileUpload");
      formData.files.addAll(
        files.asMap().entries.map((entry) {
          final index = entry.key;
          final file = entry.value;
          log("Processing file ${index + 1}/${files.length}: ${file.path}",
              name: "FileUpload");

          // Process file if needed (compression)
          File fileToUpload = file;
          if (compressImage &&
              file.lengthSync() > 1 * 1024 * 1024 && // 1 MB threshold
              file.path.endsWith(
                  RegExp(r'\.(jpg|jpeg|png)$', caseSensitive: false).pattern)) {
            log("Compressing large image file: ${file.path}",
                name: "FileUpload");
            fileToUpload = ImageUtils.compressAndResizeImage(file);
            log("Compressed size: ${fileToUpload.lengthSync()} bytes",
                name: "FileUpload");
          }

          // Generate unique filename
          final fileName =
              "${prefix}_${index + 1}_$timestamp${path.extension(file.path)}";
          log("Generated filename: $fileName", name: "FileUpload");

          // Determine content type
          final ext = path.extension(fileToUpload.path).toLowerCase();
          String mimeType = 'application/octet-stream';

          if (ext == '.jpg' || ext == '.jpeg') {
            mimeType = 'image/jpeg';
          } else if (ext == '.png') {
            mimeType = 'image/png';
          } else if (ext == '.pdf') {
            mimeType = 'application/pdf';
          }
          log("File type: $mimeType", name: "FileUpload");

          // Add path information to form data for this file
          formData.fields
              .add(MapEntry('keys[$index]', '$uploadPath/$fileName'));

          // Return the file entry
          return MapEntry(
              'files[$index]',
              dio.MultipartFile.fromFileSync(
                fileToUpload.path,
                contentType: MediaType.parse(mimeType),
              ));
        }).toList(),
      );

      // Add any additional fields
      if (additionalFields != null) {
        log("Adding ${additionalFields.length} additional fields to request",
            name: "FileUpload");
        additionalFields.forEach((key, value) {
          formData.fields.add(MapEntry(key, value));
        });
      }

      // Configure headers
      Map<String, dynamic> headers = {};
      if (requireAccessToken && accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
        log("Added authorization header", name: "FileUpload");
      }

      // Make a single request for all files
      log("Sending batch upload request to /s3/upload/batch",
          name: "FileUpload");
      dio.Response response = await _dio.post(
        '/s3/upload', // Adjust endpoint as needed for batch uploads
        data: formData,
        options: dio.Options(headers: headers),
      );

      log("Received response with status: ${response.statusCode}",
          name: "FileUpload");
      var responseModel = ResponseModel.fromJson(response.data);

      if (!responseModel.success) {
        log("Upload failed: ${responseModel.message}", name: "FileUpload");
        return left(
          Failure(
            message: responseModel.message,
            stackTrace: StackTrace.current,
          ),
        );
      }

      // Extract all URLs from response
      final List<String> urls = (responseModel.data['urls'] as List<dynamic>)
          .map((url) => url.toString())
          .toList();

      log("Successfully uploaded ${urls.length} files", name: "FileUpload");
      debugPrint("Upload URLs: $urls");

      return right(urls);
    } catch (e) {
      log("Error uploading multiple files: $e", name: "FileUpload", error: e);
      debugPrint('Error uploading multiple files: $e');

      String errorMessage = "Failed to upload files";
      if (e is dio.DioException) {
        if (e.response != null) {
          errorMessage = e.response?.data?['message'] ?? errorMessage;
          log("DioException with response: ${e.response?.statusCode} - $errorMessage",
              name: "FileUpload", error: e);
        } else if (e.type == dio.DioExceptionType.connectionTimeout) {
          errorMessage = "Connection timeout during upload";
          log("DioException: Connection timeout", name: "FileUpload", error: e);
        } else {
          log("DioException type: ${e.type}", name: "FileUpload", error: e);
        }
      }

      return left(
        Failure(
          message: errorMessage,
          stackTrace: StackTrace.current,
          originalError: e,
        ),
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
