import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:picapool/core/api_impl.dart';
import 'package:picapool/core/core.dart';

class AssetsApi with PicapoolApiClass {
  FutureEither<List<String>> uploadImagesToServer({
    required List<XFile> pickedFiles,
  }) async {
    try {
      var files = pickedFiles.map((file) => File(file.path)).toList();
      log("files of length ${files.length}");
      return api.uploadMultipleFiles(
        files: files,
        uploadPath: 'images/pool',
        requireAccessToken: true,
        compressImage: true,
      );
    } catch (e) {
      debugPrint('Error in uploadImageToServer: $e');
      return left(
        Failure(
          message: "Failed to upload image",
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  FutureEither<String> uploadImageToServer({
    XFile? pickedFile,
    required String fileName,
  }) async {
    if (pickedFile == null) {
      return left(Failure(
          message: "No image selected", stackTrace: StackTrace.current));
    }

    try {
      File tempFile = File(pickedFile.path);
      String uploadFileName = path.basename(pickedFile.path);

      return api.uploadFile(
        file: tempFile,
        pickedFile: pickedFile,
        uploadPath: 'images/pool',
        fileName: uploadFileName,
        requireAccessToken: true,
        compressImage: true,
      );
    } catch (e) {
      debugPrint('Error in uploadImageToServer: $e');
      return left(
        Failure(
          message: "Failed to upload image",
          stackTrace: StackTrace.current,
        ),
      );
    }
  }
}
