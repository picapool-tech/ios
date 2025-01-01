
import 'package:picapool/services/products/entities/list_of_products_entity.dart';
import 'package:picapool/services/products/payloads/create_product_payload.dart';
import 'package:picapool/services/products/payloads/update_product_payload.dart';
import 'package:picapool/services/products/responses/create_product_response.dart';
import 'package:picapool/services/products/entities/product_entity.dart';
import 'package:picapool/services/products/responses/get_all_products_response.dart';
import 'package:picapool/services/products/responses/update_product_response.dart';

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:picapool/utils/auth_utils.dart';
import 'package:picapool/utils/constants.dart';
import 'package:picapool/utils/http_helper.dart';
import 'package:logger/logger.dart';
import 'package:picapool/utils/logger_helper.dart';

class ProductsServices {
  static Future<CreateProductResponse> createProduct(
    Map<String,dynamic> createProductPayload,
  ) async {
    try {
      // print("******************** Payload ************************");
      // print(jsonEncode(createProductPayload));
      // print("*****************************************************");
      await getAccessToken();
      final Dio dio = await getDio();
      final Response<dynamic> response = await dio.post(
        Constants.apiUrl + Constants.createProductEndpoint,
        data: jsonEncode(createProductPayload),
        options: Options(headers: {'Content-Type': 'application/json'},  ),
        // data: jsonEncode(createProductPayload),
        queryParameters: <String, bool>{'withContent': true},
      );
      if (response.statusCode! < 300 && response.statusCode! >= 200) {
        final CreateProductResponse searchResult = CreateProductResponse(
          success: true,
          message: '${response.statusMessage}',
          data: Product.fromJson(response.data as Map<String, dynamic>),
        );

        return searchResult;
      } else {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final String errMessage =
            data['message'] as String? ?? 'Connection error';
        return CreateProductResponse(
          success: false,
          message: errMessage,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return CreateProductResponse(
          success: false,
          message: 'Connection Error',
        );
      } else {
        final Map<String, dynamic> data =
            e.response?.data as Map<String, dynamic>;
        final String errMessage =
            data['message'] as String? ?? 'Connection error';
        return CreateProductResponse(
          success: false,
          message: errMessage,
        );
      }
    }
  }

  static Future<UpdateProductResponse> updateProduct(
    String productId,
    UpdateProductPayload createProductPayload,
  ) async {
    try {
      await getAccessToken();
      final Dio dio = await getDio();
      final Response<dynamic> response = await dio.get(
        "${Constants.apiUrl}${Constants.createProductEndpoint}/{productId}",
        queryParameters: <String, bool>{'withContent': true},
      );
      if (response.statusCode! < 300 && response.statusCode! >= 200) {
        final UpdateProductResponse searchResult = UpdateProductResponse(
          success: true,
          message: '${response.statusMessage}',
          data: Product.fromJson(response.data as Map<String, dynamic>),
        );

        return searchResult;
      } else {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final String errMessage =
            data['message'] as String? ?? 'Connection error';
        return UpdateProductResponse(
          success: false,
          message: errMessage,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return UpdateProductResponse(
          success: false,
          message: 'Connection Error',
        );
      } else {
        final Map<String, dynamic> data =
            e.response?.data as Map<String, dynamic>;
        final String errMessage =
            data['message'] as String? ?? 'Connection error';
        return UpdateProductResponse(
          success: false,
          message: errMessage,
        );
      }
    }
  }

  static Future<List<Product>> getAllProducts() async {
    List<Product> productsList;
    try {
      await getAccessToken();
      final Dio dio = await getDio();
      final Response<dynamic> response = await dio.get(
        Constants.apiUrl + Constants.getAllProductsEndpoint,
      );
      if (response.statusCode! < 300 && response.statusCode! >= 200) {
        final responseData = response.data as Map<String, dynamic>;
        final productList = responseData['data'] as List<dynamic>;
        return productList.map((product) => Product.fromJson(product)).toList();

        // final GetAllProductsResponse allProductsResponse =
        //     GetAllProductsResponse(
        //       success: true ,
        //       message: "${response.statusMessage}" ,
        //       data: List<Product>.from(response.data.map((x) => Product.fromJson(x)))
        //     );
        // return allProductsResponse;
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
