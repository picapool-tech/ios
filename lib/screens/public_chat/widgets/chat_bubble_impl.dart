import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/functions/color_function.dart';
import 'package:picapool/common/widgets/blurry_container.dart';
import 'package:picapool/models/message_model.dart';
import 'package:picapool/screens/public_chat/widgets/chat_bubble_widget.dart';
import 'package:picapool/utils/date_time_helper.dart';
import 'package:picapool/utils/theme.dart';

class ChatBubble extends StatefulWidget {
  final bool isSender;
  final Message message;
  final bool showTail;
  final Message? replyMessage;
  final String? replyUsername;
  final String? username;
  final Widget? leadingWidget;
  final VoidCallback? onDragToEnd;
  final void Function(LongPressStartDetails)? onLongPress;
  const ChatBubble({
    super.key,
    required this.isSender,
    required this.message,
    this.showTail = true,
    this.replyMessage,
    this.username,
    this.leadingWidget,
    this.onDragToEnd,
    this.onLongPress,
    this.replyUsername,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

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
    Color customTheme = getColorFromString(username).darken();
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
      child: Row(
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

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late Animation<double> _opacityAnimation;

  Color get customTheme => getColorFromString(widget.username ?? "").darken();
  String get formattedTime =>
      DateTimeHelper.formatDateTime(widget.message.updatedAt, "hh:mm a");

  @override
  Widget build(BuildContext context) {
    if (widget.message.type == MessageType.system) {
      return _buildSystemMessage();
    } else {
      return _buildDismissibleBubble();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween(
      begin: const Offset(0, 0),
      end: const Offset(0.35, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.decelerate,
        reverseCurve: Curves.decelerate.flipped,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.decelerate,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  Widget _buildDismissibleBubble() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (details) {
        setState(() {
          // Calculate the drag distance
          double dragDistance =
              _controller.value + details.delta.dx / Get.mediaQuery.size.width;

          // Apply elasticity if the drag exceeds the threshold
          if (dragDistance > 0.5) {
            var distance = 0.5;

            dragDistance =
                distance + (dragDistance - 0.5) * 0.2; // Elastic effect
          } else if (dragDistance < 0) {
            dragDistance =
                dragDistance * 0.2; // Elastic effect for reverse drag
          }

          // Update the animation value
          _controller.value = dragDistance.clamp(0.0, 1.0);
        });
      },
      onHorizontalDragEnd: (details) {
        if (_controller.value > 0.35) {
          widget.onDragToEnd?.call(); // Trigger the reply action
        }
        _controller.reverse(); // Reset the animation
      },
      child: SlideTransition(
        position: _animation,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _buildReplyIcon(),
            ChatBubbleWidget(
              isSender: widget.isSender,
              message: widget.message,
              formattedTime: formattedTime,
              customTheme: customTheme,
              username: widget.username,
              replyMessage: widget.replyMessage,
              replyUsername: widget.replyUsername,
              leadingWidget: widget.leadingWidget,
            ),
            _buildReactionsOverlay(),
          ],
        ),
      ),
    );
  }

  // Widget _buildMessageBubble() {
  //   var customTheme = getColorFromString(widget.username ?? "").darken();
  //   var formattedTime =
  //       DateTimeHelper.formatDateTime(widget.message.updatedAt, "hh:mm a");

  //   return
  // Row(
  //   mainAxisAlignment:
  //       widget.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
  //   crossAxisAlignment: CrossAxisAlignment.start,
  //   children: [
  //     if (!widget.isSender) widget.leadingWidget ?? const SizedBox.shrink(),
  //     if (!widget.isSender) const SizedBox(width: 8),
  //     IntrinsicWidth(
  //       child: Container(
  //         key: ValueKey(widget.message.id),
  //         constraints: BoxConstraints(
  //           maxWidth: Get.mediaQuery.size.width * 0.7,
  //         ),
  //         child: Card(
  //           color: widget.isSender ? customBlue.shade400 : Colors.white,
  //           margin: const EdgeInsets.only(bottom: 5),
  //           child: Stack(
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     if (!widget.isSender && widget.username != null)
  //                       Text(
  //                         widget.username!,
  //                         maxLines: 1,
  //                         overflow: TextOverflow.ellipsis,
  //                         style: TextStyle(
  //                           fontSize: 14,
  //                           color: customTheme,
  //                           fontWeight: FontWeight.w800,
  //                         ),
  //                       ),
  //                     if (!widget.isSender) const SizedBox(height: 2),
  //                     if (widget.replyMessage != null)
  //                       ReplyingWidget(
  //                         username: widget.replyUsername!,
  //                         message: widget.replyMessage!.content,
  //                         isSender: widget.isSender,
  //                       ),
  //                     Padding(
  //                       padding: const EdgeInsets.only(right: 4.0),
  //                       child: RichText(
  //                         text: TextSpan(
  //                           children: <TextSpan>[
  //                             TextSpan(
  //                               text: widget.message.content,
  //                               style: Theme.of(context)
  //                                   .textTheme
  //                                   .bodyMedium
  //                                   ?.copyWith(
  //                                     color: widget.isSender
  //                                         ? Colors.white
  //                                         : Colors.black,
  //                                   ),
  //                             ),
  //                             TextSpan(
  //                               text: formattedTime,
  //                               style: const TextStyle(
  //                                 color: Colors.transparent,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Positioned(
  //                 right: 8.0,
  //                 bottom: 4.0,
  //                 child: Text(
  //                   formattedTime,
  //                   style: TextStyle(
  //                     fontSize: 12.0,
  //                     color: Colors.grey.shade500,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   ],
  // );
  // }

  Widget _buildReactionsOverlay() {
    return Positioned(
      bottom: -25,
      right: widget.isSender ? 8 : null,
      left: widget.isSender ? null : 45,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.message.reactions.map((reaction) {
            return const Padding(
              padding: EdgeInsets.all(2.0),
              child: Row(
                children: [
                  Text(
                    "😀",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(width: 2),
                  Text(
                    "2", // Replace with actual reaction count
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReplyIcon() {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: SlideTransition(
          position: _animation,
          child: Icon(
            Icons.reply,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildSystemMessage() {
    return Align(
      alignment: Alignment.center,
      child: BlurryContainer(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        backgroundColor: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
        alignment: Alignment.center,
        child: Text(
          widget.message.content,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
