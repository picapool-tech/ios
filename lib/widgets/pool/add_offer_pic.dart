import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picapool/utils/center_custom_text.dart';
import 'package:picapool/utils/large_button.dart';
import 'package:picapool/utils/svg_icon.dart';

class AddOfferImage extends StatefulWidget {
  const AddOfferImage({super.key});

  @override
  State<AddOfferImage> createState() => _AddOfferImageState();
}

class _AddOfferImageState extends State<AddOfferImage> {
  final ImagePicker _picker = ImagePicker();
  PickedFile? _imageFile;
  bool isImageSelected = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        height: size.height * 0.55,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
        ),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
            child: SingleChildScrollView(
                child: Column(children: [
              const CenterAlignText(
                  text: "Create your Pool!",
                  size: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff333333)),
              const CenterAlignText(
                  text: "Add an Offer Image",
                  size: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff666666)),
              const SizedBox(
                height: 64,
              ),
              Container(
                height: 224,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 27),
                decoration: BoxDecoration(
                  color: const Color(0xffD9D9D9),
                  borderRadius: BorderRadius.circular(42),
                ),
                child: isImageSelected
                    ? Stack(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(42),
                              child: Image.file(
                                File(_imageFile!.path),
                                fit: BoxFit.cover,
                              )),
                          Transform.translate(
                            offset: Offset(
                                size.width - 24 - 54 - 44 - 18, 224 - 44 - 18),
                            child: Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                  color: const Color(0xffFF8D41),
                                  borderRadius: BorderRadius.circular(44)),
                              child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          isImageSelected = false;
                                          _imageFile = null;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(44),
                                      child: const Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child:
                                            SvgIcon("assets/icons/cross.svg"),
                                      ))),
                            ),
                          )
                        ],
                      )
                    : Center(
                        child: Stack(
                          children: [
                            const SvgIcon("assets/icons/big_camera.svg"),
                            Transform.translate(
                              offset: const Offset(93, 82),
                              child: Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                    color: const Color(0xffFF8D41),
                                    borderRadius: BorderRadius.circular(44)),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (context) => Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  ListTile(
                                                    leading: const Icon(
                                                        Icons.camera),
                                                    title: const Text('Camera'),
                                                    onTap: () async {
                                                      await _pickImage(
                                                          ImageSource.camera,
                                                          size.width);
                                                      setState(() {});
                                                      if (context.mounted) {
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                  ),
                                                  ListTile(
                                                    leading:
                                                        const Icon(Icons.image),
                                                    title:
                                                        const Text('Gallery'),
                                                    onTap: () async {
                                                      await _pickImage(
                                                          ImageSource.gallery,
                                                          size.width);
                                                      setState(() {});
                                                      if (context.mounted) {
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ));
                                    },
                                    borderRadius: BorderRadius.circular(44),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: SvgIcon("assets/icons/plus.svg"),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
              ),
              const SizedBox(
                height: 64,
              ),
              LargeButton(text: "Next", onPressed: () {})
            ]))));
  }

  Future<void> _pickImage(ImageSource source, double width) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: width - 24 - 54, ratioY: 224),
        maxHeight: 400,
        maxWidth: 400,
      );
      if (croppedFile != null) {
        setState(() {
          _imageFile = PickedFile(croppedFile.path);
          isImageSelected = true;
        });
      }
    }
  }
}
