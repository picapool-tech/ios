import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/models/message_model.dart';
import 'package:picapool/screens/public_chat/widgets/chat_bubble_impl.dart';
import 'package:picapool/utils/theme.dart';

class ChatBubbleWidget extends StatelessWidget {
  final bool isSender;
  final Message message;
  final String? username;
  final String? replyUsername;
  final Message? replyMessage;
  final Widget? leadingWidget;
  final String formattedTime;
  final Color customTheme;
  const ChatBubbleWidget({
    super.key,
    required this.isSender,
    required this.message,
    required this.username,
    required this.replyUsername,
    required this.replyMessage,
    required this.leadingWidget,
    required this.formattedTime,
    required this.customTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isSender) leadingWidget ?? const SizedBox.shrink(),
        if (!isSender) const SizedBox(width: 8),
        IntrinsicWidth(
          child: Container(
            key: ValueKey(message.id),
            constraints: BoxConstraints(
              maxWidth: Get.mediaQuery.size.width * 0.7,
            ),
            child: Card(
              color: isSender ? customBlue.shade400 : Colors.white,
              margin: const EdgeInsets.only(bottom: 5),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isSender && username != null)
                          Text(
                            username!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: customTheme,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        if (!isSender) const SizedBox(height: 2),
                        if (replyMessage != null)
                          ReplyingWidget(
                            username: replyUsername!,
                            message: replyMessage!.content,
                            isSender: isSender,
                          ),
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: message.content,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: isSender
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                ),
                                TextSpan(
                                  text: formattedTime,
                                  style: const TextStyle(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 8.0,
                    bottom: 4.0,
                    child: Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
