import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  // static final SocketService _instance = SocketService._internal();
  // factory SocketService() => _instance;
  // SocketService._internal();
  static int roomIdG = 0;

  static bool isShownError = false;

  IO.Socket? socket;

  IO.Socket? createSocketConnection({
    required int userId,
    required int roomId,
    required String userName,
    required String accessToken,
    String userType = "User",
  }) {
    disconnectSocket();

    roomIdG = roomId;
    socket = IO.io(
      "http://api.picapool.com:3000",
      IO.OptionBuilder()
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
      'content': content,
      'reactionMessageId': reactionMessageId,
    };

    socket!.emit('reaction', reactionData);
  }
}
