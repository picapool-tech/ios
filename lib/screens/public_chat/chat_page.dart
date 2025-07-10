import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:picapool/common/extensions/date_extensions.dart';
// import 'package:picapool/common/functions/url_launch.dart';
import 'package:picapool/common/widgets/blurry_container.dart';
import 'package:picapool/core/core.dart';
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

  Message? editMessage;

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
                  child: Stack(
                    children: [
                      MessageList(
                        chatId: widget.chat.id,
                        onSwipeToEnd: (message) {
                          setState(() {
                            isReplying = true;
                            replyingMessage = message;
                            _focusNode.requestFocus();
                          });
                        },
                        onLongPress: (details, message) {
                          _showReactionDialog(
                              context, message, details.globalPosition);
                          // showPullDownMenu(
                          //   context: context,
                          //   routeTheme: PullDownMenuRouteTheme(
                          //     borderRadius: BorderRadius.circular(20),
                          //     backgroundColor:
                          //         AppTheme.currentTheme.colorScheme.surface,
                          //   ),
                          //   items: [
                          //     PullDownMenuItem(
                          //       title: "Reply",
                          //       icon: Icons.reply,
                          //       onTap: () {
                          //         setState(() {
                          //           isReplying = true;
                          //           replyingMessage = message;
                          //           _focusNode.requestFocus();
                          //         });
                          //       },
                          //     ),
                          //     PullDownMenuItem(
                          //       title: "Copy",
                          //       icon: Icons.copy,
                          //       onTap: () {
                          //         Clipboard.setData(
                          //             ClipboardData(text: message.content));
                          //         ScaffoldMessenger.of(context).showSnackBar(
                          //           const SnackBar(
                          //               content: Text("Message copied!")),
                          //         );
                          //       },
                          //     ),
                          //     if (message.userId ==
                          //         _userController.user?.id) ...[
                          //       PullDownMenuItem(
                          //         title: "Edit",
                          //         icon: Icons.edit,
                          //         onTap: () {
                          //           setState(() {
                          //             editMessage = message;
                          //             _textController.text = message.content;
                          //             _focusNode.requestFocus();
                          //           });
                          //         },
                          //       ),
                          //     ],
                          //     // PullDownMenuItem(
                          //     //   title: "Delete",
                          //     //   icon: Icons.delete,
                          //     //   isDestructive: true,
                          //     //   onTap: () {
                          //     //     // _chatController.de;
                          //     //     // Navigator.of(context).pop();
                          //     //   },
                          //     // ),
                          //   ],
                          //   position: Rect.fromLTWH(
                          //     details.globalPosition.dx,
                          //     details.globalPosition.dy,
                          //     MediaQuery.of(context).size.width +
                          //         details.globalPosition.dx,
                          //     MediaQuery.of(context).size.height -
                          //         details.globalPosition.dy,
                          //   ),
                          //   // position: Rect.fromPoints(details.globalPosition., b)
                          // );
                        },
                      ),
                      if (editMessage != null)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              editMessage = null;
                              _textController.clear();
                            });
                          },
                          child: BlurryContainer(
                            blur: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ChatBubbleWidget(
                                  isSender: true,
                                  message: editMessage!,
                                  username: editMessage!.user?.username ?? "",
                                  replyUsername: null,
                                  replyMessage: null,
                                  leadingWidget: null,
                                  formattedTime:
                                      editMessage!.updatedAt.formattedTime(),
                                  isEdited: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                MessageBar(
                  textController: _textController,
                  onSend: (message) {
                    if (editMessage != null) {
                      _chatController.editMessage(
                        messageId: editMessage!.id,
                        newContent: _textController.text,
                      );

                      setState(() {
                        editMessage = null;
                        _textController.clear();
                      });
                      return;
                    }

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
                  editMessage: editMessage,
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
    _chatController.messages.clear();
    _chatController.usersInChat.clear();
    _focusNode.dispose();
    super.dispose();
  }

  Message? getReplyMessage(int? parentId) {
    var message = _chatController.getMessageFromId(parentId);
    return message;
  }

  String? getReplyUserName(int? parentId, {Message? replyMessage}) {
    if (replyMessage != null) {
      return _chatController.usersInChat[replyMessage.userId]?.username ??
          replyingMessage!.user?.username;
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
    });

    _chatController.getAllMessages(widget.chat.id).then((_) {
      _chatController.getAllUsersInChat(widget.chat.id);
    });
  }

  String _formatOfferName() {
    if (widget.offer != null) {
      return widget.offer!.name.replaceAll("- FROM BRANDS", "");
    } else if (widget.liveOffer != null) {
      if (widget.liveOffer!.from == null || widget.liveOffer!.to == null) {
        return "Cab Booking";
      }

      String from = widget.liveOffer!.from ?? "Cab Booking";
      String to = widget.liveOffer!.to ?? "Cab Booking";
      String dateTime = widget.liveOffer!.createdAt.formattedTime();
      return "$from to $to on $dateTime";
    }
    return "";
  }

  String _getOfferDetail() {
    if (widget.offer != null) {
      return """
${_getOfferingTitle()}

Title: ${_formatOfferName()}
Details: ${widget.offer?.desc}

Check it out: ${_getOfferLink()}
""";
    } else if (widget.liveOffer != null) {
      return """
${_getOfferingTitle()}

📍 Pickup: ${widget.liveOffer?.from ?? "N/A"}
📍 Drop: ${widget.liveOffer?.to ?? "N/A"}

Join here : ${_getOfferLink()}
""";
    }
    return "";
  }

  int _getOfferId() {
    if (widget.offer != null) {
      return widget.offer!.id;
    } else if (widget.liveOffer != null) {
      return widget.liveOffer!.id;
    }
    return -1;
  }

  String _getOfferingTitle() {
    if (widget.offer != null) {
      return "Spotted this deal on Picapool -- might be just what you need!";
    } else if (widget.liveOffer != null) {
      return "Spotted a cab on Picapool -- cheaper together!";
    }
    return "Spotted this deal on Picapool -- might be just what you need!";
  }

  String _getOfferLink() {
    if (widget.offer != null) {
      return "https://offer.picapool.com/offer/${widget.offer!.id}";
    } else if (widget.liveOffer != null) {
      return "https://offer.picapool.com/liveOffer/${widget.liveOffer!.id}";
    }
    return "";
  }

  String _getOfferName() {
    if (widget.offer != null) {
      return widget.offer!.name.replaceAll("- FROM BRANDS", "");
    } else if (widget.liveOffer != null) {
      return widget.liveOffer!.from ?? "Cab Booking";
    }
    return "";
  }

  _leaveChat() {
    _chatController.leaveChat();
    Get.back();
  }

  PopupMenuItem _menuItemWithIcons({
    IconData? icon,
    String? text,
    VoidCallback? onTap,
    Color color = Colors.black,
  }) {
    return PopupMenuItem(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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

  FutureVoid _shareOffer() async {
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
                    editMessage = message;
                    _textController.text = message.content;
                    _focusNode.requestFocus();
                    Navigator.of(context).pop();
                  });
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
