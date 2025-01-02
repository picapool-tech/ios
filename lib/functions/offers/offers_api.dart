import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:http/http.dart' as http;
import 'package:picapool/models/response_model.dart';

class OffersApi {
  FutureEither<List<Offer>> getAllOffers({
    required String accessToken,
  }) async {
    try {
      var response = await http.get(
        Uri.parse("https://api.picapool.com/v2/offer/all"),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
      debugPrint("FROM ALL OFFERS API : ${response.body}");
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
    } catch (e) {
      debugPrint("Error while fetching all offers: $e");
      return left(Failure(
        message: "Error while fetching all offers: $e",
        stackTrace: StackTrace.current,
      ));
    }
  }

  static FutureEither<List<Offer>> getOffers(String at) async {
    try {
      final response = await http.get(
          Uri.parse('https://api.picapool.com/v2/offer/all'),
          headers: {'Authorization': "Bearer $at"});

      var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
      debugPrint("FROM OFFERS API : ${response.body}");
      if (responseModel.success) {
        return right(
          responseModel.data
              .map<Offer>((offer) => Offer.fromJson(offer))
              .toList(),
        );
      } else {
        return left(Failure(
            message: responseModel.message, stackTrace: StackTrace.current));
      }
    } catch (e) {
      return left(
        Failure(
          message: "Error while fetching offers: $e",
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
      var response = await http.get(
          Uri.parse("https://api.picapool.com/v2/chat/offer/$offerId"),
          headers: {
            'Authorization': 'Bearer $accessToken',
          });

      var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
      debugPrint("GET CHAT FROM OFFER ID : ${response.body}");
      if (responseModel.success) {
        return right(Chat.fromJson(responseModel.data));
      } else {
        return left(Failure(
          message: responseModel.message,
          stackTrace: StackTrace.current,
        ));
      }
    } catch (e) {
      debugPrint("Error while getting chat from offer: $e");
      return left(Failure(
        message: "Error while getting chat from offer: $e",
        stackTrace: StackTrace.current,
      ));
    }
  }

  FutureEither<List<Offer>> getAllUsersOffer({
    required int userId,
    required String accessToken,
  }) async {
    try {
      var response = await http.get(
          Uri.parse("https://api.picapool.com/v2/user/$userId/offers"),
          headers: {"Authorization": "Bearer $accessToken"});

      debugPrint("POOLING HISTORY RESPONSEMMODEL : ${response.body}");
      // var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
      if (response.statusCode == 200) {
        var offers = jsonDecode(response.body) as List;
        List<Offer> offersList =
            offers.map<Offer>((offer) => Offer.fromJson(offer)).toList();
        debugPrint(response.body);
        return right(offersList);
      } else {
        return left(
          Failure(
            message: "Not able to get pooling history",
            stackTrace: StackTrace.current,
          ),
        );
      }
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
}
