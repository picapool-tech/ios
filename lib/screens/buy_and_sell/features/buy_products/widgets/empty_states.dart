import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';

class EmptyStates extends StatelessWidget {
  final String message;
  final String? secondaryMessage;
  final VoidCallback? onActionPressed;
  final String? actionText;
  final String imagePath;
  const EmptyStates({
    super.key,
    required this.message,
    this.imagePath = "assets/images/buy_and_sell/empty_state.png",
    this.secondaryMessage,
    this.onActionPressed,
    this.actionText,
  }) : assert(
          (onActionPressed == null && actionText == null) ||
              (onActionPressed != null && actionText != null),
          "onActionPressed and actionText must both be null or both be non-null",
        );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        children: [
          Image.asset(
            imagePath,
            width: Get.width * 0.5,
          ),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          if (secondaryMessage != null)
            Text(
              secondaryMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          if (onActionPressed != null)
            PicaOutlineButton(
              text: "Create your own listing",
              onPressed: () {},
              isSmall: true,
              isLoading: false.obs,
            ),
        ],
      ),
    );
  }
}
