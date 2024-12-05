import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:http/http.dart' as http;
import 'package:picapool/models/response_model.dart';

class OffersApi {
  static FutureEither<List<Offer>> getOffers(String at) async {
    try {
      final response = await http.get(
          Uri.parse('https://api.picapool.com/v2/offer'),
          headers: {'Authorization': "Bearer $at"});

      var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
      debugPrint("FROM OFFERS API : ${response.body}");
      if (responseModel.success) {
        return right(responseModel.data
            .map<Offer>((offer) => Offer.fromJson(offer))
            .toList());
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
}
