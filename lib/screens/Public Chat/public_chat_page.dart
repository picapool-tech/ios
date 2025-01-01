import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:picapool/models/message_model_new.dart';

class PublicChatView extends StatefulWidget {
  final List<MessageModel> messages;
  final ScrollController scrollController;
  const PublicChatView({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  @override
  State<PublicChatView> createState() => _PublicChatViewState();
}

class _PublicChatViewState extends State<PublicChatView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    widget.scrollController.animateTo(
      widget.scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    widget.scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        return ChatBubble(
          sender: message.sender,
          message: message.message,
          time: message.time,
          isMe: message.isMe,
          imageUrl: message.imageUrl ?? '',
          showSenderDetails: true,
          replyToMessage: message.replyToMessage,
          replySender: message.replySender,
        );
      },
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String sender;
  final String message;
  final String time;
  final bool isMe;
  final String imageUrl;
  final bool showSenderDetails;
  final String? replyToMessage;
  final String? replySender;

  const ChatBubble({
    super.key,
    required this.sender,
    required this.message,
    required this.time,
    required this.isMe,
    required this.imageUrl,
    required this.showSenderDetails,
    this.replyToMessage,
    this.replySender,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                backgroundImage: (imageUrl.isEmpty)
                    ? const AssetImage("assets/icons/Frame 64.png")
                        as ImageProvider
                    : CachedNetworkImageProvider(imageUrl),
                radius: 20,
              ),
              const SizedBox(width: 10),
            ],
            // else if (!isMe) ...[
            //   CircleAvatar(
            //     backgroundImage: (imageUrl.isEmpty)
            //         ? const AssetImage("assets/images/profile.jpg")
            //             as ImageProvider
            //         : CachedNetworkImageProvider(imageUrl),
            //     radius: 20,
            //   ),
            //   const SizedBox(width: 50),
            // ],
            Expanded(
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      (sender.isNotEmpty) ? sender : "Picapool User",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontFamily: "MontserratSB", // Sender's name font
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xFFF3D7C5)
                          : const Color(0xFFDEDEDE), // Main bubble colors
                      borderRadius: BorderRadius.only(
                        topLeft: isMe
                            ? const Radius.circular(10)
                            : const Radius.circular(0),
                        topRight: const Radius.circular(10),
                        bottomLeft: const Radius.circular(10),
                        bottomRight: isMe
                            ? const Radius.circular(0)
                            : const Radius.circular(10),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (replyToMessage != null && replySender != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? const Color(0xFFFFE2D0)
                                  : const Color(
                                      0xFFEBEBEB), // Lighter background for reply
                              borderRadius: BorderRadius.circular(10),
                              border: const Border(
                                left: BorderSide(
                                    color: Colors.orange,
                                    width:
                                        3), // Orange line to the left of reply
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  replySender!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily:
                                        "MontserratSB", // Replied sender's name font
                                    color: isMe
                                        ? Colors.orange.shade700
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                    height:
                                        4), // Small space between name and message
                                Text(
                                  replyToMessage!,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily:
                                        "MontserratM", // Replied message font
                                    fontSize:
                                        14, // Regular size for reply message
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          message,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: "MontserratM", // Chat text font
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          time,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xff6C6C6C)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
