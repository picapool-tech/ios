import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/chats/chat_api.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/message_model.dart';
import 'package:picapool/models/user_model.dart';
import 'package:picapool/services/socket.service.dart';

class ChatController extends GetxController {
  final ChatApi _chatApi = ChatApi();
  final AuthController _authController = Get.find<AuthController>();
  final SocketService socketService = SocketService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var chats = <ChatAndOfferModel>[].obs;

  var messages = <Message>[].obs;
  var usersInChat = <User>[].obs;

  // just for scrolling need some rethinking on this.
  final ScrollController scrollController = ScrollController();

  Future<void> getAllChats() async {
    isLoading.value = true;
    errorMessage.value = '';
    update();

    var accessToken = _authController.auth.value!.accessToken;

    final result = await _chatApi.getChats(accessToken: accessToken!);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message,
            snackPosition: SnackPosition.TOP);
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
    errorMessage.value = '';
    update();

    var accessToken = _authController.auth.value!.accessToken;

    final result = await _chatApi.getAllMessages(
      accessToken: accessToken!,
      chatId: chatId,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message,
            snackPosition: SnackPosition.TOP);
      },
      (messagesList) {
        messages.value = messagesList;
      },
    );

    isLoading.value = false;
    update();
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<ChatAndOfferModel?> createChatWithOfferId(int offerId) async {
    isLoading.value = true;
    update();

    var accessToken = await _authController.getAccessToken();
    var result = await _chatApi.createChatWithOfferId(
      accessToken: accessToken!,
      offerId: offerId,
      userId: _authController.auth.value!.user!.id,
    );

    isLoading.value = false;
    update();

    return result.fold(
      (error) {
        Get.snackbar("Error", error.message);
        return null;
      },
      (chatAndOfferModel) {
        return chatAndOfferModel;
      },
    );
  }

  void connectToSocket(int userId, int chatId) async {
    debugPrint('Connecting socket...');
    var checkSocket = socketService.socket;
    if (checkSocket != null) {
      debugPrint(
          "Socket is already connected with the party ${SocketService.roomIdG}");
      socketService.socket!.disconnect();
    }

    var accessToken = await _authController.getAccessToken();
    debugPrint("GETTING ACCESS TOKEN: $accessToken");
    socketService.createSocketConnection(
      userId: _authController.user.value!.id,
      roomId: chatId,
      userName: _authController.user.value!.name ?? "No Name",
      accessToken: accessToken!,
    );
    var socket = socketService.socket;
    if (socket == null) {
      debugPrint('Socket is null');
      return;
    }
    debugPrint("I am in connectToSocket Function");
    socket.on('receiveMessage', handleIncomingMessage);
  }

  bool isSocketConnected() {
    return socketService.socket?.connected ?? false;
  }

  void handleIncomingMessage(data) {
    var message = data['createdMessage'];
    var messageModel = Message.fromJson(message);
    messages.add(messageModel);
    update();
    // await Future.wait([Future.value(const Duration(milliseconds: 300))]);
    if (scrollController.hasClients) {
      debugPrint("Scrolling here");
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    debugPrint("Receive Message $data with data $message");
  }

  void sendMessage(String message, {int? replyMessageId}) {
    debugPrint('Sending message... $message');
    socketService.sendMessage(
      message,
      replyMessageId: replyMessageId,
    );
    debugPrint("I am in sendMessage Function");
  }

  void sendReaction(String content, int reactionMessageId) {
    socketService.sendReaction(content, reactionMessageId);
  }

  void kickUser(int userId) {
    socketService.kickUser(userId);
  }

  void disconnectSocket() {
    debugPrint('Disconnecting socket...');
    socketService.disconnectSocket();

    messages.value = [];
    usersInChat.value = [];
  }

  Future<void> getAllUsersInChat(int chatId) async {
    isLoading.value = true;
    update();

    var accessToken = _authController.auth.value!.accessToken;

    final result = await _chatApi.getAllUsersInChat(
      accessToken: accessToken!,
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
        usersInChat.value = usersList;
      },
    );

    isLoading.value = false;
    update();
  }

  String? getUserNameFromIdInChat(int userId) {
    if (usersInChat.isEmpty) {
      return null;
    }

    return usersInChat.firstWhereOrNull((user) => user.id == userId)?.name;
  }

  @override
  void onClose() {
    disconnectSocket();
    scrollController.dispose();
    super.onClose();
  }
}
