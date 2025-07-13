import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:picapool/common/extensions/date_extensions.dart';
// import 'package:picapool/common/functions/url_launch.dart';
import 'package:picapool/common/widgets/blurry_container.dart';
import 'package:picapool/core/type_defs.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/live_offer_model.dart';
import 'package:picapool/models/message_model.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/screens/public_chat/chat_info_impl.dart';
import 'package:picapool/screens/public_chat/widgets/additional_action_bar.dart';
import 'package:picapool/screens/public_chat/widgets/chat_bubble_widget.dart';
import 'package:picapool/screens/public_chat/widgets/message_bar.dart';
import 'package:picapool/screens/public_chat/widgets/message_info.dart';
import 'package:picapool/screens/public_chat/widgets/message_list.dart';
import 'package:picapool/utils/date_time_helper.dart';
import 'package:picapool/utils/theme.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;
  final String chatTitle;
  final Offer? offer;
  final LiveOffer? liveOffer;
  const ChatPage({
    super.key,
    required this.chat,
    required this.chatTitle,
    this.offer,
    this.liveOffer,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class MessageListWrapper extends StatefulWidget {
  final int chatId;
  final Function(Message) onSwipeToEnd;
  final Function(LongPressStartDetails, Message) onLongPress;

  const MessageListWrapper({
    super.key,
    required this.chatId,
    required this.onSwipeToEnd,
    required this.onLongPress,
  });

  @override
  State<MessageListWrapper> createState() => _MessageListWrapperState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  // Replace bool variables with ValueNotifiers
  final ValueNotifier<bool> _isEmojiShowing = ValueNotifier(false);
  final ValueNotifier<bool> _isReplying = ValueNotifier(false);
  final ValueNotifier<Message?> _replyingMessage = ValueNotifier(null);
  final ValueNotifier<Message?> _editMessage = ValueNotifier(null);

  // Keep these as regular variables since they don't affect MessageList
  final ChatController _chatController = Get.find<ChatController>();
  final UserController _userController = Get.find<UserController>();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _controller;
  late Animation<Offset> animation;

  bool get showGoodToGo =>
      (widget.offer?.name.toLowerCase().contains("- from brands") ??
          false || widget.liveOffer != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          borderRadius: BorderRadius.circular(4),
          splashColor: Colors.transparent,
          onTap: _openChatInfo,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.chatTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Obx(() {
                      return Text(
                        "${_chatController.usersInChat.length} members",
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: AppTheme.currentTheme.hintColor,
                        ),
                      );
                    })
                  ],
                ),
              ),
            ],
          ),
        ),
        titleTextStyle: Get.textTheme.titleLarge,
        elevation: 1,
        scrolledUnderElevation: 2,
        actions: [
          PullDownButton(
            routeTheme: PullDownMenuRouteTheme(
              borderRadius: BorderRadius.circular(20),
              backgroundColor: AppTheme.currentTheme.colorScheme.surface,
            ),
            itemBuilder: (context) => [
              PullDownMenuItem(
                onTap: _openChatInfo,
                title: 'Chat info',
                icon: Icons.info,
              ),
              PullDownMenuItem(
                title: 'Share',
                subtitle: 'Share this to other people',
                onTap: _shareOffer,
                icon: Icons.share_rounded,
              ),
              const PullDownMenuDivider.large(),
              PullDownMenuItem(
                onTap: _leaveChat,
                title: 'Exit chat',
                subtitle: 'Leave this chat',
                isDestructive: true,
                icon: Icons.exit_to_app,
              ),
            ],
            buttonBuilder: (context, showMenu) => IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: showMenu,
              tooltip: "More options",
            ),
          ),
          // PopupMenuButton<void>(
          //   icon: const Icon(Icons.more_vert_rounded),
          //   color: AppTheme.currentTheme.colorScheme.surface,
          //   itemBuilder: (BuildContext context) => [
          //     _menuItemWithIcons(
          //       onTap: () {
          //         _openChatInfo();
          //       },
          //       text: 'Chat Info',
          //       icon: Icons.chat_bubble_rounded,
          //     ),
          //     _menuItemWithIcons(
          //       onTap: () {
          //         _shareOffer();
          //       },
          //       text: "Share",
          //       icon: Icons.share_rounded,
          //     ),
          //     // const PopupMenuDivider(),
          //     // _menuItemWithIcons(
          //     //   onTap: () {},
          //     //   text: 'Report',
          //     //   icon: Icons.report_rounded,
          //     // ),
          //     // const PopupMenuDivider(),
          //     // _menuItemWithIcons(
          //     //   onTap: (widget.offer?.userId == _userController.user!.id)
          //     //       ? null
          //     //       : () {
          //     //           _chatController.leaveChat();
          //     //           Get.back();
          //     //         },
          //     //   text: 'Leave Chat',
          //     //   icon: Icons.exit_to_app_rounded,
          //     //   color: Colors.red,
          //     // ),
          //   ],
          // )
        ],
        bottomOpacity: 1,
        bottom: (showGoodToGo)
            ? PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight / 1.5),
                child: AdditionalActionBar(
                  additionalInfo: "Ready to proceed with the offer?",
                  actionButtonText:
                      widget.liveOffer != null ? "Book a cab" : "Good to go",
                  onActionButtonPressed: () async {
                    if (widget.liveOffer != null) {
                      debugPrint("THIS IS LVIE OFFER");
                      await _sendForCab();
                      return;
                    }

                    await _sendForBrands();
                  },
                ),
              )
            : null,
      ),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => _focusNode.unfocus(),
        child: Stack(
          children: [
            _buildBackground(),
            Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // MessageList won't rebuild when emoji/reply state changes
                      MessageListWrapper(
                        chatId: widget.chat.id,
                        onSwipeToEnd: _handleSwipeToReply,
                        onLongPress: _handleLongPress,
                      ),
                      // Edit overlay with ValueListenableBuilder
                      ValueListenableBuilder<Message?>(
                        valueListenable: _editMessage,
                        builder: (context, editMessage, child) {
                          if (editMessage == null) {
                            return const SizedBox.shrink();
                          }
                          return _buildEditOverlay(editMessage);
                        },
                      ),
                    ],
                  ),
                ),
                // Message bar with ValueListenableBuilder
                Container(
                  padding: EdgeInsets.only(
                    bottom: Get.mediaQuery.padding.bottom,
                  ),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isReplying,
                    builder: (context, isReplying, child) {
                      return ValueListenableBuilder<Message?>(
                        valueListenable: _replyingMessage,
                        builder: (context, replyingMessage, child) {
                          return ValueListenableBuilder<Message?>(
                            valueListenable: _editMessage,
                            builder: (context, editMessage, child) {
                              return MessageBar(
                                textController: _textController,
                                onSend: _handleSendMessage,
                                focusNode: _focusNode,
                                prefix: _buildEmojiToggle(),
                                replying: isReplying,
                                replyingMessage: replyingMessage,
                                replyingTo: _getReplyUserName(replyingMessage),
                                onCancelReply: _cancelReply,
                                editMessage: editMessage,
                                textFieldTextStyle: Get.textTheme.titleMedium ??
                                    const TextStyle(),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: _isEmojiShowing,
        builder: (context, isEmojiShowing, child) {
          return isEmojiShowing
              ? SafeArea(child: _buildEmojiPicker())
              : SizedBox.shrink();
        },
      ),
    );
  }

  @override
  void dispose() {
    _isEmojiShowing.dispose();
    _isReplying.dispose();
    _replyingMessage.dispose();
    _editMessage.dispose();
    _textController.dispose();
    _focusNode.dispose();
    _chatController.usersInChat.clear();
    _chatController.messages.clear();
    _chatController.disconnectSocket();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _chatController.connectToSocket(
        _userController.user!.id,
        widget.chat.id,
      );

      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      );

      animation =
          Tween(begin: const Offset(0.0, 0.0), end: const Offset(0.3, 0.0))
              .animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.decelerate,
      ));

      await _chatController.getAllMessages(widget.chat.id);

      await _chatController.getAllUsersInChat(widget.chat.id);
    });
  }

  Widget _buildBackground() {
    return Opacity(
      opacity: 0.5,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          AppTheme.currentTheme.colorScheme.secondary,
          BlendMode.hue,
        ),
        child: Image.asset(
          "assets/images/chat/wallpaper_1.png",
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildEditOverlay(Message editMessage) {
    return GestureDetector(
      onTap: _cancelEdit,
      child: BlurryContainer(
        blur: 8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ChatBubbleWidget(
              isSender: true,
              message: editMessage,
              username: editMessage.user?.username ?? "",
              replyUsername: null,
              replyMessage: null,
              leadingWidget: null,
              formattedTime: editMessage.updatedAt.formattedTime(),
              isEdited: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return EmojiPicker(
      textEditingController: _textController,
      onBackspacePressed: () => _isEmojiShowing.value = false,
      config: Config(
        bottomActionBarConfig: const BottomActionBarConfig(
          backgroundColor: Colors.white,
          buttonColor: Colors.transparent,
          buttonIconColor: Colors.black38,
        ),
        emojiViewConfig: EmojiViewConfig(
          backgroundColor: Colors.white,
          buttonMode: ButtonMode.CUPERTINO,
        ),
        categoryViewConfig: CategoryViewConfig(
          backgroundColor: Colors.white,
          indicatorColor: Get.theme.colorScheme.secondary,
          iconColorSelected: Get.theme.colorScheme.secondary,
        ),
        emojiTextStyle: Get.textTheme.headlineLarge,
      ),
    );
  }

  Widget _buildEmojiToggle() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isEmojiShowing,
      builder: (context, isEmojiShowing, child) {
        return IconButton(
          onPressed: () {
            _isEmojiShowing.value = !_isEmojiShowing.value;
            if (_isEmojiShowing.value) {
              _focusNode.unfocus();
            } else {
              _focusNode.requestFocus();
            }
          },
          icon: Icon(
            isEmojiShowing ? Icons.keyboard : Icons.emoji_emotions_outlined,
            size: 30,
          ),
        );
      },
    );
  }

  void _cancelEdit() {
    _editMessage.value = null;
    _textController.clear();
  }

  void _cancelReply() {
    _isReplying.value = false;
    _replyingMessage.value = null;
  }

  String _getReplyUserName(Message? replyMessage) {
    if (replyMessage == null) return "";
    return _chatController.usersInChat[replyMessage.userId]?.username ??
        replyMessage.user?.username ??
        "";
  }

  void _handleLongPress(LongPressStartDetails details, Message message) {
    _showReactionDialog(context, message, details);
  }

  void _handleSendMessage(String message) {
    if (_editMessage.value != null) {
      _chatController.editMessage(
        messageId: _editMessage.value!.id,
        newContent: _textController.text,
      );
      _cancelEdit();
      return;
    }

    _chatController.sendMessage(
      message,
      replyMessageId: _replyingMessage.value?.id,
    );

    if (_isReplying.value) {
      _cancelReply();
    }
  }

  // Event handlers - no more setState calls!
  void _handleSwipeToReply(Message message) {
    _isReplying.value = true;
    _replyingMessage.value = message;
    _focusNode.requestFocus();
  }

  void _leaveChat() {
    // Implement leave chat functionality
    _chatController.leaveChat();
    Get.back();
  }

  void _openChatInfo() {
    Get.to(
      () => ChatInfoImpl(
        chatId: widget.chat.id,
        offer: widget.offer,
        chatTitle: widget.chatTitle,
        liveOffer: widget.liveOffer,
      ),
    );
  }

  FutureVoid _sendForBrands() async {
    final String formattedString = """
Hello, I would like to avail this offer. Here are the details:

Username: ${_userController.user!.username ?? _userController.user!.name}
Offer Name: ${widget.offer!.name}
Offer ID: ${widget.offer!.id}
S_ID: ${widget.chat.id}

Please confirm if I can proceed

""";

    var urlString =
        "https://api.whatsapp.com/send/?phone=918330935063&text=$formattedString&type=phone_number&app_absent=0";

    final Uri url = Uri.parse(urlString);

    debugPrint(url.toString());
    if (!await launchUrl(url)) {
      Get.snackbar(
        "Oop! something occured",
        "Something went wrong processing your requeset.",
      );
    }
  }

  FutureVoid _sendForCab() async {
    var dateTime = widget.liveOffer!.createdAt;
    final date = DateTimeHelper.formatDateTime(dateTime, "dd/MM/yyyy hh:mm a");
    final formattedString = """
Hi!
This is *${_userController.user!.name}* (ID: ${_userController.user!.id}).

I’d like to proceed with the following cab booking (L_ID):

*Pickup Location:* ${widget.liveOffer?.from}
*Destination:* ${widget.liveOffer?.to}
*Date & Time:* $date

Could you please check for any discounts and share the final fare? 😊
""";
    final encodedString = Uri.encodeComponent(formattedString);
    final urlString =
        "https://api.whatsapp.com/send/?phone=918330935063&text=$encodedString&type=phone_number&app_absent=0";
    final Uri url = Uri.parse(urlString);
    debugPrint(url.toString());
    if (!await launchUrl(url)) {
      Get.snackbar(
        "Oop! something occured",
        "Something went wrong processing your requeset.",
      );
    }
  }

  FutureVoid _shareOffer() async {
    // add images or files to share if needed
    SharePlus.instance.share(
      ShareParams(
        text: (widget.offer != null)
            ? widget.offer!.shareOfferString
            : (widget.liveOffer != null)
                ? widget.liveOffer!.shareOfferString
                : "",
        // uri: Uri.parse("https://offer.picapool.com/offers/${widget.offer?.id}"),
        subject: "Check out this offer on Picapool!",

        // previewThumbnail: XFile(filePath),
      ),
    );
  }

  // Update reaction dialog to use ValueNotifier
  void _showReactionDialog(
      BuildContext context, Message message, LongPressStartDetails details) {
    showPullDownMenu(
      context: context,
      routeTheme: PullDownMenuRouteTheme(
        borderRadius: BorderRadius.circular(20),
        backgroundColor: AppTheme.currentTheme.colorScheme.surface,
      ),
      items: [
        PullDownMenuItem(
          title: "Reply",
          icon: Icons.reply,
          onTap: () {
            // ✅ No setState - just update ValueNotifier
            _isReplying.value = true;
            _replyingMessage.value = message;
            _focusNode.requestFocus();
          },
        ),
        PullDownMenuItem(
          title: "Copy",
          icon: Icons.copy,
          onTap: () {
            Clipboard.setData(ClipboardData(text: message.content));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Message copied!")),
            );
          },
        ),
        if (message.userId == _userController.user?.id) ...[
          PullDownMenuItem(
            title: "Edit",
            icon: Icons.edit,
            onTap: () {
              // ✅ No setState - just update ValueNotifier
              _editMessage.value = message;
              _textController.text = message.content;
              _focusNode.requestFocus();
            },
          ),
        ],
      ],
      position: Rect.fromLTWH(
        details.globalPosition.dx,
        details.globalPosition.dy,
        MediaQuery.of(context).size.width + details.globalPosition.dx,
        MediaQuery.of(context).size.height - details.globalPosition.dy,
      ),
    );
    // showMenu<void>(
    //   context: context,
    //   position: RelativeRect.fromLTRB(
    //     tapPosition.dx,
    //     tapPosition.dy,
    //     MediaQuery.of(context).size.width - tapPosition.dx,
    //     MediaQuery.of(context).size.height - tapPosition.dy,
    //   ),
    //   items: [
    //     // ... existing reaction menu items
    //     PopupMenuItem<void>(
    //       child: ListTile(
    //         leading: const Icon(Icons.reply),
    //         title: const Text("Reply"),
    //         onTap: () {
    //           _isReplying.value = true;
    //           _replyingMessage.value = message;
    //           _focusNode.requestFocus();
    //           Navigator.of(context).pop();
    //         },
    //       ),
    //     ),
    //     // ... other menu items
    //     if (message.userId == _userController.user?.id)
    //       PopupMenuItem<void>(
    //         child: ListTile(
    //           leading: const Icon(Icons.edit),
    //           title: const Text("Edit"),
    //           onTap: () {
    //             _editMessage.value = message;
    //             _textController.text = message.content;
    //             _focusNode.requestFocus();
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //       ),
    //   ],
    // );
  }

  void _showReactionDialogs(
      BuildContext context, Message message, Offset tapPosition) {
    showMenu<void>(
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        MediaQuery.of(context).size.width - tapPosition.dx,
        MediaQuery.of(context).size.height - tapPosition.dy,
      ),
      popUpAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
      ),
      color: Colors.transparent,
      elevation: 1,
      menuPadding: const EdgeInsets.symmetric(horizontal: 0),
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      items: <PopupMenuEntry<void>>[
        // Reactions Section
        PopupMenuItem<void>(
          enabled: true, // Disable interaction for this section
          padding: EdgeInsets.zero,
          child: BlurryContainer(
            backgroundColor: Colors.white70,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var reaction in ["❤️", "👍", "😂", "🔥", "🎉", "😢"])
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _chatController.sendReaction(
                          content: reaction,
                          messageId: message.id,
                        );
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          reaction,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Context Menu Section
        PopupMenuItem<void>(
          padding: EdgeInsets.zero,
          child: BlurryContainer(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            backgroundColor: Colors.white60,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              leading: const Icon(Icons.reply),
              title: const Text("Reply"),
              onTap: () {
                setState(() {
                  _isReplying.value = true;
                  _replyingMessage.value = message;
                  _focusNode.requestFocus();
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        const PopupMenuDivider(
          height: 1,
        ),
        PopupMenuItem<void>(
          padding: EdgeInsets.zero,
          child: BlurryContainer(
            borderRadius: BorderRadius.circular(0),
            backgroundColor: Colors.white60,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              // tileColor: Colors.white,
              leading: const Icon(Icons.copy),
              title: const Text("Copy"),
              // contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.content));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Message copied!")),
                );
              },
            ),
          ),
        ),

        if (message.userId == _userController.user?.id) ...[
          const PopupMenuDivider(
            height: 1,
          ),
          PopupMenuItem<void>(
            padding: EdgeInsets.zero,
            child: BlurryContainer(
              borderRadius: BorderRadius.circular(0),
              backgroundColor: Colors.white60,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListTile(
                // tileColor: Colors.white,
                leading: const Icon(Icons.edit),
                title: const Text("Edit"),
                // contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                onTap: () {
                  setState(() {
                    _editMessage.value = message;
                    _textController.text = message.content;
                    _focusNode.requestFocus();
                    Navigator.of(context).pop();
                  });
                },
              ),
            ),
          ),
          const PopupMenuDivider(
            height: 1,
          ),
          PopupMenuItem<void>(
            padding: EdgeInsets.zero,
            child: BlurryContainer(
              borderRadius: BorderRadius.circular(0),
              backgroundColor: Colors.white60,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListTile(
                // tileColor: Colors.white,
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text("Info"),
                // contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                onTap: () {
                  Get.to(() => MessageInfo(
                        message: message,
                      ));
                },
              ),
            ),
          ),
        ],
        const PopupMenuDivider(
          height: 1,
        ),
        PopupMenuItem<void>(
          padding: EdgeInsets.zero,
          child: BlurryContainer(
            backgroundColor: Colors.white60,
            // decoration: const BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            //   color: Colors.white,
            // ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Delete", style: TextStyle(color: Colors.red)),
              onTap: () {
                // _chatController.deleteMessage(message.id);
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageListWrapperState extends State<MessageListWrapper> {
  @override
  Widget build(BuildContext context) {
    return MessageList(
      chatId: widget.chatId,
      onSwipeToEnd: widget.onSwipeToEnd,
      onLongPress: widget.onLongPress,
    );
  }
}
