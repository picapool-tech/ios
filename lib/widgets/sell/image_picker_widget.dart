import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:picapool/controllers/sell_form_controller.dart';

class ImagePickerWidget extends StatefulWidget {
  final List<String> imageFiles;
  final Function(List<String>) onImagesUploaded; // Add callback function

  const ImagePickerWidget({
    required this.imageFiles, 
    required this.onImagesUploaded,
    Key? key
  }) : super(key: key);

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final FormController formController = Get.find<FormController>();
  List<File> _imageFiles = []; // Store cropped images

  Future<void> pickImage(List<String> imageURLs) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    
    if (images != null) {
      for (var image in images) {
        File? croppedImage = await _cropImage(File(image.path));
        if (croppedImage != null) {
          setState(() {
            _imageFiles.add(croppedImage);
          });
        }
      }
      
      // Upload images and get URLs
      if (_imageFiles.isNotEmpty) {
        try {
          List<String> urls = await formController.uploadProductImages(_imageFiles);
          setState(() {
            widget.imageFiles.addAll(urls);
          });
          // Notify parent widget about new URLs
          widget.onImagesUploaded(urls);
        } catch (e) {
          print("Error uploading images: $e");
          // Handle error (show snackbar, etc.)
        }
      }
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    return await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      androidUiSettings: const AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.orange,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
      iosUiSettings: const IOSUiSettings(
        minimumAspectRatio: 1.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20),
      child: Center(
        child: GestureDetector(
          onTap: () => pickImage(widget.imageFiles),
          child: widget.imageFiles.isEmpty
              ? Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 60, color: Colors.orange),
                      Text('Add image', style: TextStyle(color: Colors.orange)),
                    ],
                  ),
                )
              : CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    enableInfiniteScroll: false,
                    enlargeCenterPage: true,
                    autoPlay: false,
                  ),
                  items: widget.imageFiles.map((imageUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                imageUrl,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.error),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () => pickImage(widget.imageFiles),
                                child: const CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.orange,
                                  child: Icon(Icons.add, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }).toList(),
                ),
        ),
      ),
    );
  }
}