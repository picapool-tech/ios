import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picapool/features/assets/assets_api.dart';

class AssetsController extends GetxController {
  final AssetsApi _assetsApi = AssetsApi();

  var isLoading = false.obs;

  Future<String?> uploadImage(
    XFile? pickedFile,
    String fileName,
  ) async {
    isLoading.value = true;
    update();

    final result = await _assetsApi.uploadImageToServer(
      pickedFile: pickedFile,
      fileName: fileName,
    );

    isLoading.value = false;
    update();

    return result.fold(
      (failure) {
        if (failure.showError) {
          Get.snackbar(
            'Error',
            failure.message,
            snackPosition: SnackPosition.TOP,
          );
        }
        return null;
      },
      (url) {
        return url;
      },
    );
  }

  Future<List<String>> uploadMultipleImages(
    List<XFile> images,
  ) async {
    isLoading.value = true;
    update();

    debugPrint("Uploading image to server");
    final result = await _assetsApi.uploadImagesToServer(
      pickedFiles: images,
    );

    isLoading.value = false;
    update();

    return result.fold(
      (failure) {
        if (failure.showError) {
          Get.snackbar(
            'Error',
            failure.message,
            snackPosition: SnackPosition.TOP,
          );
        }
        return [];
      },
      (urls) {
        return urls;
      },
    );
  }

  // FutureEither<List<String>> uploadMultipleFilesWithStream({
  //   required List<File> files,
  //   required String uploadPath,
  //   String? fileNamePrefix,
  // }) async {
  //   // Create a Stream from the list of files
  //   return Stream.fromIterable(files)
  //       // Convert each file to a Future<Either<Failure, String>>
  //       .asyncMap((file) => uploadFile(
  //             file: file,
  //             uploadPath: uploadPath,
  //             fileName:
  //                 "${fileNamePrefix ?? 'upload'}_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}",
  //           ))
  //       // Collect results
  //       .fold<Either<Failure, List<String>>>(
  //           right([]), // Initial value: empty list of URLs
  //           (previous, element) => previous.fold(
  //               (failure) =>
  //                   left(failure), // If there's already a failure, keep it
  //               (urls) => element.fold(
  //                   (failure) =>
  //                       left(failure), // If this upload failed, return failure
  //                   (url) => right([...urls, url]) // Add this URL to list
  //                   )));
  // }
}
