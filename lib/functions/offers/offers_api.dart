import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/live_offer/live_offer_entity.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/vicinity_offer_model.dart';

class OffersApi {
  final PicapoolApi _api = PicapoolApi();

  FutureEither<List<Offer>> getAllOffers({
    required String accessToken,
  }) async {
    try {
      final response = await _api.makeRequest(
        enpoint: APIEndpoints.getAllOffers,
        method: RequestMethod.getRequest,
      );

      return response.fold((error) => left(error), (responseModel) {
        if (responseModel.success) {
          return right(
            responseModel.data
                .map<Offer>((offer) => Offer.fromJson(offer))
                .toList(),
          );
        } else {
          return left(Failure(
            message: responseModel.message,
            stackTrace: StackTrace.current,
          ));
        }
      });
    } catch (e) {
      debugPrint("Error while fetching all offers: $e");
      return left(Failure(
        message: "Error while fetching all offers: $e",
        stackTrace: StackTrace.current,
      ));
    }
  }

  FutureEither<List<Offer>> getAllUserCreatedOffer({
    required int userId,
    required String accessToken,
  }) async {
    try {
      var response = await _api.makeRequest(
        enpoint: APIEndpoints.getAllUserCreatedOffer(userId),
        method: RequestMethod.getRequest,
      );

      return response.fold((error) => left(error), (responseModel) {
        if (responseModel.success) {
          var offers = responseModel.data as List;
          List<Offer> offersList =
              offers.map<Offer>((offer) => Offer.fromJson(offer)).toList();
          return right(offersList);
        } else {
          return left(
            Failure(
              message: responseModel.message,
              stackTrace: StackTrace.current,
            ),
          );
        }
      });

      // debugPrint("POOLING HISTORY RESPONSEMMODEL : ${response.body}");
      // var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
      // if (response.statusCode == 200) {
      //   var offers = jsonDecode(response.body) as List;
      //   List<Offer> offersList =
      //       offers.map<Offer>((offer) => Offer.fromJson(offer)).toList();
      //   debugPrint(response.body);
      //   return right(offersList);
      // } else {
      //   return left(
      //     Failure(
      //       message: "Not able to get pooling history",
      //       stackTrace: StackTrace.current,
      //     ),
      //   );
      // }
    } catch (e) {
      debugPrint("Errro getting pooling history : $e");
      return left(
        Failure(
          message: "Not able to fetch pooling history at this time.",
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  FutureEither<Chat> getChatFromOfferId({
    required String accessToken,
    required int offerId,
  }) async {
    try {
      final response = await _api.makeRequest(
        enpoint: APIEndpoints.getChatFromOfferId(offerId),
        method: RequestMethod.getRequest,
      );

      return response.fold((error) => left(error), (responseModel) {
        if (responseModel.success) {
          return right(Chat.fromJson(responseModel.data));
        } else {
          return left(
            Failure(
              message: responseModel.message,
              stackTrace: StackTrace.current,
            ),
          );
        }
      });
    } catch (e) {
      debugPrint("Error while getting chat from offer: $e");
      return left(Failure(
        message: "Error while getting chat from offer: $e",
        stackTrace: StackTrace.current,
      ));
    }
  }

  FutureEither<List<Offer>> getOffersByTagId(int tagId) async {
    try {
      final response = await _api.makeRequest(
        enpoint: APIEndpoints.getOffersByTagId(tagId),
        method: RequestMethod.getRequest,
      );

      return response.fold((error) => left(error), (responseModel) {
        if (responseModel.success) {
          return right(
            responseModel.data
                .map<Offer>((offer) => Offer.fromJson(offer))
                .toList(),
          );
        } else {
          return left(
            Failure(
              message: responseModel.message,
              stackTrace: StackTrace.current,
            ),
          );
        }
      });
    } catch (e) {
      return left(
        Failure(
          message: "Not able to get offers by tag id",
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  FutureEither<List<Offer>> getOffersForUser({
    required int userId,
    required String accessToken,
  }) async {
    try {
      final response = await _api.makeRequest(
        enpoint: APIEndpoints.getOffersForUser(userId),
        method: RequestMethod.getRequest,
      );

      return response.fold((error) => left(error), (responseModel) {
        if (responseModel.success) {
          var offers = responseModel.data['Offers'];
          List<Offer> offersList =
              offers.map<Offer>((offer) => Offer.fromJson(offer)).toList();

          var liveOffers = responseModel.data['LiveOffers'];
          List<LiveOffer> liveOffersList = liveOffers
              .map<LiveOffer>((liveOffer) => LiveOffer.fromJson(liveOffer))
              .toList();

          return right(offersList);
        } else {
          return left(
            Failure(
              message: responseModel.message,
              stackTrace: StackTrace.current,
            ),
          );
        }
      });
    } catch (e) {
      return left(
        Failure(
          message: "Error while fetching offers: $e",
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  // FutureEither<List<Offer>> getAllUsersOffer({
  //   required int userId,
  //   required String accessToken,
  // }) async {
  //   try {
  //     var response = await _api.makeRequest(
  //       enpoint: "/v2/user/$userId/offers",
  //       method: RequestMethod.getRequest,
  //       requireAccessToken: true,
  //     );

  //     return response.fold((error) {
  //       return left(
  //         Failure(
  //           message: error.message,
  //           stackTrace: StackTrace.current,
  //         ),
  //       );
  //     }, (responseModel) {
  //       if (responseModel.success) {
  //         var offers = responseModel.data as List;
  //         List<Offer> offersList =
  //             offers.map<Offer>((offer) => Offer.fromJson(offer)).toList();
  //         return right(offersList);
  //       } else {
  //         return left(
  //           Failure(
  //             message: responseModel.message,
  //             stackTrace: StackTrace.current,
  //           ),
  //         );
  //       }
  //     });

  //     // var response = await http.get(
  //     //     Uri.parse("https://api.picapool.com/v2/user/$userId/offers"),
  //     //     headers: {"Authorization": "Bearer $accessToken"});

  //     // debugPrint("POOLING HISTORY RESPONSEMMODEL : ${response.body}");
  //     // // var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
  //     // if (response.statusCode == 200) {
  //     //   var offers = jsonDecode(response.body) as List;
  //     //   List<Offer> offersList =
  //     //       offers.map<Offer>((offer) => Offer.fromJson(offer)).toList();
  //     //   debugPrint(response.body);
  //     //   return right(offersList);
  //     // } else {
  //     //   return left(
  //     //     Failure(
  //     //       message: "Not able to get pooling history",
  //     //       stackTrace: StackTrace.current,
  //     //     ),
  //     //   );
  //     // }
  //   } catch (e) {
  //     debugPrint("Errro getting pooling history : $e");
  //     return left(
  //       Failure(
  //         message: "Not able to fetch pooling history at this time.",
  //         stackTrace: StackTrace.current,
  //       ),
  //     );
  //   }
  // }

  FutureEither<List<Offer>> getOffersInVicinity({
    required String accessToken,
    required VicinityLocation location,
  }) async {
    try {
      var body = {
        "loc": {
          "lat": location.lat.toDouble(),
          "lng": location.long.toDouble(),
        },
        "radius": 1000,
        "chats": true,
        "products": false,
      };

      debugPrint("Request body of nearest offer: ${body.toString()}");

      final response = await _api.makeRequest(
        enpoint: APIEndpoints.getOffersInVicinity,
        method: RequestMethod.post,
        body: body,
        additionalHeaders: {
          'Content-Type': 'application/json',
        },
      );

      return response.fold((error) => left(error), (responseModel) {
        if (responseModel.success) {
          return right(
            responseModel.data
                .map<Offer>((offer) => Offer.fromJson(offer))
                .toList(),
          );
        } else {
          return left(
            Failure(
              message: responseModel.message,
              stackTrace: StackTrace.current,
            ),
          );
        }
      });
    } catch (e) {
      debugPrint("Error in getOffersInVicinity : $e");
      return left(
        Failure(
          message: "Not able to get offers in vicinity",
          stackTrace: StackTrace.current,
        ),
      );
    }
  }
}
