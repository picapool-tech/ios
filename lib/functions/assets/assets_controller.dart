import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picapool/functions/assets/assets_api.dart';
import 'package:picapool/functions/auth/auth_controller.dart';

class AssetsController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final AssetsApi _assetsApi = AssetsApi();

  var isLoading = false.obs;

  Future<String?> uploadImage(
    XFile? pickedFile,
    String fileName,
  ) async {
    isLoading.value = true;
    update();

    final result = await _assetsApi.uploadImageToServer(
      pickedFile: pickedFile,
      fileName: fileName,
      accessToken: authController.auth.value!.accessToken!,
    );

    isLoading.value = false;
    update();

    return result.fold(
      (failure) {
        Get.snackbar(
          'Error',
          failure.message,
          snackPosition: SnackPosition.TOP,
        );
        return null;
      },
      (url) {
        return url;
      },
    );
  }
}
