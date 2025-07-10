import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  static File compressAndResizeImage(File file) {
    img.Image? image = img.decodeImage(file.readAsBytesSync());

    if (image == null) {
      throw Exception('Invalid image');
    }

    // Resize the image to have the longer side be 800 pixels
    int width;
    int height;

    if (image.width > image.height) {
      width = 800;
      height = (image.height / image.width * 800).round();
    } else {
      height = 800;
      width = (image.width / image.height * 800).round();
    }

    img.Image resizedImage =
        img.copyResize(image, width: width, height: height);

    // Compress the image with JPEG format
    List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 60);

    // Create compressed file with proper extension handling
    String originalPath = file.path;
    String directory = file.parent.path;
    String nameWithoutExtension = file.uri.pathSegments.last.split('.').first;
    String compressedPath = '$directory/${nameWithoutExtension}_compressed.jpg';

    File compressedFile = File(compressedPath);
    compressedFile.writeAsBytesSync(compressedBytes);

    return compressedFile;
  }

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

  static Future<List<XFile>?> pickImages() async {
    // var isPhotoPermissionGranted =
    //     await PermissionUtil().isPhotoPermissionGranted();
    // if (!isPhotoPermissionGranted) {
    //   isPhotoPermissionGranted =
    //       await PermissionUtil().requestPhotoPermission();
    //   if (!isPhotoPermissionGranted) {
    //     return null;
    //   }
    // }
    final pickedFiles = await _picker.pickMultiImage(
      imageQuality: 10,
    );

    return pickedFiles;
  }
}
