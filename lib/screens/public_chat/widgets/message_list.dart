import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/blurry_container.dart';
import 'package:picapool/common/widgets/user_profile_picture_widget.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/features/chats/values/enums.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/models/message_model.dart';
import 'package:picapool/screens/public_chat/widgets/chat_bubble_impl.dart';
import 'package:picapool/utils/date_time_helper.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MessageHelper {
  static bool isOnlyEmojis(String message) {
    if (message.trim().isEmpty) return false;

    String cleanMessage = message.replaceAll(RegExp(r'\s+'), '');

    final emojiRegex = RegExp(
      r'^(?:[\u{1F600}-\u{1F64F}]|' // Emoticons
      r'[\u{1F300}-\u{1F5FF}]|' // Misc Symbols
      r'[\u{1F680}-\u{1F6FF}]|' // Transport
      r'[\u{1F1E0}-\u{1F1FF}]|' // Flags
      r'[\u{2600}-\u{26FF}]|' // Misc symbols
      r'[\u{2700}-\u{27BF}]|' // Dingbats
      r'[\u{1F900}-\u{1F9FF}]|' // Supplemental Symbols
      r'[\u{1F200}-\u{1F2FF}])+$', // Enclosed Ideographic
      unicode: true,
    );

    return emojiRegex.hasMatch(cleanMessage);
  }
}

class MessageList extends StatefulWidget {
  final int chatId;
  final void Function(Message) onSwipeToEnd;
  final void Function(LongPressStartDetails, Message)? onLongPress;
  const MessageList({
    super.key,
    required this.chatId,
    required this.onSwipeToEnd,
    this.onLongPress,
  });

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ChatController controller = Get.find<ChatController>();
  final UserController _userController = Get.find<UserController>();
  final Set<int> _readMessageIds = <int>{};
  Timer? _readDebounceTimer;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        _cleanupReadIds();
        if (controller.getLoadingState(ChatLoadingEnums.getAllMessages).value &&
            controller.messages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty && controller.messages.isEmpty) {
          return Center(
            child: Text(controller.errorMessage.value),
          );
        }

        if (controller.messages.isEmpty) {
          return const Center(
            child: Text("No messages found"),
          );
        }

