import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/functions/storage/storage_controller.dart';
import 'package:picapool/functions/tags/tag_api.dart';
import 'package:picapool/models/tag_model.dart';

class TagController extends GetxController {
  final TagApi _tagApi = TagApi();
  final StorageController _storageController = Get.find<StorageController>();

  var isLoading = false.obs;

  var tags = <Tag>[].obs;

  Future<void> getAllTags({
    bool forceRefresh = false,
  }) async {
    isLoading.value = true;
    update();

    final result = await _tagApi.getAllTags();

    result.fold(
      (failure) {
        if (failure.showError) {
          Get.snackbar('Error', failure.message);
        }
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

          // Update existing tags if there are any changes
          for (var tag in tagsList) {
            var index = tags.indexWhere((element) => element.id == tag.id);
            if (index != -1) {
              tags[index] = tag;
            }
          }

          tags.addAll(filtered);
          _storageController.saveTags(tags);
        }

        if (forceRefresh) {
          tags.value = tagsList;
          tags.sort((a, b) => a.id - b.id);
        }
      },
    );

    isLoading.value = false;
    update();
  }

  Future<Tag?> getTag(int tagId) async {
    isLoading.value = true;
    update();

    if (tags.contains(tagId)) {
      isLoading.value = false;
      update();
      return tags.firstWhereOrNull((element) => element.id == tagId);
    }

    final result = await _tagApi.getTag(tagId: tagId);

    isLoading.value = false;
    update();

    return result.fold(
      (failure) {
        if (failure.showError) {
          Get.snackbar('Error', failure.message);
        }
        return null;
      },
      (tag) {
        return tag;
      },
    );
  }

  Tag? getTagsByTagName(String name) {
    return tags.firstWhereOrNull(
        (element) => element.tag.toLowerCase().contains(name));
  }

  initialize() async {
    await _storageController.loadTags();
    tags.value = _storageController.tags.value;
    if (tags.isEmpty) {
      getAllTags();
    }
  }

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> subscribeToTopics() async {
    try {
      await _storageController.loadTags();

      var tags = _storageController.tags.value;
      if (tags.isEmpty) {
        await getAllTags();
        tags = _storageController.tags.value;
      }
      var firebaseInstance = FirebaseMessaging.instance;
      for (var tag in tags) {
        var topic = tag.tag;
        if (tag.isActive) {
          if (!_isValid(tag.tag.trim())) {
            topic = toValidTopic(tag.tag.trim());
          }
          firebaseInstance.subscribeToTopic(topic).then((val) {
            debugPrint("Subscribed to $topic");
          });
        }
      }
    } catch (e) {
      debugPrint("SUBSCRIBING TO TOPIC Error: $e");
    }
  }

  String toValidTopic(String input) {
    // Define the regex for valid characters
    final validCharRegExp = RegExp(r'[a-zA-Z0-9-_.~%]');

    // Filter only valid characters
    String filtered = input
        .split('')
        .where((char) => validCharRegExp.hasMatch(char))
        .join('');

    // Truncate to 900 characters if necessary
    if (filtered.length > 900) {
      filtered = filtered.substring(0, 900);
    }

    return filtered;
  }

  Future<void> unSubscribeToTopics() async {
    try {
      await _storageController.loadTags();

      var tags = _storageController.tags.value;
      if (tags.isEmpty) {
        await getAllTags();
        tags = _storageController.tags.value;
      }
      var firebaseInstance = FirebaseMessaging.instance;
      for (var tag in tags) {
        var topic = tag.tag;
        if (tag.isActive) {
          if (!_isValid(topic)) {
            topic = toValidTopic(topic);
          }
          firebaseInstance.unsubscribeFromTopic(topic).then((val) {
            debugPrint("UNSubscribed to $topic");
          });
        }
      }
    } catch (e) {
      debugPrint("UNSUBSCRIBING TO TOPIC Error: $e");
    }
  }

  bool _isValid(String topic) {
    bool isValidTopic = RegExp(r'^[a-zA-Z0-9-_.~%]{1,900}$').hasMatch(topic);
    return isValidTopic;
  }
}
