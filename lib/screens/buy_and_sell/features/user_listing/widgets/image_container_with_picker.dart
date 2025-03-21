import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picapool/common/widgets/dotted_border.dart';
import 'package:picapool/utils/theme.dart';

class ImageContainerWithPicker extends StatefulWidget {
  final VoidCallback onClicked;
  final List<XFile> images;
  final String? hintText;
  final void Function(int) onImageRemoveTap;
  const ImageContainerWithPicker({
    super.key,
    required this.onClicked,
    required this.images,
    required this.onImageRemoveTap,
    this.hintText,
  });

  @override
  State<ImageContainerWithPicker> createState() =>
      _ImageContainerWithPickerState();
}

class _ImageContainerWithPickerState extends State<ImageContainerWithPicker> {
  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      // curve: Curves.easeInOut,
      firstChild: _emptyContainer(),
      secondChild: listOfImages(),
      duration: const Duration(milliseconds: 500),
      crossFadeState: (widget.images.isEmpty)
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
    );
  }

  Widget listOfImages() {
    return Container(
      height: Get.width * 0.6,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _emptyContainer();
          }
          var file = File(widget.images[index - 1].path);
          return Stack(
            children: [
              Container(
                width: Get.width * 0.5,
                height: Get.height * 0.5,
                decoration: roundedContainer(),
                clipBehavior: Clip.hardEdge,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: Image.file(
                  file,
                  fit: BoxFit.cover,
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                    return child;
                  },
                ),
              ),
              // Delete button overlay
              Positioned(
                top: 0,
                right: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        widget.onImageRemoveTap(index - 1);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _emptyContainer() {
    return CustomPaint(
      painter: DottedBorderPainter(
        color: AppTheme.currentTheme.disabledColor,
        strokeWidth: 2.0,
        dashLength: 6.0,
        dashGap: 3.0,
        borderRadius: 12.0,
      ),
      child: Container(
        height: Get.width * 0.6,
        decoration: roundedContainer(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                label: const Text("Add images"),
                onPressed: widget.onClicked,
                icon: const Icon(
                  CupertinoIcons.add_circled,
                ),
              ),
              if (widget.hintText != null && widget.images.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    widget.hintText!,
                    textAlign: TextAlign.center,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.currentTheme.disabledColor,
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
