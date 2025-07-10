import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/extensions/string_extensions.dart';
import 'package:picapool/common/functions/url_launch.dart';
import 'package:picapool/models/message_model.dart';
import 'package:picapool/screens/public_chat/widgets/message_list.dart';
import 'package:picapool/screens/public_chat/widgets/reply_widget.dart';
import 'package:picapool/utils/theme.dart';

class ChatBubbleWidget extends StatelessWidget {
  final bool isSender;
  final Message message;
  final String? username;
  final String? replyUsername;
  final Message? replyMessage;
  final Widget? leadingWidget;
  final String formattedTime;
  final bool isEdited;
  const ChatBubbleWidget({
    super.key,
    required this.isSender,
    required this.message,
    required this.username,
    required this.replyUsername,
    required this.replyMessage,
    required this.leadingWidget,
    required this.formattedTime,
    required this.isEdited,
  });

  @override
  Widget build(BuildContext context) {
    var hasOnlyEmoji = MessageHelper.isOnlyEmojis(message.content);

    return Row(
      mainAxisAlignment:
          isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isSender) leadingWidget ?? const SizedBox.shrink(),
        if (!isSender) const SizedBox(width: 8),
        Container(
          key: ValueKey(message.id),
          constraints: BoxConstraints(
            maxWidth: Get.mediaQuery.size.width * 0.7,
          ),
          child: Card(
            shadowColor: Colors.transparent,
            color: hasOnlyEmoji
                ? Colors.transparent
                : isSender
                    ? customBlue.shade400
                    : Colors.white,
            margin: const EdgeInsets.only(bottom: 5),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    top: 8,
                    bottom: 8,
                    right: 8,
                  ),
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
                            color: username!.toColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      if (!isSender) const SizedBox(height: 2),
                      if (replyMessage != null && replyMessage != null)
                        ReplyingWidget(
                          username: replyUsername ??
                              replyMessage?.user?.username ??
                              '',
                          message: replyMessage!.content,
                          isSender: isSender,
                        ),
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              hasURLs(message.content)
                                  ? urlText()
                                  : TextSpan(
                                      text: message.content,
                                      style: Get.textTheme.bodyMedium?.copyWith(
                                        color: isSender
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: hasOnlyEmoji ? 30 : null,
                                      ),
                                    ),
                              TextSpan(
                                text: formattedTime,
                                style: const TextStyle(
                                  color: Colors.transparent,
                                ),
                                children: [
                                  if (isEdited)
                                    TextSpan(
                                      text: ' $formattedTime',
                                      style: TextStyle(
                                        fontSize: 10.0,
                                      ),
                                    ),
                                ],
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: roundedContainer().copyWith(
                      color: hasOnlyEmoji
                          ? customBlue.shade400
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isEdited) ...[
                          Text(
                            'Edited',
                            style: TextStyle(
                              fontSize: 10.0,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 9.0,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 10.0,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool hasURLs(String text) {
    const pattern =
        r"(https?:\/\/(www.)?|www.)([\w-]+.([\w-]+.)?[\w]+)([\w./?=%-]*)";
    final regExp = RegExp(pattern);
    return regExp.hasMatch(text);
  }

  TextSpan urlText() {
    return TextSpan(
        style: Get.textTheme.bodyMedium?.copyWith(
          color: isSender ? Colors.white : Colors.black,
        ),
        children: message.content.split('\n').expand((line) {
          final List<TextSpan> lineSpans = [];
          final urlPattern = RegExp(
            r"(https?:\/\/(www\.)?|www\.)([\w-]+\.([\w-]+\.)?[\w]+)([\w.\/?=%&-]*)",
            caseSensitive: false,
          );

          int lastMatchEnd = 0;
          for (final match in urlPattern.allMatches(line)) {
            // Add text before the URL
            if (match.start > lastMatchEnd) {
              lineSpans.add(TextSpan(
                text: line.substring(lastMatchEnd, match.start),
                style: TextStyle(
                  color: isSender ? Colors.white : Colors.black,
                  fontSize: 13,
                ),
              ));
            }

            // Extract URL and handle trailing punctuation
            String url = match.group(0)!;
            String trailing = '';
            if (',.;:!?)]'.contains(url[url.length - 1])) {
              trailing = url[url.length - 1];
              url = url.substring(0, url.length - 1);
            }

            // Add the URL with styling
            lineSpans.add(
              TextSpan(
                text: url,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.blue,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(url);
                  },
              ),
            );

            // Add trailing punctuation, if any
            if (trailing.isNotEmpty) {
              lineSpans.add(TextSpan(
                text: trailing,
                style: TextStyle(
                  color: isSender ? Colors.white : Colors.black,
                  fontSize: 13,
                ),
              ));
            }

            lastMatchEnd = match.end;
          }

          // Add remaining text after the last URL
          if (lastMatchEnd < line.length) {
            lineSpans.add(TextSpan(
              text: line.substring(lastMatchEnd),
              style: TextStyle(
                color: isSender ? Colors.white : Colors.black,
                fontSize: 13,
              ),
            ));
          }

          // Add newline if not the last line
          lineSpans.add(const TextSpan(text: '\n'));

          return lineSpans;
        }).toList());
  }
}
