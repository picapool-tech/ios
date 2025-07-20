import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/extensions/color_extensions.dart';
import 'package:picapool/common/extensions/string_extensions.dart';
import 'package:picapool/features/chats/chat_api.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/chat_unread_model.dart';
import 'package:picapool/screens/public_chat/chat_page.dart';
import 'package:picapool/utils/date_time_helper.dart';

class ChatListWidget extends StatelessWidget {
  final List<ChatAndOfferModel> chats;
  final bool Function(LastMessageModel, int) isMessageUnread;

  const ChatListWidget({
    super.key,
    required this.chats,
    required this.isMessageUnread,
  });

  @override
  Widget build(BuildContext context) {
    var chatController = Get.find<ChatController>();
    // returns the display title based on private/group rules
    String _titleForChat(ChatAndOfferModel chat, int currentUserId) {
      if (!chat.chat.isMain) {
        final users = chat.chat.users ?? [];
        if (users.length >= 2) {
          final other = users.firstWhere(
            (u) => u.id != currentUserId,
            orElse: () => users.first,
          );
          return '${other.username} – ${chat.offer?.name ?? chat.liveOffer?.to ?? "Chat"}';
        }
        // only current user in list
        return 'You – ${chat.offer?.name ?? chat.liveOffer?.to ?? "Chat"}';
      }
      // group chat
      return chat.offer?.name ?? chat.liveOffer?.to ?? "Chat";
    }

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        // bool isSelected = selectedIndexes.contains(index);
        var chat = chats[index];
        final currentUserId = Get.find<UserController>().user?.id ?? -1;
        final title = _titleForChat(chat, currentUserId);
        var chatTitleColor = title.toColor;

        final DateTime latestTime = chat.chat.updatedAt;

        bool unread = false;
        if (chat.chat.messages?.isNotEmpty ?? false) {
          unread = isMessageUnread(
            chat.chat.messages!.last,
            chat.chat.id,
          );
        }

        return GestureDetector(
          onTap: () {
            // setState(() {
            Get.to(() => ChatPage(
                  chat: chat.chat,
                  offer: chat.offer,
                  liveOffer: chat.liveOffer,
                  chatTitle: chat.liveOffer?.to ?? chat.offer?.name ?? "Chat",
                ))?.then(
              (onValue) async {
                await chatController.getAllChats();
                saveAllLastMessages(chatController);
                debugPrint('ChatPage closed:');
              },
            );
            // if (selectedIndexes.isNotEmpty) {
            //   if (isSelected) {
            //     selectedIndexes.remove(index);
            //   } else {
            //     selectedIndexes.add(index);
            //   }
            // }
          },
          child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: (chat.hasImage)
                      ? DecorationImage(
                          image: chat.getImageProvider,
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: chat.hasImage ? null : chatTitleColor.lighter(),
                ),
                child: chat.hasImage
                    ? null
                    : Center(
                        child: Text(
                          title.characters.first.toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: chatTitleColor,
                          ),
                        ),
                      ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // todo : change the title to chat.title
                  Expanded(
                    child: Hero(
                      tag: chat.chat.id,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    DateTimeHelper.timeAgoSince(
                      latestTime.toIso8601String(),
                    ),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Get.theme.hintColor,
                        ),
                  ),
                ],
              ),
              subtitle: _getLastMessage(
                  chat.chat.messages ?? [], chat.chat.id, chatController)
              // (chat.chat.messages?.isNotEmpty ?? false)
              //     ? LastMessageWidget(
              //         username:
              //             chat.chat.messages?.lastOrNull?.user?.username ?? "",
              //         message: chat.chat.messages?.lastOrNull?.content ?? "",
              //       ) //getLastMessage(chat.chat.messages!, chat.chat.id)
              //     : null,
              // trailing: unread ? const Icon(Icons.mark_chat_unread) : null,
              ),
        );
      },
    );
  }

  int countUnreadMessages(List<LastMessageModel> messages, int chatId) {
    int count = 0;
    for (var message in messages) {
      if (isMessageUnread(message, chatId)) {
        count++;
      }
    }
    return count;
  }

  void saveAllLastMessages(ChatController chatController) {
    Map<int, ChatUnreadModel> readMessages = {};
    for (var chat in chatController.chats) {
      readMessages[chat.chat.id] = ChatUnreadModel(
        chatId: chat.chat.id,
        lastMessageModel: chat.chat.messages?.lastOrNull,
      );
    }
    chatController.lastReadMessages.value = readMessages;
    Get.find<StorageController>().saveLastReadMessagesWithChatId(readMessages);
  }

  Widget _getLastMessage(
      List<LastMessageModel> list, int chatId, ChatController chatController) {
    if (list.isEmpty) {
      return const SizedBox.shrink();
    }
    var lastMessage = list.last;
    var unReadCount = countUnreadMessages(list, chatId);

    // if (unReadCount > 0) {
    //   chatController.countUnreadMessages[chatId] = unReadCount;
    // } else {
    //   chatController.countUnreadMessages.remove(chatId);
    // }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (unReadCount > 0) {
        chatController.countUnreadMessages[chatId] = unReadCount;
      } else {
        chatController.countUnreadMessages.remove(chatId);
      }
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: lastMessage.user?.username ?? "",
              children: [
                if (lastMessage.user != null) const TextSpan(text: ": "),
                TextSpan(
                  text: lastMessage.content,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
        if (countUnreadMessages(list, chatId) > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$unReadCount',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          )
      ],
    );
  }
}
