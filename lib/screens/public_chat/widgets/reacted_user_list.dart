import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/user_profile_picture_widget.dart';
import 'package:picapool/features/reaction/reaction_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/models/message_model.dart';
import 'package:picapool/models/message_reaction_model.dart';

class ReactedUserList extends StatelessWidget {
  final Message message;
  const ReactedUserList({
    super.key,
    required this.message,
  });

  UserController get _userController => Get.find<UserController>();

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
          FutureBuilder(
            future: _fetchReactions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Cannot fetch reactions at this time.",
                    style: Get.textTheme.bodySmall,
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    "No reactions found",
                    style: Get.textTheme.bodySmall,
                  ),
                );
              }

              final reactions = snapshot.data!;
              // make the user who reacted appear at the top of the list
              reactions.sort((a, b) {
                if (isSameUser(a.userId)) {
                  return -1; // Move current user to the top
                } else if (isSameUser(b.userId)) {
                  return 1; // Move current user to the top
                }
                return a.user.name.compareTo(b.user.name); // Sort by name
              });

              return ListView.builder(
                itemCount: reactions.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding:
                    EdgeInsets.only(bottom: Get.mediaQuery.viewPadding.bottom),
                itemBuilder: (context, index) {
                  final reaction = reactions[index];
                  return ListTile(
                    contentPadding: EdgeInsets.only(left: 0),
                    leading: UserProfilePictureWidget(
                      username: reaction.user.name,
                      imageUrl: reaction.user.pic,
                    ),
                    title: Text(
                      !isSameUser(reaction.userId) ? reaction.user.name : "You",
                      style: Get.textTheme.bodySmall,
                    ),
                    trailing: Text(
                      reaction.reaction,
                      style: Get.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // message.reactions.map((reaction) {
          //   return ListTile(
          //     leading: Text(
          //       reaction.reaction,
          //       style: Get.textTheme.bodyMedium,
          //     ),
          //     title: Text(
          //       "${reaction.count} ${reaction.count > 1 ? 'reactions' : 'reaction'}",
          //       style: Get.textTheme.bodySmall,
          //     ),
          //   );
          // }),
        ],
      ),
    );
  }

  bool isSameUser(int userId) {
    return _userController.user?.id == userId;
  }

  Future<List<MessageReactionModel>> _fetchReactions() async {
    final ReactionController reactionController =
        Get.find<ReactionController>();
    return reactionController.getReactionsByMessageId(message.id);
  }
}
