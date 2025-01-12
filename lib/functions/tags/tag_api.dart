import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/models/response_model.dart';
import 'package:picapool/models/tag_model.dart';
import 'package:http/http.dart' as http;

class TagApi {
  final PicapoolApi _api = PicapoolApi();
  FutureEither<List<Tag>> getAllTags({
    required String accessToken,
  }) async {
    try {
      final response = await _api.makeRequest(
        enpoint: APIEndpoints.getAllTags,
        method: RequestMethod.getRequest,
      );

      return response.fold((error) => left(error), (responseModel) {
        if (responseModel.success) {
          return right(
            responseModel.data.map<Tag>((tag) => Tag.fromJson(tag)).toList(),
          );
        } else {
          return left(Failure(
            message: responseModel.message,
            stackTrace: StackTrace.current,
          ));
        }
      });
    } catch (e) {
      debugPrint("Error while fetching all tags: $e");
      return left(Failure(
        message: "Error while fetching all tags: $e",
        stackTrace: StackTrace.current,
      ));
    }
  }

  FutureEither<Tag> getTag({
    required String accessToken,
    required int tagId,
  }) async {
    try {
      final response = await _api.makeRequest(
        enpoint: APIEndpoints.getTagById(tagId),
        method: RequestMethod.getRequest,
      );

      return response.fold((error) => left(error), (responseModel) {
        if (responseModel.success) {
          return right(Tag.fromJson(responseModel.data));
        } else {
          return left(Failure(
            message: responseModel.message,
            stackTrace: StackTrace.current,
          ));
        }
      });
    } catch (e) {
      debugPrint("Error while fetching tag: $e");
      return left(Failure(
        message: "Error while fetching tag: $e",
        stackTrace: StackTrace.current,
      ));
    }
  }
}
