import 'dart:async';
import 'package:get/get.dart';
import 'package:picapool/models/live_offer/create_live_offer_payload.dart';
import 'package:picapool/models/live_offer/create_live_offer_response.dart';
import 'package:picapool/models/live_offer/get_live_offer_payload.dart';
import 'package:picapool/services/live_offers/live_offers_service.dart';

enum GetLiveOfferState { liveofferLoading, liveofferLoaded, liveofferCantLoad }
enum CreateLiveOfferState { creating, created, error }
// enum IndividualLiveOfferState { liveofferLoading, liveofferLoaded, liveofferCantLoad }

class LiveOfferController extends GetxController {
  GetLiveOfferState liveofferState = GetLiveOfferState.liveofferLoaded;
  CreateLiveOfferState createLiveOfferState = CreateLiveOfferState.created;
  // IndividualLiveOfferState individualLiveOfferState = IndividualLiveOfferState.liveofferLoading;

  /// Get liveoffer by ID
  Future<void> getLiveOffer(String liveOfferId) async {
    liveofferState = GetLiveOfferState.liveofferLoading;
    update();

    try {
      final GetLiveOfferResponse response = await LiveOffersService.getLiveOffer(liveOfferId); 
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

  // / Create a new live offer
  Future<void> createLiveOffer(CreateLiveOfferPayload createLiveOfferPayload) async {
    createLiveOfferState = CreateLiveOfferState.creating;
    update();

    final CreateLiveOfferResponse response = await LiveOffersService.createLiveOffer(createLiveOfferPayload);
    if (response.success ?? false) {
      createLiveOfferState = CreateLiveOfferState.created;
    } else {
      createLiveOfferState = CreateLiveOfferState.error;
    }
    update();
  }
}
