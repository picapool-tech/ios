import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/common/widgets/dialog_widgets.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/features/tags/tag_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/features/user/values/user_data_model_enum.dart';
import 'package:picapool/models/tag_model.dart';
import 'package:picapool/screens/profile_page/widgets/notification_preferences_list_item.dart';

class NotificationPreferences extends StatefulWidget {
  const NotificationPreferences({super.key});

  @override
  State<NotificationPreferences> createState() =>
      _NotificationPreferencesState();
}

class _NotificationPreferencesState extends State<NotificationPreferences> {
  final TagController _tagController = Get.find<TagController>();
  final StorageController _storageController = Get.find<StorageController>();
  final UserController _userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (_hasChanges()) {
            updateValues();
          } else {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Notification Preferences',
            style: TextStyle(
              fontFamily: "MontserratM",
              color: Color(0xffFFFFFF),
            ),
          ),
          systemOverlayStyle:
              uiOverlayStyle(context, brightness: Brightness.dark),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(10),
            child: Obx(() {
              if (_tagController.tags.isNotEmpty &&
                  _tagController.isLoading.value) {
                return const LinearProgressIndicator();
              }
              return const SizedBox.shrink();
            }),
          ),
          automaticallyImplyLeading: true,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color(0xff02005D),
        ),
        body: GetBuilder<TagController>(
            init: _tagController,
            builder: (controller) {
              List<Tag> tags = controller.tags;

              if (controller.isLoading.value && tags.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (tags.isEmpty) {
                return const Center(
                  child: Text('No tags found'),
                );
              }

              return ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      NotificationPreferencesListItem(
                        tag: tags[index],
                        index: index,
                      ),
                      if (index != tags.length - 1) const Divider(),
                    ],
                  );
                },
              );
            }),
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      _tagController.activeTags.value =
          _userController.user!.tags?.map((tag) => tag.id).toList() ?? [];
      debugPrint("Getting tag controller: ${_tagController.activeTags}");
      debugPrint(
          "Getting user tag controller: ${_storageController.user.value!.tags}");
    });
  }

  void updateValues() async {
    try {
      showPicaLoadingDialog(message: "Updating your preferences");

      var tags = _tagController.activeTags
          .map((id) => _tagController.getTagWithId(id))
          .where((tag) => tag != null)
          .whereType<Tag>()
          .toList();

      // Update the local user object
      _storageController.user.update((user) {
        if (user != null) {
          user.tags = tags;
        }
      });

      // Send update to server
      final result = await _userController.updateUser(
        [UserField.tag],
        customExecution: (userField) => MapEntry(
          userField.apiField,
          tags.map((tag) => tag.tag).toList(),
        ),
      );

      hidePicaDialog();

      await Future.delayed(const Duration(milliseconds: 300));

      // Provide feedback to user
      if (result) {
        Get.snackbar('Success', 'Notification preferences updated',
            snackPosition: SnackPosition.TOP);
      } else {
        showPicaAlertDialog(
          title: 'Update Failed',
          message: 'Could not update notification preferences',
          confirmText: 'OK',
          onConfirm: () {
            Get.back();
          },
        );
      }
    } catch (e) {
      hidePicaDialog();
      debugPrint(e.toString());

      await Future.delayed(const Duration(milliseconds: 300));

      showPicaAlertDialog(
        title: 'Error',
        message: 'An error occurred: ${e.toString()}',
        confirmText: 'OK',
        onConfirm: () => hidePicaDialog(),
      );
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // Add this method to track if changes were made
  bool _hasChanges() {
    final currentTags = _tagController.activeTags.toSet();
    final originalTags =
        _userController.user?.tags?.map((tag) => tag.id).toSet() ?? {};

    return !setEquals(currentTags, originalTags);
  }
}
