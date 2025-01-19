import 'package:get/get.dart';
import 'package:picapool/functions/feedback/feedback_api.dart';

class FeedbackController extends GetxController {
  final FeedbackApi _api = FeedbackApi();
  var isLoading = false.obs;

  Future<void> sendFeedback(String feedback) async {
    isLoading.value = true;
    update();

    final result = await _api.sendFeedback(feedback: feedback);

    result.fold(
      (failure) {
        Get.snackbar('Error', failure.message,
            snackPosition: SnackPosition.TOP);
      },
      (responseModel) {
        Get.snackbar('Success', responseModel.message,
            snackPosition: SnackPosition.TOP);
      },
    );

    isLoading.value = false;
    update();
  }
}
