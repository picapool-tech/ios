import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:http/http.dart' as http;
import 'package:picapool/models/response_model.dart';

class ChatApi {
  FutureEither<List<Chat>> getChats({
    required String accessToken,
  }) async {
    try {
      final response = await http
          .get(Uri.parse('https://api.picapool.com/v2/user/chats'), headers: {
        'Authorization': 'Bearer $accessToken',
      });
      debugPrint('getChats response: ${response.body}');
      var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
      if (responseModel.success) {
        List<Chat> chats = [];
        var data = responseModel.data['Chats'];
        for (var chat in data) {
          debugPrint("chat: $chat");
          chats.add(Chat.fromJson(chat));
        }
        return right(chats);
      } else {
        return left(
          Failure(
              message: responseModel.message, stackTrace: StackTrace.current),
        );
      }
    } catch (e) {
      return left(
        Failure(message: e.toString(), stackTrace: StackTrace.current),
      );
    }
  }
}
