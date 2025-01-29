import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  static File compressAndResizeImage(File file) {
    img.Image? image = img.decodeImage(file.readAsBytesSync());

    // Resize the image to have the longer side be 800 pixels
    int width;
    int height;

    if (image == null) {
      throw Exception('Invalid image');
    }

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
    List<int> compressedBytes =
        img.encodeJpg(resizedImage, quality: 85); // Adjust quality as needed

    // Save the compressed image to a file
    File compressedFile =
        File(file.path.replaceFirst('.jpg', '_compressed.jpg'));
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
}
