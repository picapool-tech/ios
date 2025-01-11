import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picapool/utils/center_custom_text.dart';
import 'package:picapool/utils/large_button.dart';
import 'package:picapool/utils/svg_icon.dart';

class AddProfilePicBottomSheet extends StatefulWidget {
  const AddProfilePicBottomSheet({super.key});

  @override
  State<AddProfilePicBottomSheet> createState() =>
      _AddProfilePicBottomSheetState();
}

class _AddProfilePicBottomSheetState extends State<AddProfilePicBottomSheet> {
  final ImagePicker _picker = ImagePicker();
  PickedFile? _imageFile;
  bool isImageSelected = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        maxHeight: 300,
        maxWidth: 300,
      );
      if (croppedFile != null) {
        setState(() {
          _imageFile = PickedFile(croppedFile.path);
          isImageSelected = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(34)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const CenterAlignText(
                    text: "Add a Profile Photo",
                    size: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff333333)),
                CenterAlignText(
                    text: isImageSelected
                        ? "Lookin’ Good!"
                        : "Add a picture from your library",
                    size: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff333333).withOpacity(0.5)),
                const SizedBox(height: 36),
                !isImageSelected
                    ? SizedBox(
                        height: 120,
                        child: Stack(
                          children: [
                            const SvgIcon("assets/icons/camera.svg"),
                            Transform.translate(
                                offset: const Offset(90.5, 77),
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
                                                          ImageSource.camera);
                                                      setState(() {});
                                                      if (mounted) {
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
                                                          ImageSource.gallery);
                                                      setState(() {});
                                                      if (mounted) {
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ));
                                    },
                                    child: const SvgIcon(
                                        "assets/icons/add_icon.svg")))
                          ],
                        ))
                    : SizedBox(
                        height: 120,
                        width: 120,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage:
                                  FileImage(File(_imageFile!.path)),
                            ),
                            Transform.translate(
                              offset: const Offset(90.5, 77),
                              child: InkWell(
                                child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        isImageSelected = false;
                                        _imageFile = null;
                                      });
                                    },
                                    child: const SvgIcon(
                                        "assets/icons/cross_icon.svg")),
                              ),
                            )
                          ],
                        ),
                      ),
                const SizedBox(height: 38),
                isImageSelected
                    ? LargeButton(
                        text: "Finish Signing Up",
                        onPressed: () {
                          // Navigator.pushAndRemoveUntil(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (ctx) => const ScreenRouter()),
                          //     (route) => false);
                        })
                    : LargeButton(
                        text: "Skip",
                        onPressed: () {
                          //TODO: handle skip
                        },
                        bgColor: const Color(0xffAAAAAA),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
