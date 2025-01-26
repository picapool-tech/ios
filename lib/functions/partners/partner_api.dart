import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/functions/partners/partnerModel/partner_request_model.dart';
import 'package:picapool/models/partner_model.dart';

class PartnerApi {
  final PicapoolApi _api = PicapoolApi();

  FutureEither<Partner> getPartnerById({
    required int id,
    required bool products,
    required bool offers,
  }) async {
    try {
      var result = await _api.makeRequest(
        enpoint: APIEndpoints.getPartnerById(
            id: id, products: products, offers: offers),
        method: RequestMethod.getRequest,
      );

      return result.fold((l) => left(l), (responseModel) {
        if (responseModel.success) {
          return right(Partner.fromJson(responseModel.data));
        } else {
          return left(Failure(
            message: responseModel.message,
            stackTrace: StackTrace.current,
          ));
        }
      });
    } catch (e) {
      debugPrint("Error in getPartnerById: $e");
      return left(Failure(
        message: "$e",
        stackTrace: StackTrace.current,
      ));
    }
  }

  FutureEither<List<Partner>> searchPartner(PartnerRequestModel data) async {
    try {
      var response = await _api.makeRequest(
        enpoint: APIEndpoints.searchPartner,
        method: RequestMethod.post,
        additionalHeaders: {
          "Content-Type": "application/json",
        },
        body: data.toJson(),
      );

      return response.fold((error) => left(error), (responseModel) {
        if (responseModel.success) {
          var listOfPartners = responseModel.data
              .map<Partner>((partner) => Partner.fromJson(partner))
              .toList();
          return right(listOfPartners);
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
        Failure(message: "$e", stackTrace: StackTrace.current),
      );
    }
  }
}
