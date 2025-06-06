// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:picapool/models/live_offer/create_live_offer_payload.dart';
import 'package:picapool/models/live_offer/create_live_offer_response.dart';
import 'package:picapool/models/live_offer/get_live_offer_payload.dart';
import 'package:picapool/models/live_offer/live_offer_entity.dart';
import 'package:picapool/models/live_offer/search_cabs_payload.dart';
import 'package:picapool/models/live_offer/search_cabs_response.dart';
import 'package:picapool/utils/auth_utils.dart';
import 'package:picapool/utils/constants.dart';
import 'package:picapool/utils/http_helper.dart';

class LiveOffersService {
  static Future<CreateLiveOfferResponse> createLiveOffer(
      CreateLiveOfferPayload offerPayload, String accessToken) async {
    try {
      await getAccessToken();
      final Dio dio = await getDio();
      print("=== SENDING OFFER PAYLOAD ===");
      print(offerPayload.toJson());

      final Response<dynamic> response = await dio.post(
          "${Constants.apiUrl}${Constants.createLiveOfferEndpoint}",
          data: offerPayload.toJson(),
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken'
            },
          ));

      print("=== API RESPONSE ===");
      print(response.data);

      if (response.statusCode! < 300 && response.statusCode! >= 200) {
        final responseData = response.data as Map<String, dynamic>;
        // We were incorrectly parsing the response before
        // The response.data already contains the full response
        return CreateLiveOfferResponse.fromJson(responseData);
      } else {
        print("=== ERROR: Non-200 status code ===");
        print(response.statusCode);
        print(response.data);
        throw Exception("Failed to create live offer: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("=== DIO ERROR ===");
      print(e.response?.data);
      throw Exception("Network error: ${e.message}");
    } catch (e) {
      print("=== UNEXPECTED ERROR ===");
      print(e);
      throw Exception("Unexpected error: $e");
    }
  }

  static Future<List<LiveOffer>> getAllLiveOffers(String accessToken) async {
    try {
      await getAccessToken();
      final Dio dio = await getDio();
      final response =
          await dio.get("${Constants.apiUrl}${Constants.getLiveOfferEndpoint}",
              options: Options(
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $accessToken'
                },
              ));
      if (response.statusCode! < 300 && response.statusCode! >= 200) {
        final responseData = response.data as Map<String, dynamic>;
        final productList = responseData['data'] as List<dynamic>;
        return productList
            .map((liveOffer) => LiveOffer.fromJson(liveOffer))
            .toList();
      } else {
        // Handle non-successful status codes
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        return [];
      }
    } on DioException catch (e) {
      // Handle different error types
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return [];
      } else {
        final Map<String, dynamic> data =
            e.response?.data as Map<String, dynamic>;
        final String errMessage =
            data['message'] as String? ?? 'Connection error';
        return [];
      }
    }
  }

  static Future<GetLiveOfferResponse> getLiveOffer(
      String liveOfferId, String accessToken) async {
    try {
      await getAccessToken();
      final Dio dio = await getDio();
      final Response<dynamic> response = await dio.get(
          "${Constants.apiUrl}${Constants.getLiveOfferEndpoint}/$liveOfferId",
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken'
            },
          ));
      if (response.statusCode! < 300 && response.statusCode! >= 200) {
        final responseData = response.data as Map<String, dynamic>;
        final liveOfferResponse = responseData['data'];
        debugPrint('Live Offer Response: $liveOfferResponse');
        // final LiveOffer liveOffer =
        //     LiveOffer.fromJson(liveOfferResponse as Map<String, dynamic>);
        return GetLiveOfferResponse.fromJson(responseData);
        // GetLiveOfferResponse(
        //   success: responseData['success'] as bool,
        //   liveOffer: liveOffer,
        //   message: responseData['message'] as String?,
        // );
      } else {
        // Handle non-successful status codes
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        return GetLiveOfferResponse();
      }
    } on DioException catch (e) {
      // Handle different error types
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return GetLiveOfferResponse();
      } else {
        final Map<String, dynamic> data =
            e.response?.data as Map<String, dynamic>;
        final String errMessage =
            data['message'] as String? ?? 'Connection error';
        return GetLiveOfferResponse();
      }
    }
  }

  static Future<List<SearchCabsResponse>> searchLiveOffer(
      SearchCabsPayload searchCabPayload, String accessToken) async {
    try {
      await getAccessToken();
      final Dio dio = await getDio();
      print("=== SENDING OFFER PAYLOAD ===");
      print(searchCabPayload.toJson());

      final Response<dynamic> response = await dio.post(
          "${Constants.apiUrl}${Constants.searcLiveOfferEndpoint}",
          data: searchCabPayload.toJson(),
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken'
            },
          ));

      print("=== API RESPONSE ===");
      print(response.data);

      if (response.statusCode! < 300 && response.statusCode! >= 200) {
        final responseData = response.data;
        final cabsList = responseData as List<dynamic>;
        return cabsList
            .map((cabs) => SearchCabsResponse.fromJson(cabs))
            .toList();
      } else {
        print("=== ERROR: Non-200 status code ===");
        print(response.statusCode);
        print(response.data);
        throw Exception("Failed to create live offer: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("=== DIO ERROR ===");
      print(e.response?.data);
      throw Exception("Network error: ${e.message}");
    } catch (e) {
      print("=== UNEXPECTED ERROR ===");
      print(e);
      throw Exception("Unexpected error: $e");
    }
  }
}
