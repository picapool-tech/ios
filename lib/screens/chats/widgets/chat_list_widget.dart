import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/extensions/color_extensions.dart';
import 'package:picapool/common/extensions/string_extensions.dart';
import 'package:picapool/features/chats/chat_api.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/screens/chats/widgets/last_message_widget.dart';
import 'package:picapool/screens/public_chat/chat_page.dart';
import 'package:picapool/utils/date_time_helper.dart';
import 'package:picapool/features/user/user_controller.dart';

class ChatListWidget extends StatelessWidget {
  final List<ChatAndOfferModel> chats;

  const ChatListWidget({
    super.key,
    required this.chats,
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
                // saveAllLastMessages();
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
            subtitle: (chat.chat.messages?.isNotEmpty ?? false)
                ? LastMessageWidget(
                    username:
                        chat.chat.messages?.lastOrNull?.user?.username ?? "",
                    message: chat.chat.messages?.lastOrNull?.content ?? "",
                  ) //getLastMessage(chat.chat.messages!, chat.chat.id)
                : null,
          ),
        );
      },
    );
  }
}
