// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';

// int selectedConditionIndex = -1; // To keep track of selected condition

// Future<void> pickImage(List<File> imageFiles) async {
//   final ImagePicker picker = ImagePicker();
//   final List<XFile>? images = await picker.pickMultiImage();
//   if (images != null) {
//     for (var image in images) {
//       File? croppedImage = await _cropImage(File(image.path));
//       if (croppedImage != null) {
//           imageFiles.add(croppedImage);
//       }
//     }
//   }
// }

// Future<File?> _cropImage(File imageFile) async {
//   return await ImageCropper().cropImage(
//     sourcePath: imageFile.path,
//     aspectRatioPresets: [
//       CropAspectRatioPreset.square,
//     ],
//     androidUiSettings: const AndroidUiSettings(
//       toolbarTitle: 'Crop Image',
//       toolbarColor: Colors.orange,
//       toolbarWidgetColor: Colors.white,
//       initAspectRatio: CropAspectRatioPreset.square,
//       lockAspectRatio: true,
//     ),
//     iosUiSettings: const IOSUiSettings(
//       minimumAspectRatio: 1.0,
//     ),
//   );
// }

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  static Future<File> imageToFile({
    required String assetName,
  }) async {
    var bytes = await rootBundle.load(assetName);
    String tempPath = (await getTemporaryDirectory()).path;
    File file = File('$tempPath/temp.png');
    await file.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    return file;
  }
}
