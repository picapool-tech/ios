import 'dart:async';

import 'package:get/get.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/models/live_offer/create_live_offer_payload.dart';
import 'package:picapool/models/live_offer/create_live_offer_response.dart';
import 'package:picapool/models/live_offer/get_live_offer_payload.dart';
import 'package:picapool/models/live_offer/live_offer_entity.dart';
import 'package:picapool/models/live_offer/search_cabs_payload.dart';
import 'package:picapool/models/live_offer/search_cabs_response.dart';
import 'package:picapool/services/live_offers/live_offers_service.dart';

enum CreateLiveOfferState { initial, creating, created, error }

enum GetAllLiveOfferState {
  allLiveOffersLoading,
  allLiveOffersLoaded,
  allLiveOffersCantLoad
}

enum GetLiveOfferState { liveofferLoading, liveofferLoaded, liveofferCantLoad }
// enum IndividualLiveOfferState { liveofferLoading, liveofferLoaded, liveofferCantLoad }

class LiveOfferController extends GetxController {
  // final AuthController authController = Get.find<AuthController>();
  final StorageController storageController = Get.find<StorageController>();
  List<LiveOffer> liveOffersList = <LiveOffer>[];

  GetLiveOfferState liveofferState = GetLiveOfferState.liveofferLoading;

  GetAllLiveOfferState allLiveofferState =
      GetAllLiveOfferState.allLiveOffersLoaded;
  CreateLiveOfferState createLiveOfferState = CreateLiveOfferState.initial;
  SearchLiveOfferState searchLiveOfferState = SearchLiveOfferState.initial;
  CreateLiveOfferResponse? createLiveOfferResponse;
  List<SearchCabsResponse>? searchCabsList;
  Future<String?>? get accessToken async => storageController.getAccessToken();
  // IndividualLiveOfferState individualLiveOfferState = IndividualLiveOfferState.liveofferLoading;

  // / Create a new live offer
  Future<void> createLiveOffer(
      CreateLiveOfferPayload createLiveOfferPayload) async {
    try {
      createLiveOfferState = CreateLiveOfferState.creating;
      update();
      final response = await LiveOffersService.createLiveOffer(
          createLiveOfferPayload, await accessToken ?? "");
      createLiveOfferResponse = response;
      createLiveOfferState = CreateLiveOfferState.created;
      update();
    } catch (e) {
      createLiveOfferState = CreateLiveOfferState.error;
      update();
    }
  }

  Future<void> getAllLiveOffers() async {
    allLiveofferState = GetAllLiveOfferState.allLiveOffersLoading;
    update();
    try {
      final List<LiveOffer> response =
          await LiveOffersService.getAllLiveOffers(await accessToken ?? "");
      if (response.isNotEmpty) {
        liveOffersList = response ?? [];
        allLiveofferState = GetAllLiveOfferState.allLiveOffersLoaded;
        update();
      } else {
        allLiveofferState = GetAllLiveOfferState.allLiveOffersCantLoad;
        update();
      }
    } catch (e) {
      allLiveofferState = GetAllLiveOfferState.allLiveOffersCantLoad;
      print('Error getting liveoffer list: $e');
    }
    update();
  }

  /// Get liveoffer by ID
  Future<LiveOffer?> getLiveOffer(String liveOfferId) async {
    liveofferState = GetLiveOfferState.liveofferLoading;
    update();

    try {
      final GetLiveOfferResponse response =
          await LiveOffersService.getLiveOffer(
              liveOfferId, await accessToken ?? "");

      if (response.success! || response.liveOffer != []) {
        liveofferState = GetLiveOfferState.liveofferLoaded;
        return response.liveOffer;
        // liveofferList = response.data ?? [];
      } else {
        liveofferState = GetLiveOfferState.liveofferCantLoad;
        return null;
      }
    } catch (e) {
      liveofferState = GetLiveOfferState.liveofferCantLoad;
      print('Error getting liveoffer list: $e');
      return null;
    } finally {
      update();
    }
  }

  // / Search among all live offer
  Future<void> searchLiveOffer(SearchCabsPayload searchLiveOfferPayload) async {
    try {
      searchLiveOfferState = SearchLiveOfferState.creating;
      update();
      final response = await LiveOffersService.searchLiveOffer(
          searchLiveOfferPayload, await accessToken ?? "");
      searchCabsList = response;
      searchLiveOfferState = SearchLiveOfferState.created;
      update();
    } catch (e) {
      searchLiveOfferState = SearchLiveOfferState.error;
      update();
    }
  }
}

enum SearchLiveOfferState { initial, creating, created, error }
