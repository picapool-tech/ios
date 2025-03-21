import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/common/widgets/dialog_widgets.dart';
import 'package:picapool/common/widgets/text_field_widgets.dart';
import 'package:picapool/features/feedback/feedback_controller.dart';

class FeebackSheet extends StatelessWidget {
  final FeedbackController feedbackController;

  const FeebackSheet({
    super.key,
    required this.feedbackController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 8.0, 16, MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Help us improve!",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            "Your feedback is incredibly valuable",
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 16),
          // Feedback TextField
          PicaOutlinedTextField(
            maxLines: 5,
            hintText: "How you feel about our services?",
            controller: feedbackController.feedbackTextController,
          ),
          const SizedBox(height: 20),
          // Submit Form Button
          Obx(
            () => PicaPrimaryButton(
              onPressed: feedbackController.isButtonActive.value
                  ? () {
                      _sendFeedback(feedbackController.feedbackTextController
                          .text); // Add your feedback submission logic here
                    }
                  : null,
              text: "Submit Form",
              isLoading: feedbackController.isLoading,
            ),
          ),
          // Rate Us on Play Store Button
          if (Platform.isAndroid)
            PicaOutlineButton(
              onPressed: () async {
                // Handle Play Store rating action
                final InAppReview inAppReview = InAppReview.instance;
                if (await inAppReview.isAvailable()) {
                  inAppReview.requestReview();
                }
              },
              icon: Image.asset(
                'assets/icons/playstore.png', // Play Store icon asset
                width: 24,
                height: 24,
              ),
              text: "Rate us on Play Store",
              isLoading: false.obs,
            ),
        ],
      ),
    );
  }

  void _sendFeedback(String feedback) async {
    if (feedback.isEmpty) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    var isSuccess = await feedbackController.sendFeedback(feedback);
    if (isSuccess) {
      showPicaAlertDialog(
        message: "Thank you for submitting your feedback!",
        confirmText: "You're welcome",
        onConfirm: () {
          Get.back();
          Get.back(closeOverlays: true);
          feedbackController.feedbackTextController.clear();
        },
      );
    } else {
      Get.showSnackbar(
        const GetSnackBar(
          message: "Oops! your feedback did not reach us right now",
        ),
      );
    }
  }
}
