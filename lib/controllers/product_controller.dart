import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/user/user_controller.dart';
import 'package:picapool/models/offers/location_entity.dart';
import 'package:picapool/models/offers/search_offer_payload.dart';
import 'package:picapool/models/offers/search_offer_response.dart';
import 'package:picapool/services/products/payloads/create_product_payload.dart';
import 'package:picapool/services/products/payloads/update_product_payload.dart';
import 'package:picapool/services/products/responses/create_product_response.dart';
import 'package:picapool/services/products/entities/product_entity.dart';
import 'package:picapool/services/products/products_service.dart';
import 'package:picapool/services/products/responses/get_single_product_response.dart';
import 'package:picapool/services/products/responses/update_product_response.dart';
import 'package:picapool/models/offers/create_offer_payload.dart';
import 'package:picapool/models/offers/create_offer_response.dart';

enum ProductsState { productsLoading, productsLoaded, productsCantLoad }
enum CreateProductState { creating, created, error }
enum IndividualProductsState { productsLoading, productsLoaded, productsCantLoad }
enum SearchOffersState { initial, searching, searched, error }
enum CreateOfferState { initial, creating, created, error }

class ProductController extends GetxController {
  final UserController _userController = Get.find<UserController>();
  final AuthController authController = Get.find<AuthController>();
  String? get accessToken => authController.auth.value?.accessToken;

  ProductsState productsState = ProductsState.productsLoaded;
  CreateProductState createProductState = CreateProductState.created;
  IndividualProductsState individualProductsState = IndividualProductsState.productsLoading;
  SearchOffersState searchOffersState = SearchOffersState.initial;
  SearchOffersResponse? searchOffersResponse;
  List<SearchedProduct>? searchedProductsList;
  
  List<ProductData> _allProducts = []; // Store original list
  List<ProductData> productsList = [];
  late ProductData productDetails;
  List<String> imageURLs = <String>[];
  int currentIndex = 1;
  CreateOfferState createOfferState = CreateOfferState.initial;
  CreateOfferResponse? createOfferResponse;

  /// Get all products
  Future<void> getAllProducts() async {
    productsState = ProductsState.productsLoading;
    update();

    try {
      final List<ProductData> response = await ProductsServices.getAllProducts(accessToken ?? "");
      if (response.isNotEmpty || response != []) {
        _allProducts = response; // Store original list
        productsList = response; // Display list
        productsState = ProductsState.productsLoaded;
      } else {
        productsState = ProductsState.productsCantLoad;
      }
    } catch (e) {
      productsState = ProductsState.productsCantLoad;
      print('Error getting products list: $e');
    }
    update();
  }

  /// Filter products based on search query
  void filterProducts(String query) {
    if (query.isEmpty) {
      productsList = _allProducts; // Restore original list
    } else {
      productsList = _allProducts.where((product) => 
        product.name?.toLowerCase().contains(query) ?? false
      ).toList();
    }
    update();
  }

