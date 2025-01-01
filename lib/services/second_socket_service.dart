import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  // Singleton pattern implementation
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  String? _currentRoomId;
  final String _serverUrl =
      'https://your-backend-server.com'; // Replace with your server URL

  /// Connects to the socket server
  void connect() {
    if (_socket != null && _socket!.connected) {
      debugPrint('Socket is already connected.');
      return;
    }

    _socket = IO.io(
      _serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) // for Flutter or Dart VM
          .disableAutoConnect() // disable auto-connection
          .build(),
    );

    // Socket connection events
    _socket!.onConnect((_) {
      debugPrint('Connected to socket server.');
      // Optionally, emit an event to authenticate or register the user
    });

    _socket!.onDisconnect((_) {
      debugPrint('Disconnected from socket server.');
      _currentRoomId = null;
    });

    _socket!.onConnectError((data) {
      debugPrint('Connection Error: $data');
    });

    _socket!.onError((data) {
      debugPrint('Socket Error: $data');
    });

    // Connect the socket
    _socket!.connect();
  }

  /// Disconnects from the socket server
  void disconnect() {
    if (_socket == null) {
      debugPrint('Socket is not initialized.');
      return;
    }

    if (_socket!.connected) {
      // Leave the current room before disconnecting
      if (_currentRoomId != null) {
        leaveRoom(_currentRoomId!);
      }
      _socket!.disconnect();
    }
    _socket = null;
    _currentRoomId = null;
    debugPrint('Socket connection closed.');
  }

  /// Checks if the socket is connected
  bool isConnected() {
    return _socket?.connected ?? false;
  }

  /// Joins a specific chat room
  void joinRoom(String roomId,
      {Function? onJoinSuccess, Function? onJoinError}) {
    if (!isConnected()) {
      debugPrint('Socket is not connected. Attempting to connect...');
      connect();
      // Optionally, you can wait for the connection to establish before proceeding
      _socket!.onConnect((_) {
        _joinRoomInternal(roomId,
            onJoinSuccess: onJoinSuccess, onJoinError: onJoinError);
      });
    } else {
      _joinRoomInternal(roomId,
          onJoinSuccess: onJoinSuccess, onJoinError: onJoinError);
    }
  }

  /// Internal method to handle joining a room
  void _joinRoomInternal(String roomId,
      {Function? onJoinSuccess, Function? onJoinError}) {
    if (_currentRoomId != null) {
      // Leave the current room before joining a new one
      leaveRoom(_currentRoomId!);
    }

    _socket!.emit('joinRoom', {'roomId': roomId});
    debugPrint('Emitted joinRoom with roomId: $roomId');

    // Listen for the server response to confirm joining
    _socket!.once('joinRoomSuccess', (data) {
      debugPrint('Successfully joined room: $roomId');
      _currentRoomId = roomId;
      if (onJoinSuccess != null) {
        onJoinSuccess();
      }
    });

    _socket!.once('joinRoomError', (data) {
      debugPrint('Failed to join room: $roomId. Error: $data');
      if (onJoinError != null) {
        onJoinError(data);
      }
    });
  }

  /// Leaves a specific chat room
  void leaveRoom(String roomId,
      {Function? onLeaveSuccess, Function? onLeaveError}) {
    if (!isConnected()) {
      debugPrint('Socket is not connected. Cannot leave room.');
      return;
    }

    _socket!.emit('leaveRoom', {'roomId': roomId});
    debugPrint('Emitted leaveRoom with roomId: $roomId');

    // Listen for the server response to confirm leaving
    _socket!.once('leaveRoomSuccess', (data) {
      debugPrint('Successfully left room: $roomId');
      if (_currentRoomId == roomId) {
        _currentRoomId = null;
      }
      if (onLeaveSuccess != null) {
        onLeaveSuccess();
      }
    });

    _socket!.once('leaveRoomError', (data) {
      debugPrint('Failed to leave room: $roomId. Error: $data');
      if (onLeaveError != null) {
        onLeaveError(data);
      }
    });
  }

  /// Sends a message to the current room
  void sendMessage(String message) {
    if (!isConnected()) {
      debugPrint('Socket is not connected. Message not sent.');
      return;
    }

    if (_currentRoomId == null) {
      debugPrint('No room joined. Join a room before sending messages.');
      return;
    }

    _socket!.emit('sendMessage', {
      'roomId': _currentRoomId,
      'message': message,
      // Add other relevant user data if necessary
    });
    debugPrint('Sent message to room $_currentRoomId: $message');
  }

  /// Listens for incoming messages in the current room
  void onMessage(Function(Map<String, dynamic>) callback) {
    if (_socket == null) {
      debugPrint('Socket is not initialized. Cannot listen for messages.');
      return;
    }

    _socket!.on('receiveMessage', (data) {
      debugPrint('Received message: $data');
      if (data is Map<String, dynamic>) {
        callback(data);
      } else if (data is String) {
        callback(json.decode(data));
      }
    });
  }

  /// Emits a reaction to a message
  void sendReaction(String messageId, String reactionType) {
    if (!isConnected()) {
      debugPrint('Socket is not connected. Reaction not sent.');
      return;
    }

    if (_currentRoomId == null) {
      debugPrint('No room joined. Join a room before sending reactions.');
      return;
    }

    Map<String, dynamic> reactionData = {
      'roomId': _currentRoomId,
      'messageId': messageId,
      'reaction': reactionType,
      // Add other relevant user data if necessary
    };

    _socket!.emit('reaction', reactionData);
    debugPrint(
        'Sent reaction to message $messageId in room $_currentRoomId: $reactionType');
  }

  /// Kicks a user from the current room (admin functionality)
  void kickUser(int userId) {
    if (!isConnected()) {
      debugPrint('Socket is not connected, user not kicked.');
      return;
    }

    if (_currentRoomId == null) {
      debugPrint('No room joined. Cannot kick user.');
      return;
    }

    _socket!.emit('kick', {
      'roomId': _currentRoomId,
      'userId': userId,
    });
    debugPrint('Emitted kick for userId: $userId in room $_currentRoomId');
  }

  /// Disconnects the socket and cleans up resources
  void disconnectSocket() {
    if (_socket != null) {
      if (isConnected()) {
        // Leave the current room before disconnecting
        if (_currentRoomId != null) {
          leaveRoom(_currentRoomId!);
        }
        _socket!.disconnect();
        debugPrint('Socket disconnected.');
      }
      _socket = null;
      _currentRoomId = null;
      debugPrint('Socket resources cleaned up.');
    } else {
      debugPrint('Socket is already null.');
    }
  }

  /// Reconnects the socket (if needed)
  void reconnect() {
    if (_socket == null) {
      connect();
    } else if (!_socket!.connected) {
      _socket!.connect();
      debugPrint('Attempting to reconnect socket...');
    } else {
      debugPrint('Socket is already connected.');
    }
  }

  /// Handles socket errors
  void onError(Function(dynamic) callback) {
    if (_socket == null) {
      debugPrint('Socket is not initialized. Cannot listen for errors.');
      return;
    }

    _socket!.on('error', (data) {
      debugPrint('Socket error: $data');
      callback(data);
    });
  }

  /// Emits an event with arbitrary data
  void emitEvent(String event, dynamic data) {
    if (!isConnected()) {
      debugPrint('Socket is not connected. Cannot emit event: $event');
      return;
    }

    _socket!.emit(event, data);
    debugPrint('Emitted event: $event with data: $data');
  }
}
