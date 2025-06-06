import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          child: Text(
            "$username: $message",
            overflow: TextOverflow.ellipsis,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.hintColor,
            ),
          ),
        ),
        // if (isMessageUnread(lastMessage, chatId))
        //   const Icon(Icons.circle, color: Colors.red, size: 10)
      ],
    );
  }
}
