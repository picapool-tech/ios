import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:picapool/common/functions/color_function.dart';
import 'package:picapool/models/message_model.dart';

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

  ///chat bubble builder method
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        isSender
            ? const Expanded(
                child: SizedBox(
                  width: 5,
                ),
              )
            : leading ?? Container(),
        Container(
          constraints: constraints ??
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .8),
          margin: margin,
          padding: padding,
          child: GestureDetector(
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            onLongPress: onLongPress,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    tail
                        ? isSender
                            ? bubbleRadius
                            : 0
                        : BUBBLE_RADIUS,
                  ),
                  topRight: Radius.circular(bubbleRadius),
                  bottomLeft: const Radius.circular(
                    BUBBLE_RADIUS,
                  ),
                  bottomRight: Radius.circular(
                    tail
                        ? isSender
                            ? 0
                            : bubbleRadius
                        : BUBBLE_RADIUS,
                  ),
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: isSender
                        ? EdgeInsets.fromLTRB(
                            (text.length <= 2) ? 40 : 20, 6, 28, 18)
                        : const EdgeInsets.fromLTRB(12, 8, 12, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (username != null && !isSender)
                          Text(
                            username!,
                            style: textStyle.copyWith(
                              color: themeColor,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        if (replyMessage != null) replyingWidget(),
                        SelectableText(
                          text,
                          style: textStyle,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: isSender ? 30 : 10,
                    child: Text(
                      time,
                      style: TextStyle(
                        color:
                            textStyle.color?.withOpacity(0.7) ?? Colors.black54,
                        fontSize: 11,
                      ),
                      // textAlign: TextAlign.right,
                    ),
                  ),
                  stateIcon != null && stateTick
                      ? Positioned(
                          bottom: 4,
                          right: 6,
                          child: stateIcon,
                        )
                      : const SizedBox(
                          width: 40,
                          height: 10,
                        ),
                ],
              ),
            ),
          ),
        ),
        if (isSender && trailing != null) const SizedBox.shrink(),
      ],
    );
  }

  Widget replyingWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade100,
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          // horiztonal container with blue color
          Container(
            width: 5,
            height: 50,
            color: getColorFromString(username ?? "").darken(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isSender ? "You" : username ?? "",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: getColorFromString(username ?? "").darken(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  replyMessage?.content ?? "",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                  maxLines: 2,
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
