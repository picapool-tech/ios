import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/core/env_constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  // static final SocketService _instance = SocketService._internal();
  // factory SocketService() => _instance;
  // SocketService._internal();
  static int roomIdG = 0;

  static bool isShownError = false;

  io.Socket? socket;

  io.Socket? createSocketConnection({
    required int userId,
    required int roomId,
    required String userName,
    required String accessToken,
    String userType = "User",
  }) {
    disconnectSocket();

    // log("SOCKET = ${Env.get(APIConstants.socketUrl)}");

    roomIdG = roomId;
    socket = io.io(
      APIConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({
            'roomId': "$roomId",
            'type': "User",
            'id': userId,
          })
          .setExtraHeaders({'Authorization': 'Bearer $accessToken'})
          .enableForceNewConnection()
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      debugPrint('Connected to Socket.io Server with roomId: $roomIdG');
      joinRoom(roomId.toString());
    });

    socket!.onReconnectAttempt((handler) {});

    socket!.onConnectError((error) {
      debugPrint('Error connecting to Socket.io Server: $error');
      if (!isShownError) {
        Get.snackbar(
          'Connection Error',
          'Failed to connect to the server.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isShownError = true;
      }
      return;
    });

    socket!.onError((error) {
      debugPrint("Error on socket: $error");
      if (!isShownError) {
        Get.snackbar(
          'Connection Error',
          '$error',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isShownError = true;
      }
      return;
    });

    socket!.onDisconnect((_) {
      debugPrint('Disconnected from Socket.io Server with roomID: $roomIdG');
    });

    return socket;
  }

  void disconnectSocket() {
    // socket?.dispose();
    // if (isConnected()) {
    socket?.disconnect();
    socket?.dispose();
    roomIdG = 0;
    // socket?.close();
  }

  void editMessage({
    required int messageId,
    required String newContent,
  }) {
    if (!isConnected()) {
      debugPrint('Socket is not connected, message not edited.');
      return;
    }

    socket!.emit('message.edit', {
      'messageId': messageId,
      'newContent': newContent,
    });
  }

  bool isConnected() {
    return socket?.connected ?? false;
  }

  void joinRoom(String roomId) {
    socket?.emit('room.join', {
      'roomId': roomId,
    });
    debugPrint("room joined");
  }

  void kickUser(int userId) {
    if (!isConnected()) {
      debugPrint('Socket is not connected, user not kicked.');
      return;
    }

    socket!.emit('kick', {'userId': userId});
  }

  void leaveRoom() {
    socket?.emit('room.leave', {});
  }

  void readMessage(int messageId, int userId) {
    if (!isConnected()) {
      debugPrint('Socket is not connected, message not read.');
      return;
    }

    final readData = {
      'messageId': messageId,
      'userId': userId,
    };

    socket!.emit('readMessage', readData);
  }

  void sendMessage(String content, {int? replyMessageId}) {
    if (!isConnected()) {
      debugPrint('Socket is not connected, message not sent.');
      return;
    }

    final payload = {
      'content': content,
      'replyMessageId': replyMessageId,
    };

    socket!.emit('message', payload);
  }

  void sendReaction(String content, int reactionMessageId) {
    if (!isConnected()) {
      debugPrint('Socket is not connected, reaction not sent.');
      return;
    }

    final reactionData = {
      'reaction': content,
      'messageId': reactionMessageId,
    };

    socket!.emit('reaction', reactionData);
  }
}
