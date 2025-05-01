import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/extensions/color_extensions.dart';
import 'package:picapool/common/extensions/string_extensions.dart';
import 'package:picapool/features/chats/chat_api.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/screens/chats/widgets/last_message_widget.dart';
import 'package:picapool/screens/public_chat/chat_page.dart';
import 'package:picapool/utils/date_time_helper.dart';

class ChatListWidget extends StatelessWidget {
  final List<ChatAndOfferModel> chats;

  const ChatListWidget({
    super.key,
    required this.chats,
  });

  @override
  Widget build(BuildContext context) {
    var chatController = Get.find<ChatController>();

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        // bool isSelected = selectedIndexes.contains(index);
        var chat = chats[index];
        var chatTitleColor = chat.chatTitle.toColor;
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
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        chat.chatTitle.characters.first.toUpperCase(),
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
                      chat.chatTitle,
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
                    chat.chat.updatedAt.toIso8601String(),
                  ),
                  style: Theme.of(context).textTheme.labelSmall,
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
