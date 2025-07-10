import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';

class AdditionalActionBar extends StatelessWidget {
  final String additionalInfo;
  final String actionButtonText;
  final VoidCallback onActionButtonPressed;
  const AdditionalActionBar({
    super.key,
    required this.additionalInfo,
    required this.actionButtonText,
    required this.onActionButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              additionalInfo,
              maxLines: 1,
              overflow: TextOverflow.fade,
            ),
          ),
          PicaPrimaryButton(
            text: actionButtonText,
            onPressed: () async {
              onActionButtonPressed();
            },
            isLoading: false.obs,
            isSmall: true,
          ),
        ],
      ),
    );
  }
}
