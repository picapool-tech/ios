import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/chats/chat_controller.dart';
import 'package:picapool/models/user_model.dart';

class ChatInfo extends StatefulWidget {
  const ChatInfo({
    super.key,
    required this.chatId,
    required this.creatorId,
  });

  final int chatId;
  final int creatorId;

  @override
  State<ChatInfo> createState() => _ChatInfoState();
}

class _ChatInfoState extends State<ChatInfo> {
  final ChatController _chatController = Get.find<ChatController>();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      _chatController.getAllUsersInChat(widget.chatId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: _chatController,
        builder: (controller) {
          if (_chatController.isLoading.value &&
              _chatController.usersInChat.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_chatController.usersInChat.isEmpty &&
              !_chatController.isLoading.value) {
            return const Center(
              child: Text('No users in chat'),
            );
          }

          return ListView.builder(
            itemCount: _chatController.usersInChat.length,
            itemBuilder: (context, index) {
              final user = _chatController.usersInChat[index];
              return userListItem(user);
            },
          );
        });
  }

  Widget userListItem(User user) {
    return ListTile(
      tileColor:
          (widget.creatorId == user.id) ? Colors.orange.withAlpha(30) : null,
      leading: CircleAvatar(
        radius: 30,
        backgroundColor:
            (widget.creatorId != user.id) ? Colors.grey : Colors.orange,
        backgroundImage: (user.pic == null)
            ? const AssetImage("assets/icons/Frame 64.png") as ImageProvider
            : CachedNetworkImageProvider(
                user.pic!,
              ), // Color based on status
      ),
      title: Text(
        user.name ?? "User",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(user.username ?? ""),
      // trailing: (widget.creatorId == user.id)
      //     ? ElevatedButton(
      //         onPressed: () {},
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: Colors.grey.shade200,
      //           side: const BorderSide(color: Colors.grey),
      //         ),
      //         child: const Text(
      //           "Admin",
      //           style: TextStyle(color: Colors.grey),
      //         ),
      //       )
      //     : ElevatedButton(
      //         onPressed: () {},
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: Colors.white,
      //           side: const BorderSide(color: Colors.orange),
      //         ),
      //         child: const Text(
      //           "Request",
      //           style: TextStyle(color: Colors.orange),
      //         ),
      //       ),
    );
  }
}
