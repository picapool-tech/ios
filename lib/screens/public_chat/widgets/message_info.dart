import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/extensions/date_extensions.dart';
import 'package:picapool/common/widgets/user_profile_picture_widget.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/features/chats/values/enums.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/models/message_model.dart';
import 'package:picapool/models/user_model.dart';
import 'package:picapool/screens/public_chat/widgets/chat_bubble_impl.dart';
import 'package:picapool/utils/theme.dart';

class MessageInfo extends StatefulWidget {
  final Message message;
  const MessageInfo({
    super.key,
    required this.message,
  });

  @override
  State<MessageInfo> createState() => _MessageInfoState();
}

class _MessageInfoState extends State<MessageInfo> {
  final ChatController _chatController = Get.find<ChatController>();
  final UserController _userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Message Info"),
      ),
      body: Column(
        children: [
          // Message preview section with flexible height
          Container(
            constraints: BoxConstraints(
              minHeight: 100, // Minimum height
              maxHeight: MediaQuery.of(context).size.height *
                  0.6, // Maximum height (60% of screen)
            ),
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background that fills the container
                Positioned.fill(
                  child: _buildBackground(),
                ),
                // Content that determines the height
                SingleChildScrollView(
                  // Allow scrolling if content is too large
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min, // Important: only take needed space
                      children: [
                        ChatBubble(
                          isSender: false,
                          message: Message(
                            id: 00,
                            content: widget.message.createdAt.formattedTime(
                              formatString: "hh:mm a",
                            ),
                            createdAt: widget.message.createdAt,
                            updatedAt: widget.message.updatedAt,
                            type: MessageType.system,
                          ),
                        ),
                        SizedBox(height: 8),
                        ChatBubble(
                          isSender: true,
                          message: widget.message,
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Read by list (takes remaining space)
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Read by",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Expanded(
                    child: Obx(() {
                      if (_chatController
                          .getLoadingState(ChatLoadingEnums.getMessageReadInfo)
                          .value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.currentTheme.colorScheme.primary,
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: _chatController.readByUsers.length,
                        padding: const EdgeInsets.only(top: 8.0),
                        itemBuilder: (context, index) {
                          return FutureBuilder(
                            future: getUser(
                                _chatController.readByUsers[index].userId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  ],
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text("Error: ${snapshot.error}"),
                                );
                              } else if (!snapshot.hasData) {
                                return Center(
                                  child: Text("User not found"),
                                );
                              }

                              final user = snapshot.data!;
                              log('[USER] ${user.toJson()}');
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
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
                              );
                            },
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chatController.readByUsers.clear();
    super.dispose();
  }

  Future<User?> getUser(int userId) async {
    return await _userController.getUser(userId);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatController.getMessageReadInfo(messageId: widget.message.id);
    });
  }

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Opacity(
        opacity: 0.5,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            AppTheme.currentTheme.colorScheme.secondary,
            BlendMode.hue,
          ),
          child: Image.asset(
            "assets/images/chat/wallpaper_1.png",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
