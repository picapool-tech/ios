import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showPicaModelBottomSheet({
  required BuildContext context,
  required Widget child,
  bool isScrollController = true,
  bool hideDragHandle = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: isScrollController, // This makes modal full screen
    useSafeArea: true,
    showDragHandle: !hideDragHandle,
    sheetAnimationStyle: AnimationStyle(
      curve: const ElasticInOutCurve(),
      duration: const Duration(
        milliseconds: 500,
      ),
    ),
    builder: (context) {
      return child.marginOnly(bottom: 20);
    },
  );
}
