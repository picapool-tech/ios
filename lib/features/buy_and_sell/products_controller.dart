import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:picapool/common/widgets/dialog_widgets.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/core/reactive_loading.dart';
import 'package:picapool/features/assets/assets_controller.dart';
import 'package:picapool/features/buy_and_sell/product_api.dart';
import 'package:picapool/features/buy_and_sell/values/enums.dart';
import 'package:picapool/features/buy_and_sell/values/model.dart';
import 'package:picapool/features/location/location_controller.dart';
import 'package:picapool/features/offers/offers_controller.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/features/tags/tag_controller.dart';
import 'package:picapool/features/vicinity/vicinity_controller.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/offer_search_request_model.dart';
import 'package:picapool/models/product_model.dart';
import 'package:picapool/models/vicinity_offer_model.dart';
import 'package:picapool/screens/buy_and_sell/values/enums.dart';

class ProductsController extends GetxController
    with ReactiveLoading<ProductLoadingEnums> {
  final ProductApi _productApi = ProductApi();
  final VicinityController _offersController = Get.find<VicinityController>();
  final OffersController _opOffersController = Get.find<OffersController>();
  final LocationController _locationController = Get.find<LocationController>();
  final AssetsController _assetsController = Get.find<AssetsController>();
  final StorageController _storageController = Get.find<StorageController>();
  final TagController _tagController = Get.find<TagController>();

  final RxList<Product> _allProducts = <Product>[].obs;
  final RxList<Offer> _originSearchedProducts = <Offer>[].obs;
  final RxList<Offer> _searchedProducts = <Offer>[].obs;
  final RxList<Offer> _sortingSearchedProducts = <Offer>[].obs;

  final Rx<SortOption?> _currentSortOption = Rx<SortOption?>(null);
  final RxString _lastSearchQuery = ''.obs;

  List<Product> get allProducts => _allProducts;
  SortOption? get currentSortOption => _currentSortOption.value;

  String get lastSearchQuery => _lastSearchQuery.value;
  List<Offer> get searchedProducts => _sortingSearchedProducts;

  Future<Product?> createProduct(
    ProductRequestModel productRequestModel,
  ) async {
    debugPrint("[DEBUG] Starting createProduct method");
    startLoading(ProductLoadingEnums.createProduct);
    try {
      // 1. Validate location availability
      debugPrint("[DEBUG] Validating location");
      if (!await _validateLocation()) {
        debugPrint("[DEBUG] Location validation failed");
        stopLoading(ProductLoadingEnums.createProduct);
        return null;
      }

      // 2. Upload images with improved batch uploader
      debugPrint(
          "[DEBUG] Uploading ${productRequestModel.imagesFile.length} images");
      final imageUrls =
          await _uploadProductImages(productRequestModel.imagesFile);
      debugPrint("[DEBUG] Image upload complete. Got ${imageUrls.length} URLs");
      if (imageUrls.isEmpty) {
        debugPrint("[DEBUG] Image upload failed - no URLs returned");
        showPicaAlertDialog(
          message: "Failed to upload images. Please try again.",
          confirmText: "OK",
          onConfirm: () => Get.back(),
        );
        stopLoading(ProductLoadingEnums.createProduct);
        return null;
      }

      // 3. Create vicinity offer
      debugPrint("[DEBUG] Creating vicinity offer");
      final offerResult =
          await _createVicinityOffer(productRequestModel, imageUrls);
      if (offerResult == null) {
        debugPrint("[DEBUG] Vicinity offer creation failed");
        stopLoading(ProductLoadingEnums.createProduct);
        return null;
      }
      debugPrint("[DEBUG] Vicinity offer created with ID: ${offerResult.id}");

      // 4. Update product model with image URLs and offer ID
      productRequestModel.images.addAll(imageUrls);
      productRequestModel.offerIds.add(offerResult.id);

      // 5. Create the product
      debugPrint("[DEBUG] Creating product in API");
      var result = await _productApi.createProduct(productRequestModel);
      return result.fold(
        (error) {
          debugPrint("[DEBUG] Error creating product: ${error.message}");
          _opOffersController.deleteOffer(offerId: offerResult.id);
          showPicaAlertDialog(
            message: "Failed to create your listing: ${error.message}",
            confirmText: "OK",
            onConfirm: () => Get.back(),
          );
          return null;
        },
        (product) {
          debugPrint(
              "[DEBUG] Product created successfully with ID: ${product.id}");
          searchProducts();
          return product;
        },
      );
    } catch (e) {
      debugPrint("[DEBUG] Exception in createProduct: $e");
      debugPrint("[DEBUG] Stack trace: ${StackTrace.current}");
      showPicaAlertDialog(
        message: "An unexpected error occurred. Please try again.",
        confirmText: "OK",
        onConfirm: () => Get.back(),
      );
      return null;
    } finally {
      debugPrint("[DEBUG] Completing createProduct method");
      stopLoading(ProductLoadingEnums.createProduct);
      update();
    }
  }

  FutureVoid getAllProducts() async {
    debugPrint("[DEBUG] Starting getAllProducts method");
    startLoading(ProductLoadingEnums.getAllProducts);
    update();

    try {
      debugPrint("[DEBUG] Calling API to fetch all products");
      var result = await _productApi.getAllProducts();
      result.fold(
        (error) {
          debugPrint("[DEBUG] Error fetching products: ${error.message}");
          if (error.showError) {
            showErrorDialog(error.message);
          }
        },
        (data) {
          debugPrint("[DEBUG] Successfully fetched ${data.length} products");
          _allProducts.assignAll(data);
        },
      );
    } catch (e) {
      debugPrint("[DEBUG] Exception in getAllProducts: $e");
      debugPrint("[DEBUG] Stack trace: ${StackTrace.current}");
    } finally {
      debugPrint("[DEBUG] Completing getAllProducts method");
      stopLoading(ProductLoadingEnums.getAllProducts);
      update();
    }
  }

  @override
  void onInit() {
    super.onInit();
    initializeLoadingStates(ProductLoadingEnums.values);
  }

  void removeSorting() {
    _currentSortOption.value = null;
    _sortingSearchedProducts.assignAll(_searchedProducts);
    update();
  }

  // Reset sorting
  void resetAll() {
    _currentSortOption.value = null;
    _lastSearchQuery.value = '';
    _searchedProducts.assignAll(_originSearchedProducts);
    _sortingSearchedProducts.assignAll(_searchedProducts);
    update();
  }

  Future<void> searchProducts() async {
    debugPrint("[DEBUG] Starting searchProducts method");
    startLoading(ProductLoadingEnums.searchProducts);
    update();

    try {
      debugPrint("[DEBUG] Checking location status");
      if (!await _locationController.isLocationEnabled()) {
        debugPrint("[DEBUG] Location not enabled, aborting search");
        stopLoading(ProductLoadingEnums.searchProducts);
        update();
        return;
      }

      debugPrint("[DEBUG] Waiting for location data");
      int attempts = 0;
      // Wait until location is not null
      while (_locationController.state.value.location == null) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
        if (attempts % 4 == 0) {
          // Log every 2 seconds
          debugPrint(
              "[DEBUG] Still waiting for location data... (${attempts / 2}s)");
        }
      }

      var location = _locationController.state.value;
      debugPrint(
          "[DEBUG] Location obtained: ${location.location!.latitude}, ${location.location!.longitude}");

      var tag = _tagController.getTagsByTagName("Buy");
      debugPrint("[DEBUG] Buy tag: ${tag?.id ?? 'not found'}");

      debugPrint("[DEBUG] Sending search request");
      var result = await _productApi.searchProducts(
        OfferSearchRequestModel(
          loc: VicinityLocation(
            lat: location.location!.latitude,
            long: location.location!.longitude,
          ),
          products: true,
          radius: 5000,
          // chats: true,
          tagIds: tag != null ? [tag.id] : [],
        ),
      );
      result.fold(
        (error) {
          debugPrint("[DEBUG] Error searching products: ${error.message}");
          if (error.showError) {
            showErrorDialog(error.message);
          }
        },
        (data) {
          debugPrint(
              "[DEBUG] Search successful, found ${data.length} products");
          _originSearchedProducts.assignAll(data);

          if (_lastSearchQuery.value.isNotEmpty) {
            searchProductsLocal(_lastSearchQuery.value);
          } else {
            _searchedProducts.assignAll(data);
            _sortingSearchedProducts.assignAll(data);

            if (_currentSortOption.value != null) {
              _applySortOption(_currentSortOption.value!);
            }
          }
        },
      );
    } catch (e) {
      debugPrint("[DEBUG] Exception in searchProducts: $e");
      debugPrint("[DEBUG] Stack trace: ${StackTrace.current}");
    } finally {
      debugPrint("[DEBUG] Completing searchProducts method");
      stopLoading(ProductLoadingEnums.searchProducts);
      update();
    }
  }

  void searchProductsLocal(String query) {
    _lastSearchQuery.value = query;

    if (query.trim().isEmpty) {
      _searchedProducts.assignAll(_originSearchedProducts);
    } else {
      final normalizedQuery = query.trim().toLowerCase();

      final filteredProducts = _originSearchedProducts.where((offer) {
        final product = offer.products?.firstOrNull;
        if (product == null) return false;

        final nameMatch = product.name.toLowerCase().contains(normalizedQuery);
        final descMatch =
            product.description.toLowerCase().contains(normalizedQuery);
        final priceMatch =
            product.offerPrice?.toString().contains(normalizedQuery) ?? false;

        return nameMatch || descMatch || priceMatch;
      }).toList();

      _searchedProducts.assignAll(filteredProducts);
    }

    if (_currentSortOption.value != null) {
      _applySortOption(_currentSortOption.value!);
    } else {
      _sortingSearchedProducts.assignAll(_searchedProducts);
    }
    update();
  }

  void setSortOption(SortOption option) {
    _currentSortOption.value = option;
    _applySortOption(option);
  }

  void showErrorDialog(String message) {
    debugPrint("[DEBUG] Showing error dialog: $message");
    showPicaAlertDialog(
      message: message,
      confirmText: "Ok",
      onConfirm: () {
        Get.back();
      },
    );
  }

  void sortProductsByDate({bool ascending = true}) {
    final sortedProducts = _searchedProducts.toList();

    sortedProducts.sort((a, b) {
      final DateTime dateA = a.createdAt;
      final DateTime dateB = b.createdAt;
      return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });

    _sortingSearchedProducts.value = sortedProducts;
    update();
  }

  // Sort products by price
  void sortProductsByPrice({bool ascending = true}) {
    final sortedProducts = _searchedProducts.toList();

    sortedProducts.sort((a, b) {
      final double priceA =
          a.products?.firstOrNull?.offerPrice?.toDouble() ?? 0.0;
      final double priceB =
          b.products?.firstOrNull?.offerPrice?.toDouble() ?? 0.0;
      return ascending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });

    _sortingSearchedProducts.value = sortedProducts;
    update();
  }

  Future<Product?> updateProduct({required Product updatedProduct}) async {
    startLoading(ProductLoadingEnums.updateProduct);
    update();
    try {
      var response =
          await _productApi.updateProduct(updatedProduct: updatedProduct);
      return response.fold(
        (error) {
          debugPrint(
              "Some error occured in update product method controller : ${error.message}");
          return null;
        },
        (product) {
          return product;
        },
      );
    } catch (e) {
      debugPrint("This is an error in the product update method");
      return null;
    } finally {
      stopLoading(ProductLoadingEnums.updateProduct);
      update();
    }
  }

  void _applySortOption(SortOption option) {
    switch (option) {
      case SortOption.newestFirst:
        sortProductsByDate(ascending: false);
        break;
      case SortOption.oldestFirst:
        sortProductsByDate(ascending: true);
        break;
      case SortOption.priceHighToLow:
        sortProductsByPrice(ascending: false);
        break;
      case SortOption.priceLowToHigh:
        sortProductsByPrice(ascending: true);
        break;
    }
  }

  Future<Offer?> _createVicinityOffer(
      ProductRequestModel model, List<String> imageUrls) async {
    debugPrint("[DEBUG] Starting _createVicinityOffer");
    var tags = _tagController.tags;
    var buyTagId = tags
        .where((tag) => tag.tag.toLowerCase().contains("buy"))
        .firstOrNull
        ?.id;
    debugPrint("[DEBUG] Buy tag ID: $buyTagId");

    var location = _locationController.state.value;
    debugPrint(
        "[DEBUG] Using location: ${location.location!.latitude}, ${location.location!.longitude}");

    final result = await _offersController.createVicinity(
      offer: VicinityOffer(
        name: model.name,
        images: imageUrls,
        desc: model.description,
        expiryAt: DateTime.now().add(const Duration(days: 366)),
        userId: model.userId,
        location: VicinityLocation(
          lat: location.location!.latitude,
          long: location.location!.longitude,
        ),
        distance: 25000,
      ),
      pickedFile: null,
      uname: _storageController.user.value!.name!,
      offername: model.name,
      tagId: buyTagId,
    );

    debugPrint(
        "[DEBUG] Vicinity offer creation result: ${result?.id ?? 'Failed'}");
    return result;
  }

  // Improved image upload with stream-based progress and better error handling
  Future<List<String>> _uploadProductImages(List<XFile> images) async {
    debugPrint(
        "[DEBUG] Starting _uploadProductImages for ${images.length} images");
    if (images.isEmpty) {
      debugPrint("[DEBUG] No images to upload");
      return [];
    }

    // Adaptive concurrency based on image count
    final int concurrency = math.min(3, math.max(1, images.length ~/ 2));
    debugPrint("[DEBUG] Using concurrency: $concurrency");

    final List<String> uploadedUrls = [];
    final stopwatch = Stopwatch()..start();

    // Use Streams for batching (instead of nested loops)
    try {
      debugPrint("[DEBUG] Beginning batch upload");
      final results = await Stream.fromIterable(images)
          .asyncMap((image) => _uploadSingleImage(image))
          .where((url) => url != null) // Filter out failed uploads
          .cast<String>() // Cast to non-nullable String
          .toList();

      stopwatch.stop();
      debugPrint(
          "[DEBUG] Upload complete. Uploaded ${results.length}/${images.length} images in ${stopwatch.elapsedMilliseconds}ms");
      return results;
    } catch (e) {
      stopwatch.stop();
      debugPrint("[DEBUG] Error in batch image upload: $e");
      debugPrint("[DEBUG] Stack trace: ${StackTrace.current}");
      debugPrint(
          "[DEBUG] Uploaded ${uploadedUrls.length}/${images.length} before error, took ${stopwatch.elapsedMilliseconds}ms");
      return uploadedUrls; // Return any successfully uploaded images
    }
  }

  Future<String?> _uploadSingleImage(XFile image) async {
    final stopwatch = Stopwatch()..start();
    final fileSize = await image.length();
    debugPrint(
        "[DEBUG] Uploading image: ${image.name} (${(fileSize / 1024).toStringAsFixed(1)}KB)");

    try {
      final fileName =
          "${_storageController.user.value!.id}_${DateTime.now().millisecondsSinceEpoch}.${path.extension(image.path).replaceAll('.', '')}";

      final url = await _assetsController.uploadImage(
        image,
        fileName,
      );

      stopwatch.stop();
      debugPrint(
          "[DEBUG] Uploaded ${image.name} in ${stopwatch.elapsedMilliseconds}ms");
      return url;
    } catch (e) {
      stopwatch.stop();
      debugPrint("[DEBUG] Error uploading image ${image.name}: $e");
      debugPrint("[DEBUG] Stack trace: ${StackTrace.current}");
      return null;
    }
  }

  // Helper methods for cleaner organization
  Future<bool> _validateLocation() async {
    debugPrint("[DEBUG] Starting location validation");
    if (!await _locationController.isLocationEnabled()) {
      debugPrint("[DEBUG] Location services not enabled");
      showPicaAlertDialog(
        message: "Location access is required to create a listing.",
        confirmText: "OK",
        onConfirm: () => Get.back(),
      );
      return false;
    }

    // Wait for location with timeout
    int attempts = 0;
    debugPrint("[DEBUG] Waiting for location data");
    while (_locationController.state.value.location == null) {
      if (attempts > 10) {
        // 5 second timeout
        debugPrint("[DEBUG] Location timeout after ${attempts / 2}s");
        showPicaAlertDialog(
          message:
              "Unable to determine your location. Please check your settings.",
          confirmText: "OK",
          onConfirm: () => Get.back(),
        );
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
      if (attempts % 4 == 0) {
        debugPrint("[DEBUG] Still waiting for location... (${attempts / 2}s)");
      }
    }

    debugPrint("[DEBUG] Location validated successfully");
    return true;
  }
}
