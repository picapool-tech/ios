import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/screens/chats/widgets/chat_list_widget.dart';
import 'package:picapool/widgets/loading/chat_loading.dart';

class ChatList extends StatelessWidget {
  final String searchQuery;
  const ChatList({
    super.key,
    this.searchQuery = "",
  });

  @override
  Widget build(BuildContext context) {
    var chatController = Get.find<ChatController>();

    return GetBuilder<ChatController>(builder: (controller) {
      if (chatController.chats.isEmpty && chatController.isLoading.value) {
        return const ChatLoading();
      }

      if (chatController.chats.isEmpty) {
        return const Center(child: Text('No chats found'));
      }

      var filteredChats = controller.chats.where((model) {
        var offername = model.offer?.name ?? model.liveOffer?.from ?? "";
        var searchList = searchQuery.toLowerCase().split(" ");
        for (var element in searchList) {
          if (offername.toLowerCase().contains(element)) {
            return true;
          }
        }
        return false;
      }).toList();
      return ChatListWidget(
        chats: filteredChats,
      );
    });
  }
}
