import 'package:flutter/foundation.dart';

// Helper function for parsing a list with compute
List<T> _parseListInBackground<T>(
    T Function(Map<String, dynamic>) decoder, List<dynamic> data) {
  return data.map((item) => decoder(item)).toList();
}

// Helper function for parsing a single object with compute
T _parseSingleObjectInBackground<T>(
    T Function(Map<String, dynamic>) decoder, Map<String, dynamic> data) {
  return decoder(data);
}

class ResponseModel {
  final String message;
  final bool success;
  final dynamic data;

  ResponseModel({
    required this.message,
    required this.success,
    required this.data,
  });
  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      message: json['message'],
      success: json['success'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
      'data': data,
    };
  }
}

extension ResponseModelHelpers on ResponseModel {
  /// Parses the data field to a specific model type using compute
  ///
  /// Example: `final user = await response.parseData<User>(User.fromJson);`
  Future<T> parseData<T>(T Function(Map<String, dynamic>) fromJson) async {
    if (data == null) {
      throw Exception('Data is null');
    }

    if (data is! Map<String, dynamic>) {
      throw Exception('Data is not a valid JSON object');
    }

    return await compute(
        (arg) => _parseSingleObjectInBackground<T>(fromJson, arg),
        data as Map<String, dynamic>);
  }

  /// Parses the data field as a list of a specific model type using compute
  ///
  /// Example: `final users = await response.parseDataList<User>(User.fromJson);`
  Future<List<T>> parseDataList<T>(
      T Function(Map<String, dynamic>) fromJson) async {
    if (data == null) {
      return [];
    }

    if (data is! List) {
      throw Exception('Data is not a valid JSON array');
    }

    return await compute((arg) => _parseListInBackground<T>(fromJson, arg),
        data as List<dynamic>);
  }

  /// Safely accesses a specific field from data and parses it to a model type
  ///
  /// Example: `final profile = await response.parseField<Profile>('userProfile', Profile.fromJson);`
  Future<T> parseField<T>(
      String fieldName, T Function(Map<String, dynamic>) fromJson) async {
    if (data == null || data is! Map<String, dynamic>) {
      throw Exception('Data is null or not a valid JSON object');
    }

    if (!data.containsKey(fieldName)) {
      throw Exception('Field $fieldName not found in data');
    }

    final fieldData = data[fieldName];
    if (fieldData is! Map<String, dynamic>) {
      throw Exception('Field $fieldName is not a valid JSON object');
    }

    return await compute(
      (arg) => _parseSingleObjectInBackground<T>(fromJson, arg),
      fieldData,
    );
  }

  /// Safely accesses a specific field containing a list and parses it to a list of model type
  ///
  /// Example: `final comments = await response.parseFieldList<Comment>('comments', Comment.fromJson);`
  Future<List<T>> parseFieldList<T>(
      String fieldName, T Function(Map<String, dynamic>) fromJson) async {
    if (data == null || data is! Map<String, dynamic>) {
      throw Exception('Data is null or not a valid JSON object');
    }

    if (!data.containsKey(fieldName)) {
      throw Exception('Field $fieldName not found in data');
    }

    final fieldData = data[fieldName];
    if (fieldData is! List) {
      throw Exception('Field $fieldName is not a valid JSON array');
    }

    return await compute(
        (arg) => _parseListInBackground<T>(fromJson, arg), fieldData);
  }
}
