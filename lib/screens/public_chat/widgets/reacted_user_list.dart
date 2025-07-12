import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/models/message_model.dart';

class ReactedUserList extends StatelessWidget {
  final Message message;
  const ReactedUserList({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {

    if (message.reactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "No reactions yet",
          style: Get.textTheme.bodySmall,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Reactions",
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          ...message.reactions.map((reaction) {
            return ListTile(
              leading: Text(
                reaction.reaction,
                style: Get.textTheme.bodyMedium,
              ),
              title: Text(
                "${reaction.count} ${reaction.count > 1 ? 'reactions' : 'reaction'}",
                style: Get.textTheme.bodySmall,
              ),
            );
          }),
        ],
      ),
    );
  }
}
