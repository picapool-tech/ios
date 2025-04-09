import 'package:flutter/material.dart';
import 'package:picapool/common/widgets/text_field_widgets.dart';
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

  /// [MessageBar] constructor
  ///
  ///
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
  });

  /// [MessageBar] builder method
  ///
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            replying
                ? Container(
                    color: replyWidgetColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.reply,
                          color: replyIconColor,
                          size: 24,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              'Re : $replyingTo',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: onTapCloseReply,
                          child: Icon(
                            Icons.close,
                            color: replyCloseColor,
                            size: 24,
                          ),
                        ),
                      ],
                    ))
                : Container(),
            replying
                ? Container(
                    height: 1,
                    color: Colors.grey.shade300,
                  )
                : Container(),
            Container(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: PicaOutlinedTextField(
                      controller: textController,
                      keyboardType: TextInputType.multiline,
                      // textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 3,
                      onChanged: onTextChanged,
                      fillColor: Colors.white,
                      filled: true,
                      hintText: messageBarHintText,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      borderRadius: 30,
                      prefixIcon: prefix,
                      textStyle: textFieldTextStyle,
                      // style: textFieldTextStyle,
                      // decoration: InputDecoration(
                      //   hintText: messageBarHintText,
                      //   hintMaxLines: 1,
                      //   contentPadding: const EdgeInsets.symmetric(
                      //       horizontal: 8.0, vertical: 10),
                      //   hintStyle: messageBarHintStyle,
                      //   fillColor: Colors.white,
                      //   filled: true,
                      //   enabledBorder: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(30.0),
                      //     borderSide: const BorderSide(
                      //       color: Colors.white,
                      //       width: 0.2,
                      //     ),
                      //   ),
                      //   focusedBorder: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(30.0),
                      //     borderSide: const BorderSide(
                      //       color: Colors.black26,
                      //       width: 0.2,
                      //     ),
                      //   ),
                      // ),
                      // onTapOutside: (vo) {
                      //   FocusManager.instance.primaryFocus?.unfocus();
                      // },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  IconButton.filled(
                    onPressed: () {
                      if (textController.text.trim() != '') {
                        if (onSend != null) {
                          onSend!(textController.text.trim());
                        }
                        textController.text = '';
                      }
                    },
                    icon: const Padding(
                      padding: EdgeInsets.all(7),
                      child: Icon(
                        Icons.send_rounded,
                      ),
                    ),
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          AppTheme.currentTheme.colorScheme.secondary,
                        ),
                        iconColor: const WidgetStatePropertyAll(Colors.white)),
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