        return Align(
          alignment: Alignment.topCenter,
          child: ListView.builder(
            shrinkWrap: true,
            reverse: true,
            cacheExtent: 1000,
            addRepaintBoundaries: true,
            controller: controller.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8.0),
            physics: const BouncingScrollPhysics(),
            itemCount: controller.messages.length,
            itemExtent: null,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              final message = controller.messages[index];
              bool isSender = message.userId == _userController.user!.id;

              bool showTail = shouldShowTail(index);

              // log("${message.user?.username} -> ${message.userId}");

              var user = controller.usersInChat[message.userId];

              bool showUserName = shouldShowUserName(index);
              bool showDate = shouldShowDate(index);
              bool isSameYear = message.createdAt.year == DateTime.now().year;
              // log("${getReplyUserName(message.parentId)}");
              final replyMessage = getReplyMessage(message.parentId);
              final replyUsername = replyMessage != null
                  ? (controller.usersInChat[replyMessage.userId]?.username ??
                      replyMessage.user?.username)
                  : null;

              bool shouldMarkAsRead =
                  !isSender && !_readMessageIds.contains(message.id);

              // log("${message.type}");

              return VisibilityDetector(
                key: Key("message_${message.id}"),
                onVisibilityChanged: (visibilityInfo) {
                  log("[MESSAGE VISIBLE] for ->${message.content} -> $shouldMarkAsRead -> ${!(message.readData?.isRead ?? false)} -> ${message.isReadByAll}");
                  if (visibilityInfo.visibleFraction > 0.7 &&
                      shouldMarkAsRead &&
                      (!message.isReadByAll ||
                          !(message.readData?.isRead ?? false))) {
                    _readDebounceTimer?.cancel();

                    _readDebounceTimer = Timer(
                      const Duration(milliseconds: 300),
                      () {
                        if (!_readMessageIds.contains(message.id)) {
                          controller.markAsRead(
                              messageId: message.id,
                              customMessage: "from visibililty ");
                          _readMessageIds.add(message.id);
                        }
                      },
                    );
                  }
                },
                child: RepaintBoundary(
                  key: ValueKey(message.id),
                  child: Column(
                    crossAxisAlignment: isSender
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (showDate) ...[
                        Align(
                          alignment: Alignment.center,
                          child: BlurryContainer(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            backgroundColor: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(8),
                            alignment: Alignment.center,
                            child: Text(
                              DateTimeHelper.formatDateTime(message.createdAt,
                                  'dd MMM${isSameYear ? '' : ' yyyy'}'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                      ChatBubble(
                        onDragToEnd: () => widget.onSwipeToEnd(message),
                        // () {

                        // setState(() {
                        // isReplying = true;
                        // replyingMessage = message;
                        // _focusNode.requestFocus();
                        // });
                        // },
                        onLongPress: (details) {
                          widget.onLongPress?.call(details, message);
                          // _showReactionDialog(context, message,
                          //     details.globalPosition);
                        },
                        isSender: isSender,
                        message: message,
                        showDate: shouldShowDate(index),
                        username: (!isSender && showUserName) ||
                                message.type == MessageType.system
                            ? user?.username ?? message.user?.username
                            : null,
                        leadingWidget: showUserName || showDate
                            ? UserProfilePictureWidget(
                                username: user?.username ??
                                    message.user?.username ??
                                    'NA',
                                imageUrl: user?.pic,
                              )
                            : const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.transparent,
                              ),
                        replyMessage: replyMessage,
                        // getReplyMessage(message.parentId),
                        replyUsername: replyUsername,
                        // getReplyUserName(message.parentId),
                        isEdited: message.createdAt != message.updatedAt,
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
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _readDebounceTimer?.cancel();
    _readMessageIds.clear();
    super.dispose();
  }

  Message? getReplyMessage(int? parentId) {
    var message = controller.getMessageFromId(parentId);
    return message;
  }

  String? getReplyUserName(int? parentId, {Message? replyMessage}) {
    log("reply username: ${replyMessage?.user?.username}");
    if (replyMessage != null) {
      return controller.usersInChat[replyMessage.userId]?.username ??
          replyMessage.user?.username;
    }

    var message = getReplyMessage(parentId);
    if (message == null) {
      return null;
    }
    var user = controller.usersInChat[message.userId];
    return user?.username;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getAllMessages(widget.chatId);

      // Add a delayed check for initially visible messages
      Future.delayed(const Duration(milliseconds: 500), () {
        _checkInitiallyVisibleMessages();
      });
    });
  }

  bool shouldShowDate(int index) {
    final int length = controller.messages.length;

    // Always show the date for the last message in the reversed list (first in the UI)
    if (index == length - 1) {
      return true;
    }

    // Do not show the date for the first message in the reversed list (last in the UI)
    if (index == 0) {
      if (length == 1) {
        return true;
      }
    }

    final Message messageCurr = controller.messages[index];
    final Message messageNext =
        controller.messages[index + 1]; // Compare with the next message
    final DateTime dateCurr = messageCurr.createdAt;
    final DateTime dateNext = messageNext.createdAt;

    // Check if the current message and the next message are on the same date
    final bool isSameDate = dateCurr.year == dateNext.year &&
        dateCurr.month == dateNext.month &&
        dateCurr.day == dateNext.day;

    // Show the date if the current message is on a different date than the next message

    return !isSameDate;
  }

  bool shouldShowTail(int index) {
    final int length = controller.messages.length;

    // First message in the list
    if (index == 0) {
      return true;
    }

    // Last message in the list
    if (index == length - 1) {
      return true;
    }

    final Message messageCurr = controller.messages[index];
    final Message messageNext = controller.messages[index - 1];

    // Always show tail for system messages
    if (messageCurr.type == MessageType.system ||
        messageNext.type == MessageType.system) {
      return true;
    }

    // Show tail if next message is from a different user
    return messageCurr.userId != messageNext.userId;
  }

  bool shouldShowUserName(int index) {
    int length = controller.messages.length;
    final messageCurr = controller.messages[index];

    if (messageCurr.type == MessageType.system) {
      return false;
    }

    if (index == length - 1) {
      return true;
    }

    final messagePrev = controller.messages[index + 1];

    if (messagePrev.type == MessageType.system) {
      int prevUserMessageIndex = index + 1;
      while (prevUserMessageIndex < length) {
        if (controller.messages[prevUserMessageIndex].type !=
            MessageType.system) {
          break;
        }
        prevUserMessageIndex++;
      }
      if (prevUserMessageIndex == length) {
        return true;
      }

      final messagePrev = controller.messages[prevUserMessageIndex];
      return messageCurr.userId != messagePrev.userId;
    }

    return messageCurr.userId != messagePrev.userId;
  }

  void _checkInitiallyVisibleMessages() {
    if (!mounted || controller.messages.isEmpty) return;

    // Process the first few messages that would be visible on screen
    final visibleCount = (MediaQuery.of(context).size.height / 80).ceil();
    final processCount = controller.messages.length < visibleCount
        ? controller.messages.length
        : visibleCount;

    for (int i = 0; i < processCount; i++) {
      final message = controller.messages[i];
      final bool isSender = message.userId == _userController.user!.id;

      // Check if this message should be marked as read
      if (!isSender &&
          !_readMessageIds.contains(message.id) &&
          (!message.isReadByAll || !(message.readData?.isRead ?? false))) {
        // Add to read set to avoid duplicates
        _readMessageIds.add(message.id);

        // Mark as read in controller
        controller.markAsRead(
          messageId: message.id,
          customMessage: "from initial visibility",
        );

        log("[INITIAL VISIBLE] Marking message as read: ${message.id} - ${message.content}");
      }
    }
  }

  void _cleanupReadIds() {
    if (controller.messages.isNotEmpty) {
      final currentMessageIds = controller.messages.map((m) => m.id).toSet();
      _readMessageIds.removeWhere((id) => !currentMessageIds.contains(id));
    }
  }
}
