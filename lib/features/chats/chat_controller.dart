import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/core/reactive_loading.dart';
import 'package:picapool/features/chats/chat_api.dart';
import 'package:picapool/features/chats/values/enums.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/features/tokens/token_service.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/chat_unread_model.dart';
import 'package:picapool/models/message_model.dart';
import 'package:picapool/models/message_read_model.dart';
import 'package:picapool/models/reaction_model.dart';
import 'package:picapool/models/user_model.dart';
import 'package:picapool/services/socket.service.dart';

class ChatController extends GetxController
    with ReactiveLoading<ChatLoadingEnums> {
  final ChatApi _chatApi = ChatApi();
  final UserController _userController = Get.find<UserController>();
  final StorageController _storageController = Get.find<StorageController>();
  final AuthTokenService _authTokenService = Get.find<AuthTokenService>();
  final SocketService socketService = SocketService();
  var lastReadMessages = <int, ChatUnreadModel>{}.obs;

  var readByUsers = <MessageReadModel>[].obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var chats = <ChatAndOfferModel>[].obs;
  var countUnreadMessages = <int, int>{}.obs;

  var messages = <Message>[].obs;
  var usersInChat = <int, User>{}.obs;
  // just for scrolling need some rethinking on this.
  final ScrollController scrollController = ScrollController();

  void connectToSocket(int userId, int chatId) async {
    debugPrint('Connecting socket...');
    var checkSocket = socketService.socket;
    if (checkSocket != null) {
      debugPrint(
          "Socket is already connected with the party ${SocketService.roomIdG}");
      socketService.socket!.disconnect();
    }

    var accessToken = await _authTokenService.getAccessToken();
    if (accessToken == null) {
      debugPrint('Access token is null');
      return;
    }
    socketService.createSocketConnection(
      userId: _userController.user!.id,
      roomId: chatId,
      userName: _userController.user!.name ?? "No Name",
      accessToken: accessToken,
    );
    var socket = socketService.socket;
    if (socket == null) {
      debugPrint('Socket is null');
      return;
    }
    debugPrint("I am in connectToSocket Function");
    socket.on('receiveMessage', handleIncomingMessage);
    socket.on('messageEdited', handleEditMessage);
    socket.on('reactionUpdate', handleReaction);
    socket.on('messageRead', handleReadMessage);
  }

  Future<ChatAndOfferModel?> createChatWithOfferId(int offerId) async {
    isLoading.value = true;
    update();

    var result = await _chatApi.createChatWithOfferId(
      offerId: offerId,
      userId: _userController.user!.id,
    );

    isLoading.value = false;
    update();

    return result.fold(
      (error) {
        Get.snackbar("Oops!", error.message);
        return null;
      },
      (chatAndOfferModel) {
        return chatAndOfferModel;
      },
    );
  }

  void disconnectSocket() {
    debugPrint('Disconnecting socket...');
    socketService.disconnectSocket();

    messages.clear();
    usersInChat.clear();
  }

  void editMessage({
    required int messageId,
    required String newContent,
  }) {
    socketService.editMessage(
      messageId: messageId,
      newContent: newContent,
    );
    debugPrint("Editing message $messageId with content $newContent");
  }

  Future<void> getAllChats() async {
    isLoading.value = true;
    errorMessage.value = '';
    update();

    final result = await _chatApi.getUsersChats();

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar(
          'Error',
          failure.message,
          snackPosition: SnackPosition.TOP,
        );
      },
      (chatsList) {
        chats.value = chatsList;
      },
    );

    isLoading.value = false;
    update();
  }

  Future<void> getAllMessages(int chatId) async {
    isLoading.value = true;
    startLoading(ChatLoadingEnums.getAllMessages);
    update();

    final result = await _chatApi.getAllMessages(
      chatId: chatId,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message,
            snackPosition: SnackPosition.TOP);
      },
      (messagesList) {
        messages.value = messagesList.reversed.toList();
      },
    );

    isLoading.value = false;
    stopLoading(ChatLoadingEnums.getAllMessages);
    update();
  }

  Future<void> getAllUsersInChat(int chatId) async {
    isLoading.value = true;
    update();

    final result = await _chatApi.getAllUsersInChat(
      chatId: chatId,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar(
          'Error',
          failure.message,
          snackPosition: SnackPosition.TOP,
        );
      },
      (usersList) {
        usersInChat.assignAll(usersList);
        // usersInChat.value = usersList;
      },
    );

    isLoading.value = false;
    update();
  }

  Future<Chat?> getChatFromId({required int chatId}) async {
    startLoading(ChatLoadingEnums.chatWithId);

    var result = await _chatApi.getChatWithId(chatId: chatId);

    stopLoading(ChatLoadingEnums.chatWithId);
    return result.fold((error) {
      return null;
    }, (chat) {
      return chat;
    });
  }

  Future<ChatAndOfferModel?> getChatFromLiveOfferId(int liveOfferId,
      {ChatLoadingEnums defaultLoading =
          ChatLoadingEnums.getLiveOfferChat}) async {
    isLoading.value = true;
    if (defaultLoading != ChatLoadingEnums.getLiveOfferChat) {
      startLoading(defaultLoading);
    } else {
      startLoading(ChatLoadingEnums.getLiveOfferChat);
    }

    update();

    var result = await _chatApi.getChatFromLiveOfferId(
      liveOfferId: liveOfferId,
    );

    isLoading.value = false;
    if (defaultLoading != ChatLoadingEnums.getLiveOfferChat) {
      stopLoading(defaultLoading);
    } else {
      stopLoading(ChatLoadingEnums.getLiveOfferChat);
    }
    update();

    return result.fold(
      (error) {
        Get.snackbar("Oops!", error.message);
        return null;
      },
      (chatAndOffer) {
        return chatAndOffer;
      },
    );
  }

  Message? getMessageFromId(int? parentId) {
    if (parentId == null) {
      return null;
    }
    var result =
        messages.where((message) => message.id == parentId).toList().first;
    return result;
  }

  Future<List<MessageReadModel>> getMessageReadInfo(
      {required int messageId}) async {
    startLoading(ChatLoadingEnums.getMessageReadInfo);

    var result = await _chatApi.getMessageReadInfo(messageId: messageId);

    return result.fold(
      (error) {
        stopLoading(ChatLoadingEnums.getMessageReadInfo);
        Get.snackbar("Oops!", error.message);
        return Future.error(error);
      },
      (readData) {
        readByUsers.assignAll(readData);
        stopLoading(ChatLoadingEnums.getMessageReadInfo);
        return readData;
      },
    );
  }

  FutureVoid getReadChatMessages() async {
    lastReadMessages.value =
        await _storageController.getLastReadMessagesWithChatId();
    update();
  }

  String? getUserNameFromIdInChat(int userId) {
    if (usersInChat.isEmpty) {
      return null;
    }

    return usersInChat[userId]?.username;
  }

  void handleEditMessage(data) {
    var message = data['updatedMessage'];
    log("$message");
    log("$data");
    var messageModel = Message.fromJson(message);
    var index = messages.indexWhere((msg) => msg.id == messageModel.id);
    if (index != -1) {
      messages[index] = messageModel;
      // update();
    }
    debugPrint("Edit Message $data with data $message");
  }

  void handleIncomingMessage(data) {
    var message = data['createdMessage'];
    var messageModel = Message.fromJson(message);
    var userId = messageModel.userId;
    if (!usersInChat.containsKey(userId)) {
      getAllUsersInChat(messageModel.chatId!);
    }
    messages.insert(0, messageModel);
    socketService.readMessage(
      messageModel.id,
      _userController.user!.id,
    );
    // update();
    // await Future.wait([Future.value(const Duration(milliseconds: 300))]);
    if (scrollController.hasClients) {
      debugPrint("Scrolling here");
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    debugPrint("Receive Message $data with data $message");
  }

  // [TODO:] need to refactor this when varun fixes it from backend
  void handleReaction(data) {
    log(" $data this is reaction data for chat");
    try {
      if (data == null ||
          !data.containsKey('messageId') ||
          !data.containsKey('reactions')) {
        log("Invalid reaction data received: $data");
        return;
      }

      final int messageId = data['messageId'];
      final List<dynamic> reactionsData = data['reactions'] ?? [];

      final index = messages.indexWhere((msg) => msg.id == messageId);
      if (index == -1) {
        log("Message with ID $messageId not found when updating reactions");
        return;
      }

      final List<Reaction> reactionsModel = reactionsData
          .map<Reaction>((reaction) => Reaction(
                reaction: reaction['reaction'] ?? '',
                messageId: messageId,
                count: reaction['count'] ?? 0,
              ))
          .toList();

      var message = messages[index];
      message.reactions.assignAll(reactionsModel);
      messages[index] = message;
      // update();

      log("Updated reactions for message $messageId: ${reactionsModel.length} reactions");
    } catch (e) {
      log("Error handling reaction update: $e");
    }
  }

  void handleReadMessage(data) {
    var readMessageData = ReadMessageData.fromJson(data);
    var messsageIndex = messages.indexWhere(
      (message) => message.id == readMessageData.messageId,
    );

    if (messsageIndex == -1) {
      log("Message with ID ${readMessageData.messageId} not found when updating read status");
      return;
    }

    var message = messages[messsageIndex];
    message.readData = readMessageData;
    messages[messsageIndex] = message;
  }

  bool isSocketConnected() {
    return socketService.socket?.connected ?? false;
  }

  void kickUser(int userId) {
    socketService.kickUser(userId);
  }

  void leaveChat() {
    socketService.leaveRoom();
    debugPrint("I am in leaveChat Function");
  }

  void markAsRead({required int messageId, String? customMessage}) {
    socketService.readMessage(messageId, _userController.user!.id);
    debugPrint("Marking message $messageId as read with ${customMessage ?? ""}");
  }

  @override
  void onClose() {
    disconnectSocket();
    scrollController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    initializeLoadingStates(ChatLoadingEnums.values);
    getReadChatMessages();
  }

  void sendMessage(String message, {int? replyMessageId}) {
    debugPrint('Sending message... $message');
    socketService.sendMessage(
      message,
      replyMessageId: replyMessageId,
    );

    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
    );
    debugPrint("I am in sendMessage Function");
  }

  void sendReaction({
    required String content,
    required int messageId,
  }) {
    socketService.sendReaction(content, messageId);
    debugPrint("Sending reaction $content to message $messageId");
  }
}
