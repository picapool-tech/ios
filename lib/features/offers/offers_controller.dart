import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/get.dart';
import 'package:picapool/core/reactive_loading.dart';
import 'package:picapool/features/location/location_controller.dart';
import 'package:picapool/features/offers/offers_api.dart';
import 'package:picapool/features/offers/values/offer_loading_enums.dart';
import 'package:picapool/features/tags/tag_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/offer_search_request_model.dart';
import 'package:picapool/models/response_model.dart';
import 'package:picapool/models/tag_model.dart';
import 'package:picapool/models/vicinity_offer_model.dart';

class OffersController extends GetxController
    with ReactiveLoading<OfferLoadingEnums> {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // showing offers for user in alerts
  var offers = <Offer>[].obs;

// for showing pooling history // used in middle button
  var nearestOffers = <Offer>[].obs;

  // all offers not necessarily for user
  var allOffers = <Offer>[].obs;

  var poolingOffers = <Offer>[].obs;

  var offersByTagId = <int, List<Offer>>{}.obs;

  var carouselOffer = <Offer>[].obs;

  final UserController _userController = Get.find<UserController>();
  final LocationController _locationController = Get.find<LocationController>();
  final OffersApi _offersApi = OffersApi();

  Future<Offer?> deleteOffer({required int offerId}) async {
    try {
      var response = await _offersApi.deleteOffer(id: offerId);
      return response.fold(
        (error) => null,
        (offer) => offer,
      );
    } catch (e) {
      debugPrint("Error in deleting offer");
      return null;
    }
  }

  Future<void> fetchAllOffers() async {
    isLoading.value = true;
    errorMessage.value = '';
    update();

    final result = await _offersApi.getAllOffers();

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

  // pooling offers request
  Future<void> getAllUserCreatedOffer() async {
    startLoading(OfferLoadingEnums.poolingHistory);
    update();

    var result = await _offersApi.getAllUserCreatedOffer(
      userId: _userController.user!.id,
    );

    result.fold((error) {
      Get.snackbar("Error", error.message);
    }, (offers) {
      poolingOffers.value = offers.reversed.toList();
    });

    stopLoading(OfferLoadingEnums.poolingHistory);
    update();
  }

  Future<void> getCarasouelOffer() async {
    startLoading(OfferLoadingEnums.carousel);
    update();

    if (!await _locationController.isLocationEnabled()) {
      stopLoading(OfferLoadingEnums.carousel);
      update();
      return;
    }
    // Wait until location is not null
    while (_locationController.state.value.location == null) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    var location = _locationController.state.value;

    var tagController = Get.find<TagController>();
    List<Tag> tags = tagController.tags;
    if (tags.isEmpty) {
      await tagController.getAllTags();
      tags = tagController.tags;
    }

    var tagNames = [
      "Apparel",
      "Food",
      "Electronics",
      "Medical",
      "Entertain",
      "Music"
    ];

    var tagIds = tagNames
        .map((tagName) => tagController.getTagsByTagName(tagName))
        .filter((tag) => tag != null)
        .map((tag) => tag!.id)
        .toList();

    var result = await _offersApi.searchOffer(OfferSearchRequestModel(
      loc: VicinityLocation(
        lat: location.location!.latitude,
        long: location.location!.longitude,
      ),
      radius: 10000,
      priority: true,
      tagIds: tagIds,
    ));
    
    result.fold(
      (error) {
        if (error.showError) {
          Get.snackbar("Error", error.message);
        }
      },
      (responseModel) async {
        carouselOffer.value =
            await responseModel.parseDataList<Offer>(Offer.fromJson);
      },
    );
    stopLoading(OfferLoadingEnums.carousel);
    update();
  }

  Future<Chat?> getChatFromOfferId({
    required int offerId,
  }) async {
    isLoading.value = true;
    startLoading(OfferLoadingEnums.fetchingChat);
    // update();

    var result = await _offersApi.getChatFromOfferId(
      offerId: offerId,
    );

    isLoading.value = false;
    stopLoading(OfferLoadingEnums.fetchingChat);
    // update();

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

  Future<Offer?> getOfferDetails(int id) async {
    isLoading.value = true;
    update();

    var result = await _offersApi.getOfferDetails(id);

    isLoading.value = false;
    update();

    return result.fold(
      (error) {
        Get.snackbar("Error", error.message);
        return null;
      },
      (offer) {
        debugPrint("Offer details: ${offer.toJson()}");
        return offer;
      },
    );
  }

  Future<List<Offer>> getOffersByTagId(int tagId) async {
    isLoading.value = true;
    update();

    var location = _locationController.state.value;
    while (location.isLoading) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (location.location == null) {
      Get.snackbar("Error", "Location not available");
      return [];
    }

    final result = await _offersApi.searchOffer(OfferSearchRequestModel(
      loc: VicinityLocation(
        lat: location.location!.latitude,
        long: location.location!.longitude,
      ),
      tagIds: [tagId],
      radius: 5000,
    ));

    isLoading.value = false;
    update();
    return result.fold(
      (error) {
        if (error.showError) {
          Get.snackbar("Error", error.message);
        }
        return [];
      },
      (responseModel) {
        offersByTagId[tagId] = responseModel.data
            .map<Offer>((offer) => Offer.fromJson(offer))
            .toList();
        return offers;
      },
    );
  }

  Future<void> getOffersForUser() async {
    isLoading.value = true;
    errorMessage.value = '';
    update();

    while (_locationController.state.value.isLoading) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final result = await _offersApi.getOffersForUser(
      OfferSearchRequestModel(
        loc: VicinityLocation(
          lat: _locationController.state.value.location!.latitude,
          long: _locationController.state.value.location!.longitude,
        ),
        radius: 5000,
        chats: true,
        products: false,
      ),
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message,
            snackPosition: SnackPosition.TOP);
      },
      (offersList) {
        offers.value = offersList.toList();
      },
    );

    isLoading.value = false;
    update();
  }

  Future<void> getOffersInVicinity({
    required VicinityLocation location,
  }) async {
    isLoading.value = true;
    update();

    var result = await _offersApi.getOffersInVicinity(
      location: location,
    );

    result.fold(
      (error) {
        if (error.showError) {
          Get.snackbar(
            "Error",
            error.message,
          );
        }
      },
      (nearestOffersResponse) {
        nearestOffers.value = nearestOffersResponse.reversed.toList();
      },
    );
    isLoading.value = false;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    initializeLoadingStates(OfferLoadingEnums.values);
  }

  Future<Offer?> updateOffer({
    required Offer updatedOffer,
  }) async {
    startLoading(OfferLoadingEnums.updateOffer);
    update();
    var response = await _offersApi.updateOffer(updatedOffer: updatedOffer);

    return response.fold((error) {
      stopLoading(OfferLoadingEnums.updateOffer);
      update();
      debugPrint("Not able to update the offer information this time.");
      return null;
    }, (offer) {
      stopLoading(OfferLoadingEnums.updateOffer);
      update();
      return offer;
    });
  }
}
