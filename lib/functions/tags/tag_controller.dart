import 'package:get/get.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/tags/tag_api.dart';
import 'package:picapool/models/tag_model.dart';

class TagController extends GetxController {
  final TagApi _tagApi = TagApi();
  final AuthController _authController = Get.find<AuthController>();

  var isLoading = false.obs;

  var tags = <Tag>[].obs;

  void getAllTags() async {
    isLoading.value = true;
    update();

    var accessToken = await _authController.getAccessToken();
    final result = await _tagApi.getAllTags(accessToken: accessToken!);

    result.fold(
      (failure) {
        Get.snackbar('Error', failure.message);
      },
      (tagsList) {
        tags.value = tagsList;
      },
    );

    isLoading.value = false;
    update();
  }

  Future<Tag?> getTag(int tagId) async {
    isLoading.value = true;
    update();

    var accessToken = await _authController.getAccessToken();
    final result =
        await _tagApi.getTag(accessToken: accessToken!, tagId: tagId);

    isLoading.value = false;
    update();

    return result.fold(
      (failure) {
        Get.snackbar('Error', failure.message);
        return null;
      },
      (tag) {
        return tag;
      },
    );
  }
}
