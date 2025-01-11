import 'package:dio/dio.dart';
import 'package:picapool/services/categories/entities/category_entity.dart';
import 'package:picapool/utils/auth_utils.dart';
import 'package:picapool/utils/constants.dart';
import 'package:picapool/utils/http_helper.dart';

class CategoryServices {

  static Future<List<Category>> getAllCategories() async {
    List<Category> categoriesList;
    try {
      await getAccessToken();
      final Dio dio = await getDio();
      final Response<dynamic> response = await dio.get(
        Constants.apiUrl + Constants.getAllCategoriesEndpoint,
      );
      if (response.statusCode! < 300 && response.statusCode! >= 200) {
        final responseData = response.data as Map<String, dynamic>;
        final categoriesList = responseData['data'] as List<dynamic>;
        return categoriesList.map((category) => Category.fromJson(category)).toList();

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
