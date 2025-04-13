import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/live_offer_model.dart';
import 'package:picapool/models/message_model.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/screens/public_chat/chat_info_impl.dart';
import 'package:picapool/screens/public_chat/widgets/chat_bubble.dart';
import 'package:picapool/screens/public_chat/widgets/message_bar.dart';
import 'package:picapool/utils/date_time_helper.dart';
import 'package:picapool/utils/theme.dart';

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

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  final ChatController _chatController = Get.find<ChatController>();
  final UserController _userController = Get.find<UserController>();
  final TextEditingController _textController = TextEditingController();

  bool isEmojiShowing = false;
  bool isReplying = false;
  Message? replyingMessage;

  late AnimationController _controller;
  late Animation<Offset> animation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chatTitle,
            ),
            Obx(() {
              return Text(
                "${_chatController.usersInChat.length} members",
                style: Get.textTheme.bodySmall,
              );
            })
          ],
        ),
        titleTextStyle: Get.textTheme.titleLarge,
        // backgroundColor: AppTheme.currentTheme.colorScheme.secondary,
        elevation: 1,
        scrolledUnderElevation: 2,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(
                () => ChatInfoImpl(
                  chatId: widget.chat.id,
                  offer: widget.offer,
                ),
              );
            },
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Opacity(
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
          ),
          Column(
            children: [
              Expanded(
                child: GetBuilder<ChatController>(
                  builder: (controller) {
                    if (controller.isLoading.value &&
                        controller.messages.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.errorMessage.isNotEmpty &&
                        controller.messages.isEmpty) {
                      return Center(
                        child: Text(controller.errorMessage.value),
                      );
                    }

                    if (controller.messages.isEmpty) {
                      return const Center(
                        child: Text("No messages found"),
                      );
                    }

                    debugPrint("${controller.messages.length}");

                    return Align(
                      alignment: Alignment.topCenter,
                      child: ListView.builder(
                        shrinkWrap: true,
                        reverse: true,
                        controller: _chatController.scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2.0, vertical: 8.0),
                        physics: const BouncingScrollPhysics(),
                        itemCount: controller.messages.length,
                        itemBuilder: (context, index) {
                          final message = controller.messages[index];
                          bool isSender =
                              message.userId == _userController.user!.id;

                          bool showTail = shouldShowTail(index);

                          var user =
                              _chatController.usersInChat[message.userId];

                          var showUserName = shouldShowUserName(index);

                          return Dismissible(
                            key: Key(message.id.toString()),
                            direction: DismissDirection
                                .startToEnd, // Allow swipe from left to right
                            dismissThresholds: const {
                              DismissDirection.startToEnd:
                                  0.5, // Trigger reply action at 50% swipe
                            },
                            movementDuration: const Duration(
                              milliseconds: 200,
                            ), // Smooth swipe animation
                            confirmDismiss: (direction) async {
                              // Prevent the message from being dismissed
                              if (direction == DismissDirection.startToEnd) {
                                setState(() {
                                  isReplying = true;
                                  replyingMessage =
                                      message; // Set the message being replied to
                                });
                              }
                              return false; // Prevent dismissal
                            },
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.reply_rounded,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                            child: GestureDetector(
                              onLongPressStart: (details) {
                                _showReactionDialog(
                                    context, message, details.globalPosition);
                              },
                              child: Column(
                                crossAxisAlignment: isSender
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  BubbleNormal(
                                    text: message.content,
                                    isSender: isSender,
                                    time: DateTimeHelper.formatDateTime(
                                        message.createdAt.toLocal(), "hh:mm a"),
                                    color: isSender
                                        ? AppTheme
                                            .currentTheme.colorScheme.secondary
                                            .withAlpha(180)
                                        : Colors.white54,
                                    textStyle: isSender
                                        ? Get.textTheme.bodyMedium?.copyWith(
                                              color: AppTheme.currentTheme
                                                  .colorScheme.onSecondary,
                                            ) ??
                                            const TextStyle()
                                        : Get.textTheme.bodyLarge ??
                                            const TextStyle(),
                                    sent: isSender,
                                    delivered: isSender,
                                    tail: isSender ? showTail : showUserName,
                                    username: user?.username,
                                    replyMessage:
                                        getReplyMessage(message.parentId),
                                    leading: showUserName
                                        ? CircleAvatar(
                                            backgroundImage: (user == null ||
                                                    user.pic == null ||
                                                    user.pic!.isEmpty)
                                                ? const AssetImage(
                                                    "assets/icons/Frame 64.png",
                                                  ) as ImageProvider
                                                : CachedNetworkImageProvider(
                                                    user.pic!),
                                            radius: 20,
                                          )
                                        : const CircleAvatar(
                                            radius: 20,
                                            foregroundColor: Colors.transparent,
                                            backgroundColor: Colors.transparent,
                                          ),
                                  ),
                                  // if (message.reactions.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Wrap(
                                      spacing: 4.0,
                                      children: [1, 2, 3].map((reaction) {
                                        return Chip(
                                          label: const Text("😀"),
                                          avatar: CircleAvatar(
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                              _chatController
                                                      .usersInChat[0]?.pic ??
                                                  "",
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              MessageBar(
                textController: _textController,
                onSend: (message) {
                  _chatController.sendMessage(message,
                      replyMessageId: replyingMessage?.id);

                  // Reset reply state after sending
                  if (isReplying) {
                    setState(() {
                      isReplying = false;
                      replyingMessage = null;
                    });
                  }
                },
                prefix: IconButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      isEmojiShowing = !isEmojiShowing;
                    });
                  },
                  icon: const Icon(
                    Icons.emoji_emotions_outlined,
                    size: 30,
                  ),
                ),
                replying: isReplying,
                replyingMessage: replyingMessage,
                onCancelReply: () {
                  setState(() {
                    isReplying = false;
                    replyingMessage = null;
                  });
                },
                textFieldTextStyle:
                    Get.textTheme.titleMedium ?? const TextStyle(),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: (isEmojiShowing)
          ? EmojiPicker(
              textEditingController: _textController,
              onEmojiSelected: (category, emoji) {
                _textController.text += emoji.emoji;
              },
              onBackspacePressed: () {
                setState(() {
                  isEmojiShowing = false;
                });
              },
              config: Config(
                bottomActionBarConfig: const BottomActionBarConfig(
                  backgroundColor: Color(0xFFEBEFF2),
                  buttonColor: Colors.transparent,
                  buttonIconColor: Colors.black26,
                ),
                emojiTextStyle: Get.textTheme.headlineLarge,
              ),
            )
          : null,
    );
  }

  @override
  dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  Message? getReplyMessage(int? parentId) {
    return _chatController.getMessageFromId(parentId);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _chatController.connectToSocket(
        _userController.user!.id,
        widget.chat.id,
      );

      await _chatController.getAllUsersInChat(widget.chat.id);

      // _messageController.addListener(isActive);

      _controller = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 200));

      animation =
          Tween(begin: const Offset(0.0, 0.0), end: const Offset(0.3, 0.0))
              .animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.decelerate,
      ));

      _chatController.getAllMessages(widget.chat.id);
      debugPrint("${widget.chat.toJson()}");
    });
  }

  bool shouldShowTail(int index) {
    final int length = _chatController.messages.length;
    int prev = index - 1;

    if (index == 0) {
      if (prev < 0) {
        return true;
      }
      return false;
    }

    if (index == length - 1) {
      return true;
    }

    if (prev < 0) {
      return true;
    }

    final messageCurr = _chatController.messages[index];
    final messagePrev = _chatController.messages[prev];

    return messageCurr.userId != messagePrev.userId;
  }

  bool shouldShowUserName(int index) {
    int length = _chatController.messages.length;

    if (index == length - 1) {
      return true;
    }

    final messageCurr = _chatController.messages[index];
    final messagePrev = _chatController.messages[index + 1];
    return messageCurr.userId != messagePrev.userId;
  }

  void _showReactionDialog(
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
        curve: Curves.easeInOut,
      ),
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      items: <PopupMenuEntry<void>>[
        // Reactions Section
        PopupMenuItem<void>(
          enabled: true, // Disable interaction for this section
          child: Container(
            decoration: roundedContainer().copyWith(
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var reaction in ["❤️", "👍", "😂", "🔥", "🎉", "😢"])
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // setState(() {
                        //   message.reactions.add(
                        //     Reaction(emoji: reaction, userId: _userController.user!.id),
                        //   );
                        // });
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
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              leading: const Icon(Icons.reply),
              title: const Text("Reply"),
              onTap: () {
                setState(() {
                  isReplying = true;
                  replyingMessage = message;
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
          child: ListTile(
            tileColor: Colors.white,
            leading: const Icon(Icons.copy),
            title: const Text("Copy"),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            onTap: () {
              Clipboard.setData(ClipboardData(text: message.content));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Message copied!")),
              );
            },
          ),
        ),
        const PopupMenuDivider(
          height: 1,
        ),
        PopupMenuItem<void>(
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              color: Colors.white,
            ),
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
