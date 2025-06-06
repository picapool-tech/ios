import 'package:flutter/material.dart';
import 'package:picapool/common/extensions/string_extensions.dart';
import 'package:picapool/utils/theme.dart';

class ReplyingWidget extends StatelessWidget {
  final String username;
  final String message;

  final bool isSender;
  const ReplyingWidget({
    super.key,
    required this.username,
    required this.message,
    this.isSender = false,
  });

  @override
  Widget build(BuildContext context) {
    Color customTheme = username.toColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: isSender ? customBlue.shade300 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: customTheme, width: 5),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 6, bottom: 4, right: 4, top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: customTheme,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                      fontSize: 12,
                      color: isSender ? Colors.white : Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
