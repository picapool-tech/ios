import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';

void hidePicaDialog() {
  if (Get.isDialogOpen ?? false) {
    Future.delayed(const Duration(milliseconds: 5));
    Get.back();
  }
}

void showPicaAlertDialog({
  String? title,
  required String message,
  required String confirmText,
  required void Function() onConfirm,
  void Function()? onCancel,
  String? cancelText,
}) {
  Get.dialog(
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: PicaAlertDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: onConfirm,
        cancelText: cancelText,
        onCancel: onCancel,
      ),
    ),
  );
}

void showPicaLoadingDialog({
  String message = 'Please wait...',
  bool barrierDismissible = false,
}) {
  Get.dialog(
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: PicaLoadingDialog(message: message),
    ),
    barrierDismissible: barrierDismissible,
  );
}

class PicaAlertDialog extends StatelessWidget {
  final String message;
  final String confirmText;
  final VoidCallback onConfirm;
  final String? cancelText;
  final VoidCallback? onCancel;
  final String? title;

  const PicaAlertDialog({
    Key? key,
    required this.message,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText,
    this.onCancel,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      icon: Align(
        alignment: Alignment.topRight,
        child: Image.asset(
          "assets/images/ic_launcher.png",
          width: 20,
          height: 20,
        ),
      ),
      alignment: Alignment.center,
      // backgroundColor: AppTh, // Light Beige Background
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      title: title != null
          ? Text(
              title!,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            )
          : null,
      actionsAlignment: MainAxisAlignment.center,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: PicaValues.mediumSpacing),
          SizedBox(
            width: double.infinity,
            child: PicaPrimaryButton(
              text: confirmText,
              onPressed: onConfirm,
              isLoading: false.obs,
            ),
          ),
          if (cancelText != null && onCancel != null) ...[
            const SizedBox(height: 4),
            PicaTextButton(
              onPressed: onCancel,
              text: cancelText!,
              isLoading: false.obs,
            ),
          ],
        ],
      ),
    );
  }
}

// New loading dialog widget
class PicaLoadingDialog extends StatelessWidget {
  final String message;

  const PicaLoadingDialog({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      icon: Align(
        alignment: Alignment.topRight,
        child: Image.asset(
          "assets/images/ic_launcher.png",
          width: 20,
          height: 20,
        ),
      ),
      alignment: Alignment.center,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: PicaValues.mediumSpacing),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
