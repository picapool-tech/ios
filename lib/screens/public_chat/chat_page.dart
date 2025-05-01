import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:picapool/common/functions/url_launch.dart';
import 'package:picapool/common/widgets/blurry_container.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/common/widgets/user_profile_picture_widget.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/live_offer_model.dart';
import 'package:picapool/models/message_model.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/screens/public_chat/chat_info_impl.dart';
import 'package:picapool/screens/public_chat/widgets/chat_bubble_impl.dart';
import 'package:picapool/screens/public_chat/widgets/message_bar.dart';
import 'package:picapool/utils/date_time_helper.dart';
import 'package:picapool/utils/theme.dart';
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

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  final ChatController _chatController = Get.find<ChatController>();
  final UserController _userController = Get.find<UserController>();
  final TextEditingController _textController = TextEditingController();

  final FocusNode _focusNode = FocusNode();
  bool isEmojiShowing = false;
  bool wasPreviouslyFocused = false;

  bool isReplying = false;
  Message? replyingMessage;
  late AnimationController _controller;

  late Animation<Offset> animation;
  bool get hasFocus => _focusNode.hasFocus;
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
                        style: Get.textTheme.bodySmall,
                      );
                    })
                  ],
                ),
              ),
            ],
          ),
        ),
        titleTextStyle: Get.textTheme.titleLarge,
        // backgroundColor: AppTheme.currentTheme.colorScheme.secondary,
        elevation: 1,
        scrolledUnderElevation: 2,
        actions: [
          PopupMenuButton<void>(
            icon: const Icon(Icons.more_vert_rounded),
            color: AppTheme.currentTheme.colorScheme.surface,
            itemBuilder: (BuildContext context) => [
              _menuItemWithIcons(
                  onTap: () {
                    _openChatInfo();
                  },
                  text: 'Chat Info',
                  icon: Icons.chat_bubble_rounded),
              // const PopupMenuDivider(),
              // _menuItemWithIcons(
              //   onTap: () {},
              //   text: 'Report',
              //   icon: Icons.report_rounded,
              // ),
              // const PopupMenuDivider(),
              // _menuItemWithIcons(
              //   onTap: (widget.offer?.userId == _userController.user!.id)
              //       ? null
              //       : () {
              //           _chatController.leaveChat();
              //           Get.back();
              //         },
              //   text: 'Leave Chat',
              //   icon: Icons.exit_to_app_rounded,
              //   color: Colors.red,
              // ),
            ],
          )
        ],
        bottomOpacity: 1,
        bottom: (showGoodToGo)
            ? PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight / 1.5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Ready to proceed with the offer?",
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      PicaPrimaryButton(
                        text: widget.liveOffer != null
                            ? "Book a cab"
                            : "Good to go",
                        onPressed: () async {
                          if (widget.liveOffer != null) {
                            debugPrint("THIS IS LVIE OFFER");
                            await _sendForCab();
                            return;
                          }

                          await _sendForBrands();
                        },
                        isLoading: false.obs,
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _focusNode.unfocus();
          });
        },
        child: Stack(
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
                          itemExtent: null,
                          clipBehavior: Clip.none,
                          itemBuilder: (context, index) {
                            final message = controller.messages[index];
                            bool isSender =
                                message.userId == _userController.user!.id;

                            bool showTail = shouldShowTail(index);

                            var user =
                                _chatController.usersInChat[message.userId];

                            var showUserName = shouldShowUserName(index);

                            return Column(
                              crossAxisAlignment: isSender
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                ChatBubble(
                                  onDragToEnd: () {
                                    setState(() {
                                      isReplying = true;
                                      replyingMessage = message;
                                      _focusNode.requestFocus();
                                    });
                                  },
                                  onLongPress: (details) {
                                    // _showReactionDialog(context, message,
                                    //     details.globalPosition);
                                  },
                                  isSender: isSender,
                                  message: message,
                                  username: (!isSender && showUserName) ||
                                          message.type == MessageType.system
                                      ? user?.username
                                      : null,
                                  leadingWidget: showUserName
                                      ? UserProfilePictureWidget(
                                          username: user?.username ?? "NA",
                                          imageUrl: user?.pic,
                                        )
                                      : const CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.transparent,
                                        ),
                                  replyMessage:
                                      getReplyMessage(message.parentId),
                                  replyUsername:
                                      getReplyUserName(message.parentId),
                                ),
                                if (showTail)
                                  const SizedBox(
                                    height: 10,
                                  ),
                                if (message.reactions.isNotEmpty)
                                  const SizedBox(
                                    height: 30,
                                  ),
                              ],
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
                    _chatController.sendMessage(
                      message,
                      replyMessageId: replyingMessage?.id,
                    );

                    // Reset reply state after sending
                    if (isReplying) {
                      setState(() {
                        isReplying = false;
                        replyingMessage = null;
                      });
                    }
                  },
                  focusNode: _focusNode,
                  prefix: IconButton(
                    onPressed: () {
                      setState(() {
                        isEmojiShowing = !isEmojiShowing;
                      });
                      if (isEmojiShowing) {
                        _focusNode.unfocus();
                      } else {
                        _focusNode.requestFocus();
                      }
                    },
                    icon: Icon(
                      !isEmojiShowing
                          ? Icons.emoji_emotions_outlined
                          : Icons.keyboard,
                      size: 30,
                    ),
                  ),
                  replying: isReplying,
                  replyingMessage: replyingMessage,
                  replyingTo:
                      getReplyUserName(null, replyMessage: replyingMessage) ??
                          "",
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
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    // _scrollController.dispose();
    super.dispose();
  }

  Message? getReplyMessage(int? parentId) {
    var message = _chatController.getMessageFromId(parentId);
    return message;
  }

  String? getReplyUserName(int? parentId, {Message? replyMessage}) {
    if (replyMessage != null) {
      return _chatController.usersInChat[replyMessage.userId]?.username;
    }

    var message = getReplyMessage(parentId);
    if (message == null) {
      return null;
    }
    var user = _chatController.usersInChat[message.userId];
    return user?.username;
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

  Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  bool shouldShowTail(int index) {
    final int length = _chatController.messages.length;

    // First message in the list
    if (index == 0) {
      return true;
    }

    // Last message in the list
    if (index == length - 1) {
      return true;
    }

    final Message messageCurr = _chatController.messages[index];
    final Message messageNext = _chatController.messages[index - 1];

    // Always show tail for system messages
    if (messageCurr.type == MessageType.system ||
        messageNext.type == MessageType.system) {
      return true;
    }

    // Show tail if next message is from a different user
    return messageCurr.userId != messageNext.userId;
  }

  bool shouldShowUserName(int index) {
    int length = _chatController.messages.length;
    final messageCurr = _chatController.messages[index];

    if (messageCurr.type == MessageType.system) {
      return false;
    }

    if (index == length - 1) {
      return true;
    }

    final messagePrev = _chatController.messages[index + 1];

    if (messagePrev.type == MessageType.system) {
      int prevUserMessageIndex = index + 1;
      while (prevUserMessageIndex < length) {
        if (_chatController.messages[prevUserMessageIndex].type !=
            MessageType.system) {
          break;
        }
        prevUserMessageIndex++;
      }
      if (prevUserMessageIndex == length) {
        return true;
      }

      final messagePrev = _chatController.messages[prevUserMessageIndex];
      return messageCurr.userId != messagePrev.userId;
    }

    return messageCurr.userId != messagePrev.userId;
  }

  PopupMenuItem _menuItemWithIcons({
    IconData? icon,
    String? text,
    VoidCallback? onTap,
    Color color = Colors.black,
  }) {
    return PopupMenuItem(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      onTap: onTap,
      enabled: onTap != null,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: onTap != null ? color : null,
            ),
            const SizedBox(width: 8),
          ],
          if (text != null)
            Text(
              text,
              style: TextStyle(
                color: onTap != null ? color : null,
              ),
            ),
        ],
      ),
    );
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
                  isReplying = true;
                  replyingMessage = message;
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
