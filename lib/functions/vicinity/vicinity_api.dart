import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:picapool/core/core.dart';
import 'package:picapool/functions/network/connection_status_listener.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/vicinity_offer_model.dart';

String getFileName(String filePath) {
  return path.basename(filePath);
}

class VicinityApi {
  final PicapoolApi _api = PicapoolApi();

  FutureEither<Offer> createVicinity({
    required VicinityOffer offer,
  }) async {
    try {
      final response = await _api.makeRequest(
        enpoint: APIEndpoints.createOffer,
        method: RequestMethod.post,
        body: offer.toJson(),
        additionalHeaders: {
          'Content-Type': 'application/json',
        },
      );

      // final response = await http.post(
      //   Uri.parse(endpoint),
      //   body: jsonEncode(offer.toJson()),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization': 'Bearer $accessToken',
      //   },
      // );

      return response.fold((error) {
        return left(error);
      }, (responseModel) {
        if (responseModel.success) {
          var offerResponse = Offer.fromJson(responseModel.data);

          return right(offerResponse);
        } else {
          return left(Failure(
            message: responseModel.message,
            stackTrace: StackTrace.current,
          ));
        }
      });
    } catch (err) {
      debugPrint('Error creating offer to server: $err');
      return left(Failure(
        message: "Failed to create offer",
        stackTrace: StackTrace.fromString(err.toString()),
      ));
    }
  }

  FutureEither<bool> deleteImage({
    required String fileName,
    required String accessToken,
  }) async {
    try {
      if (!await ConnectionStatusListener.getInstance().checkConnection()) {
        return left(
          Failure(
            message: "No Internet Connection",
            stackTrace: StackTrace.current,
          ),
        );
      }
      var image = getFileName(fileName).split(".").first;
      debugPrint(image);
      var response = await http.delete(
        Uri.parse('https://api.picapool.com/v2/s3/delete/$image'),
        headers: {
          'Authorization': "Bearer $accessToken",
        },
      );
      debugPrint("Deleting image: ${response.body}");
      if (response.statusCode == 200) {
        return right(true);
      } else {
        return left(Failure(
          message: "Failed to delete image",
          stackTrace: StackTrace.current,
        ));
      }
    } catch (e) {
      return left(
        Failure(
            message: "Some error while deleting image",
            stackTrace: StackTrace.current),
      );
    }
  }

  FutureEither<Offer> getVicinity(int offerId) async {
    throw UnimplementedError();
  }

  FutureEither<List<Offer>> searchVicinity() async {
    throw UnimplementedError();
  }
}
