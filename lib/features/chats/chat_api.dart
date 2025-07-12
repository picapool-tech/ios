import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:picapool/core/api_impl.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/live_offer_model.dart';
import 'package:picapool/models/message_model.dart';
import 'package:picapool/models/message_read_model.dart';
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

  factory ChatAndOfferModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      ChatAndOfferModel(
        chat: Chat.fromJson(json),
        offer: json['Offer'] != null ? Offer.fromJson(json['Offer']) : null,
        liveOffer: json['LiveOffer'] != null
            ? LiveOffer.fromJson(json['LiveOffer'])
            : null,
      );

  String get chatTitle =>
      chat.offer?.name.replaceAll("- FROM BRANDS", "") ??
      'To:  ${chat.liveOffer?.to}';

  String get getImage {
    if (chat.offer != null) {
      var offer = chat.offer;
      if (offer!.images.isNotEmpty) {
        return offer.images.first;
      } else {
        return "assets/icons/Frame 64.png";
      }
    } else if (chat.liveOffer != null) {
      return "assets/images/share_a_cab.png";
    } else {
      return "assets/icons/Frame 64.png";
    }
  }

  ImageProvider get getImageProvider {
    if (chat.offer != null) {
      var offer = chat.offer;
      if (offer!.images.isNotEmpty) {
        return CachedNetworkImageProvider(offer.images.first);
      } else {
        return const AssetImage("assets/icons/Frame 64.png");
      }
    } else if (chat.liveOffer != null) {
      return const AssetImage("assets/images/share_a_cab.png");
    } else {
      return const AssetImage("assets/icons/Frame 64.png");
    }
  }

  bool get hasImage {
    if (chat.offer != null) {
      var offer = chat.offer;
      if (offer!.images.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } else if (chat.liveOffer != null) {
      return true;
    } else {
      return false;
    }
  }
}

class ChatApi with PicapoolApiClass {
  FutureEither<ChatAndOfferModel> createChatWithOfferId({
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

      final response = await api.makeRequest(
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

  FutureEither<List<Message>> getAllMessages({
    required int chatId,
  }) async {
    try {
      final response = await api.makeRequest(
        enpoint: APIEndpoints.getAllMessagesOfChat(chatId),
        method: RequestMethod.getRequest,
      );

      // var response = await http.get(
      //   Uri.parse('https://api.picapool.com/v2/chat/$chatId/messages'),
      //   headers: {
      //     'Authorization': 'Bearer $accessToken',
      //   },
      // );

      return response.fold((error) => left(error), (responseModel) async {
        log("${responseModel.toJson()}");
        if (responseModel.success) {
          List<Message> messages = await responseModel.parseFieldList<Message>(
            "Messages",
            Message.fromJson,
          );
          // var data = responseModel.data['Messages'];
          // for (var chat in data) {
          //   messages.add(Message.fromJson(chat));
          // }
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

  FutureEither<Map<int, User>> getAllUsersInChat({
    required int chatId,
  }) async {
    try {
      final response = await api.makeRequest(
        enpoint: APIEndpoints.getAllUsersInChat(chatId),
        method: RequestMethod.getRequest,
      );

      return response.fold((error) => left(error), (responseModel) {
        if (responseModel.success) {
          Map<int, User> users = {};
          var data = responseModel.data;
          for (var user in data) {
            var userModel = User.fromJson(user);
            users.addAll({userModel.id: userModel});
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

  FutureEither<ChatAndOfferModel> getChatFromLiveOfferId({
    required int liveOfferId,
  }) async {
    try {
      final response = await api.makeRequest(
        enpoint: APIEndpoints.getChatFromLiveOfferId(liveOfferId),
        method: RequestMethod.getRequest,
      );

      return response.fold((error) => left(error), (responseModel) {
        if (responseModel.success) {
          return right(
            ChatAndOfferModel.fromJson(
              responseModel.data,
            ),
          );
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

  FutureEither<Chat> getChatWithId({
    required int chatId,
  }) async {
    var response = await api.makeRequest(
      enpoint: APIEndpoints.getChatById(chatId),
      method: RequestMethod.getRequest,
    );

    return response.fold((error) => left(error), (responseModel) async {
      var chat = await responseModel.parseData<Chat>(Chat.fromJson);
      return right(chat);
    });
  }

  FutureEither<List<MessageReadModel>> getMessageReadInfo(
      {required int messageId}) async {
    try {
      final response = await api.makeRequest(
        enpoint: APIEndpoints.getReadMessageInfo(messageId),
        method: RequestMethod.getRequest,
      );

      return response.fold(
        (error) => left(error),
        (responseModel) async {
          if (responseModel.success) {
            List<MessageReadModel> messageReadModels =
                await responseModel.parseDataList<MessageReadModel>(
              MessageReadModel.fromJson,
            );
            return right(messageReadModels);
          } else {
            return left(
              Failure(
                message: responseModel.message,
                stackTrace: StackTrace.current,
              ),
            );
          }
        },
      );
    } catch (e) {
      debugPrint("Error on getMessageReadInfo: $e");
      return left(
        Failure(message: e.toString(), stackTrace: StackTrace.current),
      );
    }
  }

  FutureEither<List<ChatAndOfferModel>> getUsersChats() async {
    try {
      final response = await api.makeRequest(
        enpoint: APIEndpoints.getUserChats,
        method: RequestMethod.getRequest,
        requireAccessToken: true,
      );

      return response.fold((error) {
        debugPrint("Error on getChats: ${error.message}");
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
}
