import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:picapool/common/functions/color_function.dart';
import 'package:picapool/models/message_model.dart';
import 'package:picapool/utils/theme.dart';

// ignore: constant_identifier_names
const double BUBBLE_RADIUS = 16;

/// Basic chat bubble
///
/// The [BorderRadius] can be customized using [bubbleRadius]
///
/// [margin] and [padding] can be used to add space around or within
/// the bubble respectively.
///
/// Default [margin] value is [EdgeInsets.zero] and
/// default padding value is [EdgeInsets.symmetric(horizontal: 16, vertical: 2)]
///
/// Color can be customized using [color]
///
/// [tail] boolean is used to add or remove a tail according to the sender type
///
/// Display message can be changed using [text]
///
/// [text] is the only required parameter
///
/// [text] is now selectable
///
/// Message sender can be changed using [isSender]
///
/// [sent], [delivered] and [seen] can be used to display the message state
///
/// The [TextStyle] can be customized using [textStyle]
///
/// [leading] is the widget that's infront of the bubble when [isSender]
/// is false.
///
/// [trailing] is the widget that's at the end of the bubble when [isSender]
/// is true.
///
/// [onTap], [onDoubleTap], [onLongPress] are callbacks used to register tap gestures

class BubbleNormal extends StatelessWidget {
  final double bubbleRadius;
  final bool isSender;
  final Color color;
  final String text;
  final bool tail;
  final bool sent;
  final bool delivered;
  final bool seen;
  final TextStyle textStyle;
  final BoxConstraints? constraints;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final String time;
  final String? username;
  final Message? replyMessage;

  const BubbleNormal({
    Key? key,
    required this.text,
    this.constraints,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    this.bubbleRadius = BUBBLE_RADIUS,
    this.isSender = true,
    this.color = Colors.white70,
    this.tail = true,
    this.sent = false,
    this.delivered = false,
    this.seen = false,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.leading,
    this.trailing,
    this.textStyle = const TextStyle(
      color: Colors.black87,
      fontSize: 16,
    ),
    required this.time,
    this.username,
    this.replyMessage,
  }) : super(key: key);

  /// Chat bubble builder method
  @override
  Widget build(BuildContext context) {
    Color themeColor = getColorFromString(username ?? "").darken();
    bool stateTick = false;
    Icon? stateIcon;

    if (sent) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (delivered) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (seen) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF92DEDA),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment:
                  isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: <Widget>[
                if (!isSender) leading ?? const SizedBox.shrink(),
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSender ? customBlue.shade500 : Colors.white,
                      borderRadius: BorderRadius.circular(bubbleRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                // Real message
                                TextSpan(
                                  text: "$text    ",
                                  style: textStyle.copyWith(
                                    color: isSender
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),

                                // Fake additionalInfo as placeholder
                                TextSpan(
                                  text: _buildAdditionalInfo(stateIcon),
                                  style: const TextStyle(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Real additionalInfo
                        Positioned(
                          right: 8.0,
                          bottom: 4.0,
                          child: Text(
                            _buildAdditionalInfo(stateIcon),
                            style: TextStyle(
                              fontSize: 12.0,
                              color: isSender
                                  ? Colors.white60
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isSender && trailing != null) trailing!,
              ],
            ),
          ],
        ),
        if ([1].isNotEmpty) _buildReactionsOverlay(),
      ],
    );
  }

  Widget replyingWidget() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(100),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 40,
            color: getColorFromString(username ?? "").darken(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSender ? "You" : username ?? "",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: getColorFromString(username ?? "").darken(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  replyMessage?.content ?? "",
                  style: const TextStyle(
                    fontSize: 12,
                  ),
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

  String _buildAdditionalInfo(Icon? stateIcon) {
    // Combine time and state icon as additional info
    return "$time ${stateIcon != null ? "✓" : ""}";
  }

  Widget _buildReactionsOverlay() {
    return Positioned(
      bottom: -30, // Adjusted to position the reactions below the bubble
      right: isSender ? 8 : null,
      left: isSender ? null : 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          children: [1, 2].map((reaction) {
            return Row(
              children: [
                const Text(
                  "😀",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 4),
                Text(
                  2.toString(),
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(width: 8),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
