import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/services/products/payloads/create_product_payload.dart';
import 'package:picapool/services/products/payloads/update_product_payload.dart';
import 'package:picapool/services/products/responses/create_product_response.dart';
import 'package:picapool/services/products/entities/product_entity.dart';
import 'package:picapool/services/products/products_service.dart';
import 'package:picapool/services/products/responses/get_single_product_response.dart';
import 'package:picapool/services/products/responses/update_product_response.dart';

enum ProductsState { productsLoading, productsLoaded, productsCantLoad }
enum CreateProductState { creating, created, error }
enum IndividualProductsState { productsLoading, productsLoaded, productsCantLoad }

class ProductController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  String? get accessToken => authController.auth.value?.accessToken;

  ProductsState productsState = ProductsState.productsLoaded;
  CreateProductState createProductState = CreateProductState.created;
  IndividualProductsState individualProductsState = IndividualProductsState.productsLoading;
  
  List<ProductData> _allProducts = []; // Store original list
  List<ProductData> productsList = [];
  late ProductData productDetails;
  List<String> imageURLs = <String>[];
  int currentIndex = 1;

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
}