  /// Create a new product
  Future<bool> createProduct(CreateProductPayload createProductPayload) async {
    createProductState = CreateProductState.creating;
    update();

    try {
      final CreateProductResponse response = await ProductsServices.createProduct(createProductPayload, accessToken ?? "");
      if (response.success ?? false) {
        createProductState = CreateProductState.created;
        await getAllProducts();  // Refresh the products list after creation
        return true;
      } else {
        createProductState = CreateProductState.error;
        print(response);
        // Get.snackbar(
        //   'Error',
        //   response.message ?? 'Failed to create product',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.red,
        //   colorText: Colors.white,
        // );
        return false;
      }
    } catch (e) {
      createProductState = CreateProductState.error;
      Get.snackbar(
        'Error',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      update();
    }
  }

  /// Update an existing product
  Future<void> updateProduct(String productId, UpdateProductPayload updateProductPayload) async {
    individualProductsState = IndividualProductsState.productsLoading;
    update();

    try {
      final UpdateProductResponse response = await ProductsServices.updateProduct(productId, updateProductPayload, accessToken ?? "");
      if (response.success ?? false) {
        individualProductsState = IndividualProductsState.productsLoaded;
        await getAllProducts();  // Refresh the products list after updating
      } else {
        individualProductsState = IndividualProductsState.productsCantLoad;
      }
    } catch (e) {
      individualProductsState = IndividualProductsState.productsCantLoad;
      print('Error updating product: $e');
    }
    update();
  }

  /// Get a single product details by ID
  Future<void> getProductDetails(String productId) async {
    individualProductsState = IndividualProductsState.productsLoading;
    update();
    
    try {
      final GetSingleProductResponse response = 
          await ProductsServices.getProductDetails(productId, accessToken ?? "s");
      
      // Debug log
      print('Controller response: ${response.data?.toJson()}');
      
      if (response.success == true && response.data != null) {
        productDetails = response.data!;
        individualProductsState = IndividualProductsState.productsLoaded;
      } else {
        individualProductsState = IndividualProductsState.productsCantLoad;
        print('Failed to load product: ${response.message}');
      }
    } catch (e) {
      individualProductsState = IndividualProductsState.productsCantLoad;
      print('Error getting product details: $e');
    }
    update();
  }

  /// Search offers
  Future<void> searchOffers(SearchOfferPayload searchOfferPayload) async {
    try {
      searchOffersState = SearchOffersState.searching;
      update();

      final response = await ProductsServices.searchOffers(
        searchOfferPayload, 
        accessToken ?? ""
      );

      if (response.success == true) {
        searchOffersResponse = response;
        if(response.data != null){
          searchedProductsList = response.data!.first.products ;
        }
        searchOffersState = SearchOffersState.searched;
      } else {
        searchOffersState = SearchOffersState.error;
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to search offers',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      searchOffersState = SearchOffersState.error;
      debugPrint('Error searching offers: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred while searching offers',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      update();
    }
  }

  /// Create a new offer
  Future<bool> createOffer(CreateOfferPayload createOfferPayload) async {
    try {
      createOfferState = CreateOfferState.creating;
      update();

      final response = await ProductsServices.createOffer(
        createOfferPayload, 
        accessToken ?? ""
      );

      if (response.success == true) {
        createOfferResponse = response;
        createOfferState = CreateOfferState.created;
        // Optionally refresh offers list if needed
        await searchOffers(SearchOfferPayload(
          chats: true,
          loc: createOfferPayload.loc,
          products: true,
          radius: createOfferPayload.dist,
        ));
        return true;
      } else {
        createOfferState = CreateOfferState.error;
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to create offer',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      createOfferState = CreateOfferState.error;
      debugPrint('Error creating offer: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred while creating offer',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      update();
    }
  }

  /// Create a product and immediately create an offer for it
  Future<bool> createProductWithOffer(
    CreateProductPayload createProductPayload,
    Loc location,
    int radius,
  ) async {
    try {
      // Set initial states
      createProductState = CreateProductState.creating;
      createOfferState = CreateOfferState.initial;
      update();

      // First create the product
      final CreateProductResponse productResponse = await ProductsServices.createProduct(
        createProductPayload,
        accessToken ?? ""
      );

      // Debug log
      debugPrint('Product Response: ${productResponse.toJson()}');

      // Validate product creation response
      if (!productResponse.success! || productResponse.data == null) {
        createProductState = CreateProductState.error;
        Get.snackbar(
          'Error',
          productResponse.message ?? 'Failed to create product',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Product created successfully, now create offer
      createProductState = CreateProductState.created;
      createOfferState = CreateOfferState.creating;
      update();

      // Debug log
      debugPrint('Creating offer with product ID: ${productResponse.data!.id}');

      // Create offer payload
      final CreateOfferPayload offerPayload = CreateOfferPayload(
        name: productResponse.data!.name ?? createProductPayload.name,
        images: productResponse.data!.images ?? createProductPayload.images,
        desc: productResponse.data!.description ?? createProductPayload.description,
        expiryAt: DateTime.now().add(const Duration(days: 30)).toUtc(),
        productIds: [productResponse.data!.id!],
        loc: location,
        userId: _userController.user.value!.id,
        dist: radius,
        tagIds: [8]
      );

      // Create the offer
      final CreateOfferResponse offerResponse = await ProductsServices.createOffer(
        offerPayload,
        accessToken ?? ""
      );

      // Debug log
      debugPrint('Offer Response: ${offerResponse.toJson()}');

      // Validate offer creation
      if (!offerResponse.success!) {
        createOfferState = CreateOfferState.error;
        Get.snackbar(
          'Error',
          offerResponse.message ?? 'Failed to create offer',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Both operations successful
      createOfferState = CreateOfferState.created;
      createOfferResponse = offerResponse;
      
      // Refresh data
      await getAllProducts();
      await searchOffers(SearchOfferPayload(
        chats: true,
        loc: location,
        products: true,
        radius: radius,
      ));

      Get.snackbar(
        'Success',
        'Product and offer created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      debugPrint('Error in createProductWithOffer: $e');
      createProductState = CreateProductState.error;
      createOfferState = CreateOfferState.error;
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      update();
    }
  }
}
