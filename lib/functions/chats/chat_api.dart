import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:picapool/core/api.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:http/http.dart' as http;
import 'package:picapool/models/live_offer_model.dart';
import 'package:picapool/models/message_model.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/response_model.dart';
import 'package:picapool/models/user_model.dart';

class ChatAndOfferModel {
  Chat chat;
  Offer? offer;
  LiveOffer? liveOffer;

  ChatAndOfferModel({
    required this.chat,
    this.offer,
    this.liveOffer,
  });
}

class ChatApi {
  final PicapoolApi _api = PicapoolApi();

  FutureEither<List<ChatAndOfferModel>> getChats({
    required String accessToken,
  }) async {
    try {
      final response = await _api.makeRequest(
        enpoint: APIEndpoints.getUserChats,
        method: RequestMethod.getRequest,
        requireAccessToken: true,
      );

      return response.fold((error) {
        debugPrint("Error on getChats: $error");
        return left(error);
      }, (responseModel) {
        if (responseModel.success) {
          List<ChatAndOfferModel> chats = [];
          var data = responseModel.data['Chats'];

          for (var chat in data) {
            debugPrint("chat: $chat");
            var chatModel = Chat.fromJson(chat);
            debugPrint("adding chatModel");
            chats.add(
              ChatAndOfferModel(
                chat: chatModel,
                offer: chatModel.offer,
                liveOffer: chatModel.liveOffer,
              ),
            );
            debugPrint("Chat added...");
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
      });

      // final response = await http
      //     .get(Uri.parse('https://api.picapool.com/v2/user/chats'), headers: {
      //   'Authorization': 'Bearer $accessToken',
      // });
      // debugPrint('getChats response: ${response.body}');
      // log('getChats response: ${response.body}');
      // var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
      // if (responseModel.success) {
      //   List<ChatAndOfferModel> chats = [];
      //   var data = responseModel.data['Chats'];

      //   for (var chat in data) {
      //     debugPrint("chat: $chat");
      //     var chatModel = Chat.fromJson(chat);
      //     debugPrint("adding chatModel");
      //     chats.add(
      //       ChatAndOfferModel(
      //         chat: chatModel,
      //         offer: chatModel.offer,
      //         liveOffer: chatModel.liveOffer,
      //       ),
      //     );
      //     debugPrint("Chat added...");
      //   }
      //   return right(chats);
      // } else {
      //   return left(
      //     Failure(
      //       message: responseModel.message,
      //       stackTrace: StackTrace.current,
      //     ),
      //   );
      // }
    } catch (e) {
      debugPrint(
          "Error on getChats: $e with errorStack : \n ${StackTrace.current}");
      return left(
        Failure(
          message: e.toString(),
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  FutureEither<List<Message>> getAllMessages({
    required String accessToken,
    required int chatId,
  }) async {
    try {
      final response = await _api.makeRequest(
        enpoint: APIEndpoints.getAllMessagesOfChat(chatId),
        method: RequestMethod.getRequest,
      );

      // var response = await http.get(
      //   Uri.parse('https://api.picapool.com/v2/chat/$chatId/messages'),
      //   headers: {
      //     'Authorization': 'Bearer $accessToken',
      //   },
      // );

      return response.fold((error) => left(error), (responseModel) {
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
      });
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

      debugPrint("$body");

      final response = await _api.makeRequest(
        enpoint: APIEndpoints.createChat,
        method: RequestMethod.post,
        body: body,
      );

      // var response = await http.post(
      //   Uri.parse("https://api.picapool.com/v2/chat"),
      //   headers: {
      //     "Authorization": "Bearer $accessToken",
      //   },
      //   body: jsonEncode(body),
      // );

      return response.fold((error) => left(error), (responseModel) {
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
      });
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
      final response = await _api.makeRequest(
        enpoint: APIEndpoints.getAllUsersInChat(chatId),
        method: RequestMethod.getRequest,
      );

      return response.fold((error) => left(error), (responseModel) {
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
      });
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

  FutureEither<Chat> getChatFromLiveOfferId({
    required String accessToken,
    required int liveOfferId,
  }) async {
    try {
      final response = await _api.makeRequest(
        enpoint: APIEndpoints.getChatFromLiveOfferId(liveOfferId),
        method: RequestMethod.getRequest,
      );

      return response.fold((error) => left(error), (responseModel) {
        if (responseModel.success) {
          var chat = Chat.fromJson(responseModel.data);
          return right(chat);
        } else {
          return left(
            Failure(
              message: responseModel.message,
              stackTrace: StackTrace.current,
            ),
          );
        }
      });

      // var response = await http.get(
      //   Uri.parse("https://api.picapool.com/v2/chat/liveOffer/$liveOfferId"),
      //   headers: {
      //     "Authorization": "Bearer $accessToken",
      //   },
      // );

      // debugPrint("GET CHAT FROM LVIE OFFER ID RESPONSE: ${response.body}");
      
    } catch (e) {
      debugPrint("GET CAHT FROM LIVE OFFER ID ERROR: $e");
      return left(
        Failure(
          message: "Not able to get the chat for respective offer",
          stackTrace: StackTrace.current,
        ),
      );
    }
  }
}
