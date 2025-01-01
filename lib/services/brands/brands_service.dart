
import 'package:picapool/models/brands/entities/brand_entity.dart';
import 'package:picapool/utils/auth_utils.dart';
import 'package:picapool/utils/constants.dart';
import 'package:picapool/utils/http_helper.dart';


import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:picapool/utils/auth_utils.dart';
import 'package:picapool/utils/constants.dart';
import 'package:picapool/utils/http_helper.dart';
import 'package:logger/logger.dart';
import 'package:picapool/utils/logger_helper.dart';



class BrandsService {
  static Future<List<Brand>> getAllBrands()async{
    List<Brand> brandsList;
    try {
      await getAccessToken();
      final Dio dio = await getDio();
      final Response<dynamic> response = await dio.get(
        Constants.apiUrl + Constants.getBrandsEndpoint,
      );
      if (response.statusCode! < 300 && response.statusCode! >= 200) {
        final responseData = response.data as Map<String, dynamic>;
        final brandsList = responseData['data'] as List<dynamic>;
        return brandsList.map( (brand)=> Brand.fromJson(brand) ).toList();
      } else {
        // Handle non-successful status codes
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        // final String errMessage =
        //     data['message'] as String? ?? 'Failed to fetch products';
        return [];
      }
    } on DioException catch (e) {
      // Handle different error types
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return [];
        // return GetAllProductsResponse(
        //   success: false,
        //   message: 'Connection Error',
        //   data: [],
        // );
      } else {
        final Map<String, dynamic> data =
            e.response?.data as Map<String, dynamic>;
        final String errMessage =
            data['message'] as String? ?? 'Connection error';
        return [];
        // GetAllProductsResponse(
        //   success: false,
        //   message: errMessage,
        //   data: [],
        // );
      }
    }
  }
}