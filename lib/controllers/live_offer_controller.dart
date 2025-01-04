import 'dart:async';
import 'package:get/get.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/models/live_offer/create_live_offer_payload.dart';
import 'package:picapool/models/live_offer/create_live_offer_response.dart';
import 'package:picapool/models/live_offer/get_all_live_offers.dart';
import 'package:picapool/models/live_offer/get_live_offer_payload.dart';
import 'package:picapool/models/live_offer/live_offer_entity.dart';
import 'package:picapool/services/live_offers/live_offers_service.dart';

enum GetLiveOfferState { liveofferLoading, liveofferLoaded, liveofferCantLoad }
enum GetAllLiveOfferState { allLiveOffersLoading, allLiveOffersLoaded, allLiveOffersCantLoad }
enum CreateLiveOfferState { initial, creating, created, error }
// enum IndividualLiveOfferState { liveofferLoading, liveofferLoaded, liveofferCantLoad }

class LiveOfferController extends GetxController {

  final AuthController authController = Get.find<AuthController>();

  String accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdXRoSWQiOjcsInRlbmFudCI6eyJ0eXBlIjoiVXNlciIsImlkIjoxMDd9LCJSb2xlcyI6W3siaWQiOjEsInJvbGUiOiJVc2VyIn1dLCJpYXQiOjE3MzU5MTA0NjYsImV4cCI6MTczNTk5Njg2Nn0.wDXYeKUYelQYh0XH7wU-bBs-yLpJnc-BLhxqxrqgtTs";
  // String? get accessToken => authController.auth.value?.accessToken;


  List<LiveOffer> liveOffersList = <LiveOffer>[];

  GetLiveOfferState liveofferState = GetLiveOfferState.liveofferLoading;
  GetAllLiveOfferState allLiveofferState = GetAllLiveOfferState.allLiveOffersLoaded;
  CreateLiveOfferState createLiveOfferState = CreateLiveOfferState.initial;
  CreateLiveOfferResponse? createLiveOfferResponse;
  // IndividualLiveOfferState individualLiveOfferState = IndividualLiveOfferState.liveofferLoading;

  /// Get liveoffer by ID
  Future<void> getLiveOffer(String liveOfferId) async {
    liveofferState = GetLiveOfferState.liveofferLoading;
    update();

    try {
      final GetLiveOfferResponse response = await LiveOffersService.getLiveOffer(liveOfferId, accessToken ?? ""); 
      if (response.success! || response.liveOffer != []) {
        var liveoffer = response;
        // liveofferList = response.data ?? [];
        liveofferState = GetLiveOfferState.liveofferLoaded;
      } else {
        liveofferState = GetLiveOfferState.liveofferCantLoad;
      }
    } catch (e) {
      liveofferState = GetLiveOfferState.liveofferCantLoad;
      print('Error getting liveoffer list: $e');
    }
    update();
  }

  Future<void> getAllLiveOffers() async {
    allLiveofferState = GetAllLiveOfferState.allLiveOffersLoading;
    update();
    try {
      final List<LiveOffer> response = await LiveOffersService.getAllLiveOffers(accessToken ?? ""); 
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

  // / Create a new live offer
  Future<void> createLiveOffer(CreateLiveOfferPayload createLiveOfferPayload) async {
    try {
      createLiveOfferState = CreateLiveOfferState.creating;
      update();
      final response = await LiveOffersService.createLiveOffer(createLiveOfferPayload, accessToken ?? "");
      createLiveOfferResponse = response;
      createLiveOfferState = CreateLiveOfferState.created;
      update();
    } catch (e) {
      createLiveOfferState = CreateLiveOfferState.error;
      update();
    }
  }
}
