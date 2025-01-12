import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:picapool/models/offers/create_offer_payload.dart';
import 'package:picapool/models/offers/create_offer_response.dart';
import 'package:picapool/models/offers/location_entity.dart';
import 'package:picapool/models/offers/search_offer_payload.dart';
import 'package:picapool/models/offers/search_offer_response.dart';
import 'package:picapool/services/products/entities/product_entity.dart';
import 'package:picapool/services/products/payloads/create_product_payload.dart';
import 'package:picapool/services/products/payloads/update_product_payload.dart';
import 'package:picapool/services/products/responses/create_product_response.dart';
import 'package:picapool/services/products/responses/get_single_product_response.dart';
import 'package:picapool/services/products/responses/update_product_response.dart';
import 'package:picapool/utils/auth_utils.dart';
import 'package:picapool/utils/constants.dart';
import 'package:picapool/utils/http_helper.dart';

class ProductsServices {
  static Future<CreateProductResponse> createProduct(
    CreateProductPayload createProductPayload, String accessToken
  ) async {
    try {
      final Dio dio = await getDio();
      final Response<dynamic> response = await dio.post(
        Constants.apiUrl + Constants.createProductEndpoint,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        }),
        data: jsonEncode(createProductPayload),
        queryParameters: <String, bool>{'withContent': true},
      );

      // Debug log
      print('Create Product Response: ${response.data}');

      if (response.statusCode! < 300 && response.statusCode! >= 200) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        // Check if the response has a data field
        final productData = responseData['data'] as Map<String, dynamic>;
        
