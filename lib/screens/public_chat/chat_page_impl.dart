import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/live_offer_model.dart';
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

class _ChatPageState extends State<ChatPage> {
  final ChatController _chatController = Get.find<ChatController>();
  final UserController _userController = Get.find<UserController>();
  final TextEditingController _textController = TextEditingController();

  bool isEmojiShowing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chatTitle,
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

                          return BubbleNormal(
                            text: message.content,
                            isSender: isSender,
                            time: DateTimeHelper.formatDateTime(
                                message.createdAt.toLocal(), "hh:mm a"),
                            color: isSender
                                ? AppTheme.currentTheme.colorScheme.secondary
                                    .withAlpha(180)
                                : AppTheme.currentTheme.dividerColor,
                            textStyle: isSender
                                ? Get.textTheme.bodyLarge?.copyWith(
                                      color: AppTheme
                                          .currentTheme.colorScheme.onSecondary,
                                    ) ??
                                    const TextStyle()
                                : Get.textTheme.bodyLarge ?? const TextStyle(),
                            sent: isSender,
                            delivered: isSender,
                            tail: isSender ? showTail : showUserName,
                            username: showUserName && !isSender
                                ? user?.username
                                : null,
                            leading: showUserName
                                ? CircleAvatar(
                                    backgroundImage: (user == null ||
                                            user.pic == null ||
                                            user.pic!.isEmpty)
                                        ? const AssetImage(
                                            "assets/icons/Frame 64.png",
                                          ) as ImageProvider
                                        : CachedNetworkImageProvider(user.pic!),
                                    radius: 20,
                                  )
                                : const CircleAvatar(
                                    radius: 20,
                                    foregroundColor: Colors.transparent,
                                    backgroundColor: Colors.transparent,
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
                  _chatController.sendMessage(message);
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _chatController.connectToSocket(
        _userController.user!.id,
        widget.chat.id,
      );

      await _chatController.getAllUsersInChat(widget.chat.id);

      // _messageController.addListener(isActive);

      _chatController.getAllMessages(widget.chat.id);
      debugPrint("${widget.chat.toJson()}");
    });
  }

  bool shouldShowTail(int index) {
    final int length = _chatController.messages.length;
    int prev = index - 1;
    if (prev < 0) {
      return true;
    }

    if (index == length - 1) {
      return false;
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
}
