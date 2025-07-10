import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picapool/common/widgets/text_field_widgets.dart';
import 'package:picapool/utils/theme.dart';

class VicinityExpandedWidget extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final List<XFile>? imagesList;
  final void Function()? onImagePicker;
  const VicinityExpandedWidget({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.onImagePicker,
    this.imagesList,
  });

  @override
  State<VicinityExpandedWidget> createState() => _VicinityExpandedWidgetState();
}

class _VicinityExpandedWidgetState extends State<VicinityExpandedWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _isExpanded = isExpanded;
        });
      },
      expandedHeaderPadding: const EdgeInsets.all(0),
      expandIconColor: Theme.of(context).primaryColor,
      children: [
        ExpansionPanel(
          canTapOnHeader: true,
          backgroundColor: AppTheme.currentTheme.scaffoldBackgroundColor,
          headerBuilder: (context, isExpanded) {
            return AppBar(
              title: const Text("Ask Around"),
              centerTitle: true,
            );
          },
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          PicaOutlinedTextField(
                            controller: widget.titleController,
                            labelText: "What do you need?",
                            hintText: "e.g. Need bike pump",
                          ),
                          const SizedBox(height: 16),
                          PicaOutlinedTextField(
                            controller: widget.descriptionController,
                            labelText: "Add more details",
                            maxLines: 2,
                            hintText:
                                "e.g. I need a bike pump to inflate my tires",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: widget.onImagePicker,
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: widget.imagesList == null ||
                                widget.imagesList!.isEmpty
                            ? const Center(
                                child: Icon(
                                  Icons.add_photo_alternate,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              )
                            : PageView.builder(
                                itemCount: widget.imagesList!.length,
                                itemBuilder: (context, index) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(widget.imagesList![index].path),
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          isExpanded: _isExpanded,
        ),
      ],
    );
  }
}
