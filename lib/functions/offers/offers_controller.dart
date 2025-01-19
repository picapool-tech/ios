import 'package:get/get.dart';
import 'package:picapool/functions/location/location_provider.dart';
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

  var offersByTagId = <int, List<Offer>>{}.obs;

  var carouselOffer = <Offer>[].obs;

  final UserController _userController = Get.find<UserController>();
  final LocationController _locationController = Get.find<LocationController>();
  final OffersApi _offersApi = OffersApi();

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
    isLoading.value = true;
    update();

    var result = await _offersApi.getAllUserCreatedOffer(
      userId: _userController.user.value!.id,
    );

    result.fold((error) {
      Get.snackbar("Error", error.message);
    }, (offers) {
      poolingOffers.value = offers.reversed.toList();
    });

    isLoading.value = false;
    update();
  }

  Future<void> getCarasouelOffer() async {
    isLoading.value = true;
    update();

    var location = _locationController.state.value;

    if (location.location == null) {
      Get.snackbar("Error", "Location not available");
      return;
    }

    var result = await _offersApi.searchOffer({
      "loc": {
        "lat": location.location!.latitude,
        "lng": location.location!.longitude,
      },
      "top": true,
    });
    result.fold(
      (error) {
        Get.snackbar("Error", error.message);
      },
      (responseModel) {
        carouselOffer.value = responseModel.data
            .map<Offer>((offer) => Offer.fromJson(offer))
            .toList();
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
    var result = await _offersApi.getChatFromOfferId(
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

  Future<List<Offer>> getOffersByTagId(int tagId) async {
    isLoading.value = true;
    update();

    var location = _locationController.state.value;

    if (location.location == null) {
      Get.snackbar("Error", "Location not available");
      return [];
    }

    final result = await _offersApi.searchOffer({
      "tagIds": [tagId],
      "loc": {
        "lat": location.location!.latitude,
        "lng": location.location!.longitude,
      }
    });

    isLoading.value = false;
    update();
    return result.fold(
      (error) {
        Get.snackbar("Error", error.message);
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

    final result = await _offersApi.getOffersForUser(
      userId: _userController.user.value!.id,
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
