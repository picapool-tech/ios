import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showPicaModelBottomSheet({
  required BuildContext context,
  required Widget child,
  bool hideDragHandle = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // This makes modal full screen
    useSafeArea: true,
    showDragHandle: !hideDragHandle,
    sheetAnimationStyle: AnimationStyle(
      curve: const ElasticInOutCurve(),
      duration: const Duration(
        milliseconds: 500,
      ),
    ),
    builder: (context) {
      return child.paddingOnly(bottom: 10);
    },
  );
}
