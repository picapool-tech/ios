import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picapool/functions/assets/assets_controller.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/user/user_controller.dart';
import 'package:picapool/functions/vicinity/vicinity_api.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/vicinity_offer_model.dart';

class VicinityController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final UserController _userController = Get.find<UserController>();
  final VicinityApi _vicinityApi = VicinityApi();
  final AssetsController _assetsController = AssetsController();

  var isLoading = false.obs;
  var offers = <Offer>[].obs;

  Future<Offer?> createVicinity({
    required VicinityOffer offer,
    required XFile? pickedFile,
    required String uname,
    required String offername,
  }) async {
    isLoading.value = true;
    update();
    String? uploadedImage = '';
    if (pickedFile != null) {
      uploadedImage = await _assetsController.uploadImage(pickedFile,
          '$uname-$offername-${DateTime.now().toIso8601String()}.jpg');

      if (uploadedImage == null) {
        Get.snackbar("Error", "Not able to upload image");
        return null;
      }
    }

    var newOffer = VicinityOffer(
      name: offer.name,
      images: (uploadedImage.isNotEmpty) ? [uploadedImage] : [],
      desc: offer.desc,
      expiryAt: offer.expiryAt,
      userId: _userController.user.value!.id,
      tagIds: [],
      location: offer.location,
      distance: offer.distance,
    );

    var accessToken = await _authController.getAccessToken();
    debugPrint("FROM REQUEST VICINITY: $accessToken");

    final result = await _vicinityApi.createVicinity(
      offer: newOffer,
      accessToken: accessToken!,
    );

    isLoading.value = false;
    update();

    return result.fold(
      (failure) async {
        Get.snackbar('Error', failure.message,
            snackPosition: SnackPosition.TOP);
        if (uploadedImage != null) {
          await deleteImage(
              "$uname-$offername-${DateTime.now().toIso8601String()}.jpg");
        }
        return null;
      },
      (offer) {
        // offers.add(offer);
        Get.snackbar('Success', 'Offer created successfully',
            snackPosition: SnackPosition.TOP);
        return offer;
      },
    );
  }

  Future<void> searchVicinity() async {
    isLoading.value = true;
    update();

    final result = await _vicinityApi.searchVicinity();

    result.fold(
      (failure) {
        Get.snackbar('Error', failure.message,
            snackPosition: SnackPosition.BOTTOM);
      },
      (offersList) {
        offers.value = offersList;
        Get.snackbar('Success', 'Offers fetched successfully',
            snackPosition: SnackPosition.BOTTOM);
      },
    );

    isLoading.value = false;
    update();
  }

  Future<bool> deleteImage(String imageName) async {
    isLoading.value = true;
    update();

    var accessToken = await _authController.getAccessToken();

    final result = await _vicinityApi.deleteImage(
      fileName: imageName,
      accessToken: accessToken!,
    );

    result.fold(
      (failure) {
        return false;
      },
      (success) {
        return true;
      },
    );

    isLoading.value = false;
    update();
    return false;
  }
}
