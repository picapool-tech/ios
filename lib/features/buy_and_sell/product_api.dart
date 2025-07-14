import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:picapool/core/api_impl.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/features/buy_and_sell/values/product_request_model.dart';
import 'package:picapool/features/offers/offers_api.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/offer_search_request_model.dart';
import 'package:picapool/models/product_model.dart';
import 'package:picapool/models/response_model.dart';

class ProductApi with PicapoolApiClass {
  FutureEither<Product> createProduct(
      ProductRequestModel productRequestModel) async {
    try {
      var response = await api.makeRequest(
        enpoint: APIEndpoints.createProduct,
        method: RequestMethod.post,
        body: productRequestModel.toNewJson(),
      );

      return response.fold((error) => left(error), (responseModel) async {
        var product = await responseModel.parseData<Product>(Product.fromJson);
        return right(product);
      });
    } catch (e) {
      debugPrint("Create product error : $e");
      return left(Failure(
        message: "Cannot create product at this time",
        stackTrace: StackTrace.current,
      ));
    }
  }

  FutureEither<List<Product>> getAllProducts() async {
    try {
      var response = await api.makeRequest(
        enpoint: APIEndpoints.getAllProducts,
        method: RequestMethod.getRequest,
      );

      return response.fold(
        (error) => left(error),
        (responseModel) {
          debugPrint("getAllProducts: ${responseModel.data}");
          return right([]);
        },
      );
    } catch (e) {
      debugPrint("Error in getAllProducts$e");
      return left(
        Failure(
          message: "Cannot retrieve offer right now",
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  FutureEither<List<Offer>> searchProducts(
      OfferSearchRequestModel requestModel) async {
    try {
      var response = await OffersApi().searchOffer(requestModel);

      return response.fold(
        (error) => left(error),
        (responseModel) async {
          debugPrint("searchAllProducts: ${responseModel.data}");
          List<Offer> listOfProductsInOffer =
              await responseModel.parseDataList<Offer>(Offer.fromJson);
          return right(listOfProductsInOffer);
        },
      );
    } catch (e) {
      debugPrint("Error in getAllProducts$e");
      return left(
        Failure(
            message: "Cannot retrieve offer right now",
            stackTrace: StackTrace.current),
      );
    }
  }

  FutureEither<Product> updateProduct({
    required Product updatedProduct,
  }) async {
    final result = await api.makeRequest(
      enpoint: APIEndpoints.updateProduct,
      method: RequestMethod.patch,
      body: {
        'id': updatedProduct.id,
        'userId': updatedProduct.userId,
        'attributes': updatedProduct.attributes,
      },
    );

    return result.fold((error) => left(error), (responseModel) async {
      var product = await responseModel.parseData<Product>(Product.fromJson);
      return right(product);
    });
  }
}