        return CreateProductResponse(
          success: true,
          message: 'Product created successfully',
          data: ProductData.fromJson(productData), // Use the data field
        );
      } else {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        return CreateProductResponse(
          success: false,
          message: data['message'] as String? ?? 'Failed to create product',
        );
      }
    } on DioException catch (e) {
      print('Dio Error in createProduct: ${e.response?.data}');
      return CreateProductResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Connection error',
      );
    }
  }
  
  static Future<GetSingleProductResponse> getProductDetails(
    String productId, String accessToken
  ) async {
    try {
      final Dio dio = await getDio();
      final Response<dynamic> response = await dio.get(
        "${Constants.apiUrl}${Constants.getProductEndoint}$productId",
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken'
        }),
        queryParameters: <String, bool>{'withContent': true},
      );

      if (response.statusCode! < 300 && response.statusCode! >= 200) {
        // Debug log to check response
        print('Response data: ${response.data}');
        
        // Check if response.data contains a 'data' field
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        final productData = responseData['data'] as Map<String, dynamic>;
        
        final GetSingleProductResponse getResult = GetSingleProductResponse(
          success: true,
          message: response.statusMessage ?? 'Success',
          data: ProductData.fromJson(productData), // Use the data field
        );
        return getResult;
      } else {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final String errMessage = data['message'] as String? ?? 'Connection error';
        return GetSingleProductResponse(
          success: false,
          message: errMessage,
        );
      }
    } on DioException catch (e) {
      print('Dio Error: ${e.response?.data}'); // Debug log
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return GetSingleProductResponse(
          success: false,
          message: 'Connection Error',
        );
      } else {
        final Map<String, dynamic> data = e.response?.data as Map<String, dynamic>;
        final String errMessage = data['message'] as String? ?? 'Connection error';
        return GetSingleProductResponse(
          success: false,
          message: errMessage,
        );
      }
    }
  }

  static Future<UpdateProductResponse> updateProduct(
    String productId,
    UpdateProductPayload createProductPayload,
    String accessToken
  ) async {
    try {
      await getAccessToken();
      final Dio dio = await getDio();
      final Response<dynamic> response = await dio.get(
        "${Constants.apiUrl}${Constants.createProductEndpoint}/{productId}",
        queryParameters: <String, bool>{'withContent': true},
        options: Options(
          headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        )
      );
      if (response.statusCode! < 300 && response.statusCode! >= 200) {
        final UpdateProductResponse searchResult = UpdateProductResponse(
          success: true,
          message: '${response.statusMessage}',
          data: ProductData.fromJson(response.data as Map<String, dynamic>),
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

  static Future<List<ProductData>> getAllProducts(
    String accessToken
  ) async {
    List<ProductData> productsList; 
    try {
      final Dio dio = await getDio();
      final Response<dynamic> response = await dio.get(
        Constants.apiUrl + Constants.getAllProductsEndpoint,
        options: Options(
          headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        ) 
      );
      if (response.statusCode! < 300 && response.statusCode! >= 200) {
        final responseData = response.data as Map<String, dynamic>;
        final productList = responseData['data'] as List<dynamic>;
        return productList.map((product) => ProductData.fromJson(product)).toList();

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

  static Future<SearchOffersResponse> searchOffers(
    SearchOfferPayload searchOfferPayload, 
    String accessToken
  ) async {
    try {
      final Dio dio = await getDio();
      final Response<dynamic> response = await dio.post(
        Constants.apiUrl + Constants.searchOfferProductEndpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken'
          },
        ),
        data: jsonEncode(searchOfferPayload),
      );

      if (response.statusCode! < 300 && response.statusCode! >= 200) {
        return SearchOffersResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final String errMessage = data['message'] as String? ?? 'Connection error';
        return SearchOffersResponse(
          success: false,
          message: errMessage,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return SearchOffersResponse(
          success: false,
          message: 'Connection Error',
        );
      } else {
        final Map<String, dynamic> data = e.response?.data as Map<String, dynamic>;
        final String errMessage = data['message'] as String? ?? 'Connection error';
        return SearchOffersResponse(
          success: false,
          message: errMessage,
        );
      }
    }
  }

  static Future<CreateOfferResponse> createOffer(
    CreateOfferPayload createOfferPayload, 
    String accessToken
  ) async {
    try {
      final Dio dio = await getDio();
      final Response<dynamic> response = await dio.post(
        Constants.apiUrl + Constants.createOfferProductEndpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken'
          },
        ),
        data: jsonEncode(createOfferPayload),
      );

      if (response.statusCode! < 300 && response.statusCode! >= 200) {
        return CreateOfferResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final String errMessage = data['message'] as String? ?? 'Connection error';
        return CreateOfferResponse(
          success: false,
          message: errMessage,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return CreateOfferResponse(
          success: false,
          message: 'Connection Error',
        );
      } else {
        final Map<String, dynamic> data = e.response?.data as Map<String, dynamic>;
        final String errMessage = data['message'] as String? ?? 'Connection error';
        return CreateOfferResponse(
          success: false,
          message: errMessage,
        );
      }
    }
  }

  static Future<(CreateProductResponse, CreateOfferResponse?)> createProductWithOffer(
    CreateProductPayload createProductPayload,
    Loc location,
    int radius,
    String accessToken,
  ) async {
    try {
      // First create the product
      final CreateProductResponse productResponse = await createProduct(
        createProductPayload, 
        accessToken
      );

      // If product creation was successful, create the offer
      if (productResponse.success == true && productResponse.data != null && productResponse.data?.id != null ) {
        final CreateOfferPayload offerPayload = CreateOfferPayload(
          name: productResponse.data!.name,
          images: productResponse.data!.images,
          desc: productResponse.data!.description,
          expiryAt: DateTime.now().add(const Duration(days: 30)), // Set default expiry
          productIds: [productResponse.data!.id!],
          loc: location,
          dist: radius,
        );

        final CreateOfferResponse offerResponse = await createOffer(
          offerPayload, 
          accessToken
        );

        return (productResponse, offerResponse);
      }

      // If product creation failed, return only product response
      return (productResponse, null);
    } catch (e) {
      print('Error in createProductWithOffer: $e');
      return (
        CreateProductResponse(
          success: false,
          message: 'Failed to complete the operation: $e',
        ),
        null
      );
    }
  }
}
