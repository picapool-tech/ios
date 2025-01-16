import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picapool/functions/assets/assets_api.dart';
import 'package:picapool/functions/storage/storage_controller.dart';

class AssetsController extends GetxController {
  final StorageController _storageController = Get.find<StorageController>();

  final AssetsApi _assetsApi = AssetsApi();

  var isLoading = false.obs;

  Future<String?> uploadImage(
    XFile? pickedFile,
    String fileName,
  ) async {
    isLoading.value = true;
    update();

    var accessToken = await _storageController.getAccessToken();

    if (accessToken == null) {
      isLoading.value = false;
      update();
      Get.snackbar("Error", "No Access Token found");
      return null;
    }

    final result = await _assetsApi.uploadImageToServer(
      pickedFile: pickedFile,
      fileName: fileName,
      accessToken: accessToken,
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
