import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:picapool/common/functions/color_function.dart';
import 'package:picapool/common/widgets/text_field_widgets.dart';
import 'package:picapool/models/message_model.dart';
import 'package:picapool/utils/theme.dart';

///Normal Message bar with more actions
///
/// following attributes can be modified
///
///
/// # BOOLEANS
/// [replying] is the additional reply widget top of the message bar
///
/// # STRINGS
/// [replyingTo] is the string to tag the replying message
/// [messageBarHitText] is the string to show as message bar hint
///
/// # WIDGETS
/// [actions] are the additional leading action buttons like camera
/// and file select
///
/// # COLORS
/// [replyWidgetColor] is the reply widget color
/// [replyIconColor] is the reply icon color on the left side of reply widget
/// [replyCloseColor] is the close icon color on the right side of the reply
/// widget
/// [messageBarColor] is the color of the message bar
/// [sendButtonColor] is the color of the send button
/// [messageBarHintStyle] is the style of the message bar hint
///
/// # METHODS
/// [onTextChanged] is the function which triggers after text every text change
/// [onSend] is the send button action
/// [onTapCloseReply] is the close button action of the close button on the
/// reply widget usually change [replying] attribute to `false`

class MessageBar extends StatelessWidget {
  final bool replying;
  final String replyingTo;
  final List<Widget> actions;
  final Widget prefix;
  final TextEditingController textController;
  final Color replyWidgetColor;
  final Color replyIconColor;
  final Color replyCloseColor;
  final Color messageBarColor;
  final String messageBarHintText;
  final TextStyle messageBarHintStyle;
  final TextStyle textFieldTextStyle;
  final Color sendButtonColor;
  final void Function(String)? onTextChanged;
  final void Function(String)? onSend;
  final void Function()? onTapCloseReply;
  final Message? replyingMessage;
  final VoidCallback? onCancelReply;
  final FocusNode? focusNode;
  const MessageBar({
    super.key,
    this.replying = false,
    this.replyingTo = "",
    this.actions = const [],
    this.replyWidgetColor = const Color(0xffF4F4F5),
    this.replyIconColor = Colors.blue,
    this.replyCloseColor = Colors.black12,
    this.messageBarColor = const Color(0xffF4F4F5),
    this.sendButtonColor = Colors.blue,
    this.messageBarHintText = "Message",
    this.messageBarHintStyle = const TextStyle(fontSize: 16),
    this.textFieldTextStyle = const TextStyle(color: Colors.black),
    this.onTextChanged,
    this.onSend,
    this.onTapCloseReply,
    this.prefix = const SizedBox.shrink(),
    required this.textController,
    this.replyingMessage,
    this.onCancelReply,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: const Radius.circular(30),
                    bottomRight: const Radius.circular(30),
                    topLeft: replying
                        ? const Radius.circular(15)
                        : const Radius.circular(30),
                    topRight: replying
                        ? const Radius.circular(15)
                        : const Radius.circular(30),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: replying ? null : 0,
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(),
                      child:
                          replying ? replyingWidget() : const SizedBox.shrink(),
                    ),
                    PicaOutlinedTextField(
                      controller: textController,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 3,
                      onChanged: onTextChanged,
                      fillColor: Colors.white,
                      filled: true,
                      hintText: messageBarHintText,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 7,
                      ),
                      borderRadius: 30,
                      transparentBorder: true,
                      prefixIcon: prefix,
                      textStyle: textFieldTextStyle,
                      autoFocus: true,
                      onTapOutside: () {},
                      focusNode: focusNode,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            IconButton.filled(
              onPressed: () {
                if (textController.text.trim().isNotEmpty) {
                  if (onSend != null) {
                    onSend!(textController.text.trim());
                    textController.clear(); // Clear text here directly
                  }
                }
              },
              icon: const Padding(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.send,
                ),
              ),
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    customBlue.shade400,
                  ),
                  iconColor: const WidgetStatePropertyAll(Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget replyingWidget() {
    var customColor = getColorFromString(replyingTo).darken();
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade100,
          border: Border(
              left: BorderSide(
            width: 5,
            color: customColor,
          ))),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        replyingTo,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: customColor,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onCancelReply,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          Icons.close,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  replyingMessage?.content ?? "",
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
