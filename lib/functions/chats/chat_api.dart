import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:http/http.dart' as http;
import 'package:picapool/models/message_model.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/response_model.dart';
import 'package:picapool/models/user_model.dart';

class ChatAndOfferModel {
  Chat chat;
  Offer offer;

  ChatAndOfferModel({
    required this.chat,
    required this.offer,
  });
}

class ChatApi {
  FutureEither<List<ChatAndOfferModel>> getChats({
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
        List<ChatAndOfferModel> chats = [];
        var data = responseModel.data['Chats'];

        for (var chat in data) {
          debugPrint("chat: $chat");
          var offer = chat['Offer'];

          chats.add(
            ChatAndOfferModel(
              chat: Chat.fromJson(chat),
              offer: Offer.fromJson(offer),
            ),
          );
        }
        return right(chats);
      } else {
        return left(
          Failure(
            message: responseModel.message,
            stackTrace: StackTrace.current,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error on getChats: $e");
      return left(
        Failure(message: e.toString(), stackTrace: StackTrace.current),
      );
    }
  }

  FutureEither<List<Message>> getAllMessages({
    required String accessToken,
    required int chatId,
  }) async {
    try {
      var response = await http.get(
        Uri.parse('https://api.picapool.com/v2/chat/$chatId/messages'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
      if (responseModel.success) {
        List<Message> messages = [];
        var data = responseModel.data['Messages'];
        for (var chat in data) {
          messages.add(Message.fromJson(chat));
        }
        return right(messages);
      } else {
        return left(
          Failure(
            message: responseModel.message,
            stackTrace: StackTrace.current,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error on getAllMessages: $e");
      return left(
        Failure(message: e.toString(), stackTrace: StackTrace.current),
      );
    }
  }

  FutureEither<ChatAndOfferModel> createChatWithOfferId({
    required String accessToken,
    required int offerId,
    required int userId,
  }) async {
    try {
      var body = {
        "isMain": true,
        "offerId": offerId,
        "userIds": [
          userId,
        ]
      };

      debugPrint("${body}");
      var response = await http.post(
        Uri.parse("https://api.picapool.com/v2/chat"),
        headers: {
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode(body),
      );

      var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
      debugPrint("CREATE CHAT WITH OFFER ID: ${response.body}");
      if (responseModel.success) {
        var chat = Chat.fromJson(responseModel.data['chat']);
        var offer = Offer.fromJson(responseModel.data['offer']);
        return right(ChatAndOfferModel(chat: chat, offer: offer));
      } else {
        return left(
          Failure(
            message: responseModel.message,
            stackTrace: StackTrace.current,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error creating chat with offer id : $e");
      return left(
        Failure(
          message: "Error while creating chat with respective offer",
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  FutureEither<List<User>> getAllUsersInChat({
    required String accessToken,
    required int chatId,
  }) async {
    try {
      var response = await http.get(
        Uri.parse('https://api.picapool.com/v2/chat/$chatId/users'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      var responseModel = ResponseModel.fromJson(jsonDecode(response.body));

      if (responseModel.success) {
        List<User> users = [];
        var data = responseModel.data;
        for (var user in data) {
          users.add(User.fromJson(user));
        }
        return right(users);
      } else {
        return left(
          Failure(
            message: responseModel.message,
            stackTrace: StackTrace.current,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error on getAllUsersInChat: $e");
      return left(
        Failure(
          message: e.toString(),
          stackTrace: StackTrace.current,
        ),
      );
    }
  }
}
