import 'package:picapool/models/live_offer/create_live_offer_payload.dart';
import 'package:picapool/models/live_offer/create_live_offer_response.dart';
import 'package:picapool/models/live_offer/get_live_offer_payload.dart';
import 'package:picapool/utils/auth_utils.dart';
import 'package:picapool/utils/constants.dart';
import 'package:picapool/utils/http_helper.dart';
import 'package:dio/dio.dart';

class LiveOffersService {
  static Future<GetLiveOfferResponse> getLiveOffer(String liveOfferId)async{
    GetLiveOfferResponse liveOfferResponse;
    try {
      await getAccessToken();
      final Dio dio = await getDio();
      final Response<dynamic> response = await dio.get(
        "${Constants.apiUrl}${Constants.getLiveOfferEndpoint}/$liveOfferId",
      );
      if (response.statusCode! < 300 && response.statusCode! >= 200) {
        final responseData = response.data as Map<String, dynamic>;
        final liveOfferResponse = responseData['data'];
        return liveOfferResponse.map( (liveOffer)=> GetLiveOfferResponse.fromJson(liveOffer) ).toList();
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
  static Future<CreateLiveOfferResponse> createLiveOffer(CreateLiveOfferPayload offerPayload)async{
    CreateLiveOfferResponse createLiveOfferResponse;
    try {
      await getAccessToken();
      final Dio dio = await getDio();
      final Response<dynamic> response = await dio.post(
        "${Constants.apiUrl}${Constants.createLiveOfferEndpoint}",
        data: offerPayload.toJson()
      );
      if (response.statusCode! < 300 && response.statusCode! >= 200) {
        final responseData = response.data as Map<String, dynamic>;
        final createLiveOfferResponse = responseData['data'];
        return createLiveOfferResponse.map( (liveOffer)=> CreateLiveOfferResponse.fromJson(liveOffer) ).toList();
      } else {
        // Handle non-successful status codes
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        return CreateLiveOfferResponse();
      }
    } on DioException catch (e) {
      // Handle different error types
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return CreateLiveOfferResponse();
      } else {
        final Map<String, dynamic> data =
            e.response?.data as Map<String, dynamic>;
        final String errMessage =
            data['message'] as String? ?? 'Connection error';
        return CreateLiveOfferResponse();
      }
    }
  }
}