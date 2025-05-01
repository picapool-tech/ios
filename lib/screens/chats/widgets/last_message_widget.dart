import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/models/chat_model.dart';

class LastMessageWidget extends StatelessWidget {
  final String username;
  final String message;
  const LastMessageWidget({
    super.key,
    required this.username,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: username,
              children: [
                const TextSpan(text: ": "),
                TextSpan(
                  text: message,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // if (isMessageUnread(lastMessage, chatId))
        //   const Icon(Icons.circle, color: Colors.red, size: 10)
      ],
    );
  }
}
