import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:picapool/core/api_impl.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/offer_search_request_model.dart';
import 'package:picapool/models/response_model.dart';
import 'package:picapool/models/vicinity_offer_model.dart';

class OffersApi with PicapoolApiClass {
  FutureEither<List<Offer>> getAllOffers() async {
    try {
      final response = await api.makeRequest(
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
  }) async {
    try {
      var response = await api.makeRequest(
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
    required int offerId,
  }) async {
    try {
      final response = await api.makeRequest(
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

  FutureEither<Offer> getOfferDetails(int id) async {
    try {
      var result = await api.makeRequest(
        enpoint: APIEndpoints.getOfferDetails(id),
        method: RequestMethod.getRequest,
      );

      return result.fold(
        (error) => left(error),
        (responseModel) {
          if (responseModel.success) {
            log("RESPONSE OF OFFER DETAILS: ${responseModel.data}");
            return right(Offer.fromJson(responseModel.data));
          } else {
            return left(
              Failure(
                message: responseModel.message,
                stackTrace: StackTrace.current,
              ),
            );
          }
        },
      );
    } catch (e) {
      debugPrint("Error in getOfferDetails : $e");
      return left(
        Failure(
          message: "Not able to get offer details",
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  FutureEither<List<Offer>> getOffersByTagId(int tagId) async {
    try {
      final response = await api.makeRequest(
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

  FutureEither<List<Offer>> getOffersForUser(
      OfferSearchRequestModel offerRequest) async {
    try {
      final response = await searchOffer(offerRequest);

      return response.fold((error) => left(error), (responseModel) {
        if (responseModel.success) {
          var offers = responseModel.data;
          List<Offer> offersList =
              offers.map<Offer>((offer) => Offer.fromJson(offer)).toList();

          // var liveOffers = responseModel.data['LiveOffers'];
          // List<LiveOffer> liveOffersList = liveOffers
          //     .map<LiveOffer>((liveOffer) => LiveOffer.fromJson(liveOffer))
          //     .toList();

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
  //     var response = await api.makeRequest(
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

      final response = await api.makeRequest(
        enpoint: APIEndpoints.searchOffer,
        method: RequestMethod.post,
        body: body,
        additionalHeaders: {
          'Content-Type': 'application/json',
        },
      );

      return response.fold((error) => left(error), (responseModel) async {
        if (responseModel.success) {
          List<Offer> offers =
              await responseModel.parseDataList<Offer>(Offer.fromJson);
          return right(offers);
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

  FutureEither<ResponseModel> searchOffer(
      OfferSearchRequestModel offerModel) async {
    try {
      final response = await api.makeRequest(
        enpoint: APIEndpoints.searchOffer,
        method: RequestMethod.post,
        body: offerModel.toJson(),
        additionalHeaders: {
          'Content-Type': 'application/json',
        },
      );

      return response.fold((error) => left(error), (responseModel) {
        return right(responseModel);
      });
    } catch (e) {
      debugPrint("Error while searching offer: $e");
      return left(Failure(
        message: "Error while searching offer: $e",
        stackTrace: StackTrace.current,
      ));
    }
  }

  FutureEither<Offer> updateOffer({
    required Offer updatedOffer,
  }) async {
    try {
      debugPrint("Updating offer with ID: ${updatedOffer.id}");
      debugPrint("Update payload: ${updatedOffer.toJson()}");

      var result = await api.makeRequest(
        enpoint: APIEndpoints.updateOfferDetails(updatedOffer.id),
        method: RequestMethod.patch,
        body: {
          "expiryAt": updatedOffer.expiryAt.toUtc().toIso8601String(),
        },
      );

      return result.fold((error) {
        debugPrint("Error response from API: ${error.message}");
        return left(error);
      }, (responseModel) async {
        debugPrint("Success response: ${responseModel.message}");
        debugPrint("Response data: ${responseModel.data}");
        var offer = await responseModel.parseData<Offer>(Offer.fromJson);
        debugPrint("Parsed offer: ${offer.toJson()}");
        return right(offer);
      });
    } catch (e, stackTrace) {
      debugPrint("Error while updating offer: $e");
      debugPrint("Stack trace: $stackTrace");
      return left(
        Failure(
            message: "Not able to update offer information: $e",
            stackTrace: stackTrace),
      );
    }
  }
}
