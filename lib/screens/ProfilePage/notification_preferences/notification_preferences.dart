import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/functions/storage/storage_controller.dart';
import 'package:picapool/functions/tags/tag_controller.dart';
import 'package:picapool/models/tag_model.dart';

class NotificationPreferences extends StatefulWidget {
  const NotificationPreferences({super.key});

  @override
  State<NotificationPreferences> createState() =>
      _NotificationPreferencesState();
}

class _NotificationPreferencesState extends State<NotificationPreferences> {
  final TagController _tagController = Get.find<TagController>();
  final StorageController _storageController = Get.find<StorageController>();

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      _tagController.getAllTags(forceRefresh: false);
    });
  }

  @override
  dispose() {
    super.dispose();
    _storageController.saveTags(_tagController.tags);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notification Preferences',
          style: TextStyle(
            fontFamily: "MontserratM",
            color: Color(0xffFFFFFF),
          ),
        ),
        automaticallyImplyLeading: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff02005D),
      ),
      body: GetBuilder<TagController>(
          init: _tagController,
          builder: (controller) {
            if (controller.tags.isEmpty && controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.tags.isEmpty && !controller.isLoading.value) {
              return const Center(
                child: Text('No tags found'),
              );
            }

            return ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: controller.tags.length,
              itemBuilder: (context, index) {
                var tag = controller.tags[index];
                if (tag.isActive) {
                  FirebaseMessaging.instance
                      .subscribeToTopic(tag.tag)
                      .then((d) {
                    debugPrint("Subscriped to ${tag.tag}");
                  });
                }
                return notificationListItem(
                  controller.tags[index],
                  index: index,
                );
              },
            );
          }),
    );
  }

  Widget notificationListItem(
    Tag tag, {
    required int index,
    VoidCallback? onTap,
  }) {
    return SwitchListTile.adaptive(
      value: tag.isActive,
      onChanged: (newValue) {
        if (!newValue) {
          FirebaseMessaging.instance.unsubscribeFromTopic(tag.tag);
        } else {
          FirebaseMessaging.instance.subscribeToTopic(tag.tag);
        }
        setState(() {
          _tagController.tags[index].isActive = newValue;
        });
      },
      title: Text(
        tag.tag,
        style: const TextStyle(
          fontFamily: "MontserratR",
          fontSize: 16,
        ),
      ),
      secondary: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
        child: CachedNetworkImage(
          imageUrl: tag.icon, // Use the provided image path
          width: 28, // Adjust the size as needed
          height: 28,
          fit: BoxFit.cover,
          // color: (isDisabled) ? Colors.grey : null,
        ),
      ),
    );
  }
}
