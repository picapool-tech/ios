import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/vicinity/vicinity_api.dart';
import 'package:picapool/models/vicinity_offer_model.dart';

class VicinityController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final VicinityApi _vicinityApi = VicinityApi();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var offers = <VicinityOffer>[].obs;

  Future<void> createVicinity({
    required VicinityOffer offer,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    update();

    final result = await _vicinityApi.createVicinity(
      offer: offer,
      accessToken: authController.auth.value!.accessToken!,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message,
            snackPosition: SnackPosition.TOP);
      },
      (offer) {
        offers.add(offer);
        Get.snackbar('Success', 'Offer created successfully',
            snackPosition: SnackPosition.TOP);
      },
    );

    isLoading.value = false;
    update();
  }

  Future<String?> uploadImage(
      XFile? pickedFile, String uname, String offername) async {
    isLoading.value = true;
    errorMessage.value = '';
    update();

    final result = await _vicinityApi.uploadImageToServer(
      pickedFile: pickedFile,
      uname: uname,
      offername: offername,
      accessToken: authController.auth.value!.accessToken!,
    );

    isLoading.value = false;
    update();

    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message,
            snackPosition: SnackPosition.BOTTOM);
        return null;
      },
      (url) {
        return url;
      },
    );
  }

  Future<void> searchVicinity() async {
    isLoading.value = true;
    errorMessage.value = '';
    update();

    final result = await _vicinityApi.searchVicinity();

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
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
}
