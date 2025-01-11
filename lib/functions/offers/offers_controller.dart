import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/offers/offers_api.dart';
import 'package:picapool/functions/user/user_controller.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/vicinity_offer_model.dart';

class OffersController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // showing offers for user in alerts
  var offers = <Offer>[].obs;

// for showing pooling history // used in middle button
  var nearestOffers = <Offer>[].obs;

  // all offers not necessarily for user
  var allOffers = <Offer>[].obs;

  var poolingOffers = <Offer>[].obs;

  final AuthController _authController = Get.find<AuthController>();
  final UserController _userController = Get.find<UserController>();
  final OffersApi _offersApi = OffersApi();

  Future<void> getOffersForUser() async {
    isLoading.value = true;
    errorMessage.value = '';
    update();
    var accessToken = await _authController.getAccessToken();
    if (accessToken == null) {
      debugPrint("Access Token Not Updated");
      return;
    }
    final result = await _offersApi.getOffersForUser(
      userId: _userController.user.value!.id,
      accessToken: accessToken,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message,
            snackPosition: SnackPosition.TOP);
      },
      (offersList) {
        offers.value = offersList.reversed.toList();
      },
    );

    isLoading.value = false;
    update();
  }

  Future<void> fetchAllOffers() async {
    isLoading.value = true;
    errorMessage.value = '';
    update();
    var accessToken = await _authController.getAccessToken();
    if (accessToken == null) {
      debugPrint("Not updated");
      return;
    }
    final result = await _offersApi.getAllOffers(accessToken: accessToken);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message,
            snackPosition: SnackPosition.TOP);
      },
      (offersList) {
        allOffers.value = offersList.reversed.toList();
        update();
      },
    );

    isLoading.value = false;
    update();
  }

  Future<Chat?> getChatFromOfferId({
    required int offerId,
  }) async {
    isLoading.value = true;
    update();

    var accessToken = await _authController.getAccessToken();

    var result = await _offersApi.getChatFromOfferId(
      accessToken: accessToken!,
      offerId: offerId,
    );

    isLoading.value = false;
    update();

    return result.fold((error) {
      Get.snackbar(
        'Error joining chat',
        error.message,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    }, (chat) {
      return chat;
    });
  }

  // pooling offers request
  Future<void> getAllUserCreatedOffer() async {
    isLoading.value = true;
    update();

    var accessToken = await _authController.getAccessToken();
    var result = await _offersApi.getAllUserCreatedOffer(
      userId: _userController.user.value!.id,
      accessToken: accessToken!,
    );

    result.fold((error) {
      Get.snackbar("Error", error.message);
    }, (offers) {
      poolingOffers.value = offers.reversed.toList();
    });

    isLoading.value = false;
    update();
  }

  Future<void> getOffersInVicinity({
    required VicinityLocation location,
  }) async {
    isLoading.value = true;
    update();
    var accessToken = await _authController.getAccessToken();

    if (accessToken == null) {
      debugPrint("Access Token Not Updated");
      isLoading.value = false;
      update();
      return;
    }

    var result = await _offersApi.getOffersInVicinity(
      accessToken: accessToken,
      location: location,
    );

    result.fold(
      (error) {
        Get.snackbar(
          "Error",
          error.message,
        );
      },
      (nearestOffersResponse) {
        nearestOffers.value = nearestOffersResponse.reversed.toList();
      },
    );
    isLoading.value = false;
    update();
  }
}
