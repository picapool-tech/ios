import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/screens/chats/widgets/chat_list_widget.dart';
import 'package:picapool/widgets/loading/chat_loading.dart';

class ChatList extends StatelessWidget {
  final String searchQuery;
  final int filterTab; // 0‑All 1‑Group 2‑Private
  const ChatList({
    super.key,
    this.searchQuery = "",
    this.filterTab = 0,
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

      var filteredChats = controller.chats
          // 1️⃣ TAB FILTER -------------------------------------------
          .where((m) =>
              filterTab == 0 ||
              (filterTab == 1 && m.chat.isMain) ||
              (filterTab == 2 && !m.chat.isMain))
          // 2️⃣ SEARCH FILTER ----------------------------------------
          .where((model) {
        var offername = model.offer?.name ?? model.liveOffer?.to ?? "";
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
        isMessageUnread: (lastMessage, chatId) =>
            isMessageUnread(lastMessage, chatId, chatController),
      );
    });
  }

  bool isMessageUnread(LastMessageModel lastMessageModel, int chatId,
      ChatController chatController) {
    var lastReadMessage = chatController.lastReadMessages[chatId];
    if (lastReadMessage == null) {
      return false;
    }

    var readLastMessage = lastReadMessage.lastMessageModel;

    if (readLastMessage == null) {
      return true;
    }

    debugPrint("Last message: ${lastMessageModel.toJson()}");
    debugPrint("Last message: ${readLastMessage.user?.toJson()}");

    var currentUserName = Get.find<UserController>().user?.username;
    if (readLastMessage.content == lastMessageModel.content &&
        (lastMessageModel.user?.username == readLastMessage.user?.username ||
            lastMessageModel.user?.username == currentUserName)) {
      return false;
    }

    return true;
  }
}
