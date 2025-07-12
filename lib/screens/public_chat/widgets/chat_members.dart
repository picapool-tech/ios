import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/user_profile_picture_widget.dart';
import 'package:picapool/features/chats/chat_controller.dart';

class ChatMembersWidget extends StatelessWidget {
  final int? creatorId;
  const ChatMembersWidget({
    super.key,
    this.creatorId,
  });
  ChatController get _chatController => Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return SafeArea(
          top: false,
          child: ListView.builder(
            itemCount: _chatController.usersInChat.length,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 50),
            itemBuilder: (context, index) {
              var user = _chatController.usersInChat.values.elementAt(index);
              return 
              ListTile(
                leading: UserProfilePictureWidget(
                  username: user.username ?? "NA",
                  imageUrl: user.pic,
                ),
                title: Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.username ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (user.isVerified)
                      Image.asset(
                        "assets/images/profile/pica_verified.png",
                        width: 28,
                        
                      )
                  ],
                ),
                trailing: (creatorId ?? -1) == user.id
                    ? Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Admin",
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    );
  }
}
