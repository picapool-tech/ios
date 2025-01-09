import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/storage/storage_controller.dart';
import 'package:picapool/functions/tags/tag_api.dart';
import 'package:picapool/models/tag_model.dart';

class TagController extends GetxController {
  final TagApi _tagApi = TagApi();
  final AuthController _authController = Get.find<AuthController>();
  final StorageController _storageController = Get.find<StorageController>();

  var isLoading = false.obs;

  var tags = <Tag>[].obs;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  initialize() async {
    await _storageController.loadTags();
    tags.value = _storageController.tags.value;
    if (tags.isEmpty) {
      getAllTags();
    }
  }

  void getAllTags({
    bool forceRefresh = false,
  }) async {
    isLoading.value = true;
    update();

    var accessToken = await _authController.getAccessToken();
    if (accessToken == null) {
      return;
    }
    final result = await _tagApi.getAllTags(accessToken: accessToken);

    result.fold(
      (failure) {
        Get.snackbar('Error', failure.message);
      },
      (tagsList) {
        if (tags.isEmpty) {
          _storageController.saveTags(tagsList);
          tags.value = tagsList;
          debugPrint("Tags from if case: ${tags.length}");
        } else {
          var filtered = tagsList.where((tag) {
            return !tags.any((element) => element.id == tag.id);
          }).toList();

          tags.addAll(filtered);
          _storageController.saveTags(tags);
        }

        if (forceRefresh) {
          tags.value = tagsList;
        }
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
