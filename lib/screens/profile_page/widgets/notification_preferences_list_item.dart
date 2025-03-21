import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/features/tags/tag_controller.dart';
import 'package:picapool/models/tag_model.dart';

class NotificationPreferencesListItem extends StatefulWidget {
  final Tag tag;
  final int index;

  const NotificationPreferencesListItem({
    super.key,
    required this.tag,
    required this.index,
  });

  @override
  State<NotificationPreferencesListItem> createState() =>
      _NotificationPreferencesListItemState();
}

class _NotificationPreferencesListItemState
    extends State<NotificationPreferencesListItem> {
  final TagController _tagController = Get.find<TagController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return SwitchListTile.adaptive(
          value: _tagController.activeTags.contains(widget.tag.id),
          onChanged: (newValue) {
            setState(
              () {
                if (newValue) {
                  if (!_tagController.activeTags.contains(widget.tag.id)) {
                    _tagController.activeTags.add(widget.tag.id);
                  }
                } else {
                  _tagController.activeTags.remove(widget.tag.id);
                }
              },
            );
          },
          title: Text(
            widget.tag.tag,
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
              imageUrl: widget.tag.icon, // Use the provided image path
              width: 28, // Adjust the size as needed
              height: 28,
              fit: BoxFit.cover,
              // color: (isDisabled) ? Colors.grey : null,
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
