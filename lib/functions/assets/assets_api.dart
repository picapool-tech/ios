import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:picapool/models/response_model.dart';
import '../../core/core.dart';
import 'package:http/http.dart' as http;

class AssetsApi {
  FutureEither<String> uploadImageToServer({
    XFile? pickedFile,
    required String fileName,
    required String accessToken,
  }) async {
    if (pickedFile == null) {
      return left(Failure(
          message: "No image selected", stackTrace: StackTrace.current));
    }
    try {
      debugPrint("Uploading image to server at : $accessToken");
      Uri endpoint = Uri.parse('https://api.picapool.com/v2/s3/upload');

      MediaType? contentType;
      String? ext = path.extension(pickedFile.path).toLowerCase();
      debugPrint("Uploading image to server ext : $ext");
      if (ext == '.jpg' || ext == '.jpeg') {
        contentType = MediaType('image', 'jpeg');
      } else if (ext == '.png') {
        contentType = MediaType('image', 'png');
      }
      debugPrint("Uploading image to server content type : $contentType");
      var request = http.MultipartRequest('POST', endpoint);
      String fileName = path.basename(pickedFile.path);

      debugPrint("Uploading image to server fileName : $fileName");

      request.fields['key'] = 'images/pool/$fileName';

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        pickedFile.path,
        contentType: contentType,
        filename: fileName,
      ));
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $accessToken',
      });

      var response = await request.send();

      var responseModel = ResponseModel.fromJson(
          jsonDecode(await response.stream.bytesToString()));

      if (!responseModel.success) {
        return left(
          Failure(
            message: responseModel.message,
            stackTrace: StackTrace.current,
          ),
        );
      }

      var url = responseModel.data['url'];
      debugPrint(
          "Uploading image to server response : ${responseModel.data} with url : $url");
      return right(url);
    } catch (e) {
      debugPrint('Error uploading image to server: $e');
      return left(
        Failure(
          message: "Failed to upload image",
          stackTrace: StackTrace.current,
        ),
      );
    }
  }
}
