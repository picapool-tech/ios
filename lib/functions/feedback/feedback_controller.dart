import 'package:get/get.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/feedback/feedback_api.dart';

class FeedbackController extends GetxController {
  final FeedbackApi _api = FeedbackApi();
  final AuthController _authController = Get.find<AuthController>();
  var isLoading = false.obs;

  Future<void> sendFeedback(String feedback) async {
    isLoading.value = true;
    update();

    var accessToken = await _authController.getAccessToken();

    if (accessToken == null) {
      Get.snackbar(
        'Error',
        "Need to login again",
        snackPosition: SnackPosition.TOP,
      );
      isLoading.value = false;
      update();

      return;
    }

    final result =
        await _api.sendFeedback(accessToken: accessToken, feedback: feedback);

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
