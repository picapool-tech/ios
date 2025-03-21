import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/features/feedback/feedback_api.dart';

class FeedbackController extends GetxController {
  final FeedbackApi _api = FeedbackApi();

  final TextEditingController feedbackTextController = TextEditingController();

  var isButtonActive = false.obs;
  var isLoading = false.obs;

  @override
  void onClose() {
    feedbackTextController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    feedbackTextController.addListener(_updateButtonState);
  }

  Future<bool> sendFeedback(String feedback) async {
    isLoading.value = true;
    update();

    final result = await _api.sendFeedback(feedback: feedback);

    isLoading.value = false;
    update();

    return result.fold(
      (failure) {
        Get.snackbar('Error', failure.message,
            snackPosition: SnackPosition.TOP);
        return false;
      },
      (responseModel) {
        return true;
      },
    );
    // await Future.delayed(const Duration(seconds: 2));
  }

  void _updateButtonState() {
    isButtonActive.value = feedbackTextController.text.trim().isNotEmpty;
  }
}
