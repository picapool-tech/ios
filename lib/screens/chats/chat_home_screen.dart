import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/common/widgets/search_widget.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/chat_unread_model.dart';
import 'package:picapool/screens/chats/widgets/chat_list.dart';
import 'package:picapool/utils/theme.dart';

class ChatHomeScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? unarchivedChats;

  const ChatHomeScreen({super.key, this.unarchivedChats});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  List<int> selectedIndexes = []; // Track selected items
  List<Map<String, dynamic>> archivedChats = []; // Store archived items
  String selectedCategory = 'All Offers';

  final ChatController chatController = Get.find<ChatController>();
  final UserController _userController = Get.find<UserController>();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Chats", // (Need to make unread dot here)",
          style: TextStyle(
            color: AppTheme.currentTheme.colorScheme.onSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        systemOverlayStyle: uiOverlayStyle(
          context,
          brightness: Brightness.dark,
        ),
        backgroundColor: AppTheme.currentTheme.colorScheme.secondary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kBottomNavigationBarHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchWidget(
              onSearch: (query) {},
              hintColor: AppTheme.light.colorScheme.onSecondary,
              borderColor: const Color(0xff797979),
              textColor: AppTheme.light.colorScheme.onSecondary,
              trailingIconColor: AppTheme.light.colorScheme.primary,
            ),
          ),
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          await chatController.getAllChats();
        },
        child: Column(
          children: [
            Obx(() {
              if (chatController.chats.isNotEmpty &&
                  chatController.isLoading.value) {
                return const LinearProgressIndicator();
              }

              return const SizedBox.shrink();
            }),

            // Chat list
            Expanded(
              child: (_userController.user != null)
                  ? const ChatList()
                  // ? GetBuilder<ChatController>(builder: (controller) {
                  //     if (chatController.chats.isEmpty &&
                  //         chatController.isLoading.value) {
                  //       return const ChatLoading();
                  //     }

                  //     if (chatController.chats.isEmpty) {
                  //       return const Center(child: Text('No chats found'));
                  //     }

                  //     var filteredChats = controller.chats.where((model) {
                  //       var offername =
                  //           model.offer?.name ?? model.liveOffer?.from ?? "";
                  //       var searchList = _searchQuery.toLowerCase().split(" ");
                  //       for (var element in searchList) {
                  //         if (offername.toLowerCase().contains(element)) {
                  //           return true;
                  //         }
                  //       }
                  //       return false;
                  //     }).toList();
                  //     return chatList(filteredChats);
                  //   })
                  : const Center(
                      child: Text(
                        "You don't have an account to show chats",
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ListView chatList(List<ChatAndOfferModel> chats) {
  //   return
  //   ListView.builder(
  //     itemCount: chats.length,
  //     itemBuilder: (context, index) {
  //       bool isSelected = selectedIndexes.contains(index);
  //       var chat = chats[index];
  //       return GestureDetector(
  //         onTap: () {
  //           setState(() {
  //             Get.to(() => ChatPage(
  //                   chat: chat.chat,
  //                   offer: chat.offer,
  //                   liveOffer: chat.liveOffer,
  //                   chatTitle: chat.liveOffer?.to ?? chat.offer?.name ?? "Chat",
  //                 ))?.then(
  //               (onValue) async {
  //                 await chatController.getAllChats();
  //                 saveAllLastMessages();
  //                 debugPrint('ChatPage closed:');
  //               },
  //             );
  //             // if (selectedIndexes.isNotEmpty) {
  //             //   if (isSelected) {
  //             //     selectedIndexes.remove(index);
  //             //   } else {
  //             //     selectedIndexes.add(index);
  //             //   }
  //             // }
  //           });
  //         },
  //         child: Container(
  //           color: isSelected ? const Color(0xffFFEBDF) : Colors.transparent,
  //           child: ListTile(
  //             leading: Stack(
  //               alignment: Alignment.center,
  //               children: [
  // Container(
  //   width: 50,
  //   height: 50,
  //   decoration: BoxDecoration(
  //     borderRadius: BorderRadius.circular(10),
  //     image: (hasImage(chat))
  //         ? DecorationImage(
  //             image: _handleImage(chat),
  //             fit: BoxFit.cover,
  //           )
  //         : null,
  //     color: hasImage(chat)
  //         ? null
  //         : getColorFromString(getChatTitle(chat))
  //             .withAlpha(30),
  //   ),
  //   child: hasImage(chat)
  //       ? null
  //       : Center(
  //           child: Text(
  //             getChatTitle(chat).characters.first.toUpperCase(),
  //             style: TextStyle(
  //               fontSize: 20,
  //               fontWeight: FontWeight.bold,
  //               color: getColorFromString(getChatTitle(chat)),
  //             ),
  //           ),
  //         ),
  // ),
  //               ],
  //             ),
  //             title: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 // todo : change the title to chat.title
  //                 Expanded(
  //                   child: Hero(
  //                     tag: chat.chat.id,
  //                     child: Text(
  //                       getChatTitle(chat),
  //                       maxLines: 1,
  //                       overflow: TextOverflow.ellipsis,
  //                       style:
  //                           Theme.of(context).textTheme.titleMedium?.copyWith(
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(
  //                   width: 4,
  //                 ),
  //                 Text(
  //                   DateTimeHelper.timeAgoSince(
  //                     chat.chat.updatedAt.toIso8601String(),
  //                   ),
  //                   style: Theme.of(context).textTheme.labelSmall,
  //                 ),
  //               ],
  //             ),
  //             subtitle: (chat.chat.messages != null)
  //                 ? _getLastMessage(chat.chat.messages!, chat.chat.id)
  //                 : null,
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  void initState() {
    super.initState();
    if (_userController.user != null) {
      chatController.getAllChats();
    }
    _searchController.addListener(_onSearchChanged);
  }

  bool isMessageUnread(LastMessageModel lastMessageModel, int chatId) {
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

    var currentUserName = _userController.user?.username;
    if (readLastMessage.content == lastMessageModel.content &&
        (lastMessageModel.user?.username == readLastMessage.user?.username ||
            lastMessageModel.user?.username == currentUserName)) {
      return false;
    }

    return true;
  }

  void saveAllLastMessages() {
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

  // Widget _getLastMessage(List<LastMessageModel> list, int chatId) {
  //   if (list.isEmpty) {
  //     return const SizedBox.shrink();
  //   }
  //   var lastMessage = list.last;

  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Expanded(
  //         child: RichText(
  //           overflow: TextOverflow.ellipsis,
  //           text: TextSpan(
  //             text: lastMessage.user?.username ?? "",
  //             children: [
  //               if (lastMessage.user != null) const TextSpan(text: ": "),
  //               TextSpan(
  //                 text: lastMessage.content,
  //                 style: Get.textTheme.bodyMedium?.copyWith(
  //                   fontWeight: FontWeight.normal,
  //                 ),
  //               ),
  //             ],
  //             style: Get.textTheme.bodyMedium?.copyWith(
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ),
  //       ),
  //       if (isMessageUnread(lastMessage, chatId))
  //         const Icon(Icons.circle, color: Colors.red, size: 10)
  //     ],
  //   );
  // }

  void _onSearchChanged() {
    setState(() {
      // _filteredChats = chatController.chats
      //     .where((chat) => chat.title.contains(_searchController.text))
      //     .toList();
      _searchQuery = _searchController.text;
    });
  }
}
