import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/functions/color_function.dart';
import 'package:picapool/common/widgets/blurry_container.dart';
import 'package:picapool/models/message_model.dart';
import 'package:picapool/screens/public_chat/widgets/chat_bubble_widget.dart';
import 'package:picapool/utils/date_time_helper.dart';

class ChatBubble extends StatefulWidget {
  final bool isSender;
  final Message message;
  final bool showTail;
  final Message? replyMessage;
  final String? replyUsername;
  final String? username;
  final Widget? leadingWidget;
  final VoidCallback? onDragToEnd;
  final bool isEdited;
  final bool showDate;
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
    this.showDate = false,
    this.isEdited = false,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late Animation<double> _opacityAnimation;

  Color get customTheme => getColorFromString(widget.username ?? "").darken();
  String get formattedTime =>
      DateTimeHelper.formatDateTime(widget.message.createdAt, "hh:mm a");

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
    // Reference width value for consistent behavior
    final double referenceWidth = 450.0;
    double bubbleWidth = referenceWidth;

    return LayoutBuilder(builder: (context, constraints) {
      // Get actual bubble width from constraints
      bubbleWidth = constraints.maxWidth;

      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) {
          // Calculate absolute drag distance in pixels
          final double absoluteDragDx = details.delta.dx;

          // Minimum drag requirement to prevent accidental triggers
          if (absoluteDragDx.abs() < 1.0) return;

          setState(() {
            // Calculate proportional drag distance with normalization factor
            // This ensures consistent behavior regardless of bubble width
            double dragDistance = _controller.value +
                (absoluteDragDx * referenceWidth) /
                    (bubbleWidth * Get.mediaQuery.size.width);

            // Apply smoother elasticity with progressive resistance
            if (dragDistance > 0.5) {
              double overshoot = dragDistance - 0.5;
              dragDistance =
                  0.5 + (overshoot * (1.0 - (overshoot * 1.2))).clamp(0.0, 0.5);
            } else if (dragDistance < 0) {
              // Progressive resistance for reverse drag
              dragDistance = dragDistance * 0.3;
            }

            // Update the animation value
            _controller.value = dragDistance.clamp(0.0, 1.0);
          });
        },
        onHorizontalDragEnd: (details) {
          // Use velocity to determine action threshold
          final double velocity = details.primaryVelocity ?? 0;

          // Either exceed position threshold or have sufficient velocity
          if (_controller.value > 0.35 || velocity > 800) {
            widget.onDragToEnd?.call(); // Trigger the reply action
          }

          // Reset the animation with spring effect
          _controller.animateBack(
            0.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        },
        onLongPressStart: (details) {
          widget.onLongPress?.call(details);
          // showCupertinoModalPopup(
          //   context: context,
          //   builder: (_) {
          //     return CupertinoActionSheet(
          //       actions: [
          //         CupertinoActionSheetAction(
          //           onPressed: () {
          //             widget.onLongPress?.call(details);
          //             Navigator.pop(context);
          //           },
          //           child: const Text("Reply"),
          //         ),
          //       ],
          //       cancelButton: CupertinoActionSheetAction(
          //         onPressed: () => Navigator.pop(context),
          //         child: const Text("Cancel"),
          //       ),
          //     );
          //   },
          // );
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
                username: widget.username,
                replyMessage: widget.replyMessage,
                replyUsername: widget.replyUsername,
                leadingWidget: widget.leadingWidget,
                isEdited: widget.isEdited,
              ),
              _buildReactionsOverlay(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildReactionsOverlay() {
    return Positioned(
      bottom: -12,
      right: widget.isSender ? 10 : null,
      left: widget.isSender ? null : 50,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // border: Border.all(width: 1),
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
          children: widget.message.groupedReactions().entries.map((entry) {
            final reaction = entry.key;
            final count = entry.value;

            return Padding(
              padding: EdgeInsets.all(2.0),
              child: Row(
                children: [
                  Text(
                    reaction,
                    style: Get.textTheme.bodySmall,
                  ),
                  if (count > 1) ...[
                    SizedBox(width: 2),
                    Text(
                      "$count",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
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
