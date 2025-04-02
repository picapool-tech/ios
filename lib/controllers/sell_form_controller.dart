import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:picapool/controllers/product_controller.dart';
import 'package:picapool/features/tokens/token_service.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/models/offers/location_entity.dart';
import 'package:picapool/models/response_model.dart';
import 'package:picapool/services/products/entities/product_attributes_entity.dart';
import 'package:picapool/services/products/payloads/create_product_payload.dart';
import 'package:picapool/widgets/sell/build_field.dart';

class FormController extends GetxController {
  static ProductController get productController =>
      Get.find<ProductController>();
  Position? currentPosition;
  final UserController _userController = Get.find<UserController>();
  // First Form Data
  var formOneData = <String, dynamic>{}.obs;

  // Second Form Data
  var formTwoData = <String, dynamic>{}.obs;

  final AuthTokenService _storageController = Get.find<AuthTokenService>();

  // Function to get the combined data
  CreateProductPayload get combinedFormData {
    return CreateProductPayload(
      name: formOneData['name'] ?? '',
      description: formOneData['description'] ?? '',
      email: formTwoData['email'] ?? '',
      images: List<String>.from(formOneData['images'] ?? []),
      mrp: formOneData['price'].toInt(),
      // offerIds: [formOneData['category'] ?? 1],
      // Empty for now since backend has restarted and is not accepting any value
      offerIds: [],
      offerPrice: formTwoData['sellingPrice'].toInt(),
      phone: formTwoData['phone'] ?? '',
      userId: _userController.user!.id,
      attributes: Attributes(
          accessories: formOneData['accessories'],
          author: formOneData['author'],
          brand: formOneData['brand'],
          breadth: formOneData['breadth'],
          condition: formOneData['condition'],
          deviceType: formOneData['deviceType'],
          fabric: formOneData['fabric'],
          furnitureType: formOneData['type'], // Fixed field name
          genre: formOneData['genre'],
          kmsDriven: formOneData['kmsDriven'],
          height: formOneData['height'],
          length: formOneData['length'],
          material: formOneData['material'],
          modelName: formOneData['modelName'],
          reasonForSell:
              formTwoData['reasonForSell'], // Moved from form one to form two
          size: formOneData['size'],
          specifications: formOneData['specifications'],
          style: formOneData['style'],
          title: formOneData['name'], // Using name as title
          type: formOneData['type'],
          vehicleType: formOneData['type'], // Using type for vehicle type
          year: formOneData['year']),
    );
  }

  // Future<void> _getCurrentLocation() async {
  //   try {
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       return Future.error('Location services are disabled.');
  //     }

  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.denied) {
  //         return Future.error('Location permissions are denied');
  //       }
  //     }

  //     currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //     update();
  //   } catch (e) {
  //     debugPrint('Error getting location: $e');
  //   }
  // }

  Future<bool> instantiateCreateProduct(
      BuildContext context, Loc currentLocation, int radius) async {
    // _getCurrentLocation;
    try {
      // if (!validateForms()) {
      //   Get.snackbar(
      //     'Error',
      //     'Please fill all required fields',
      //     snackPosition: SnackPosition.BOTTOM,
      //     backgroundColor: Colors.red,
      //     colorText: Colors.white,
      //   );
      //   return false;
      // }

      return await productController.createProductWithOffer(
          combinedFormData, currentLocation, radius);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process request: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Function to save first form data
  void saveFormOneData(Map<String, dynamic> data) {
    formOneData.assignAll(data);
  }

  // Function to save second form data
  void saveFormTwoData(Map<String, dynamic> data) {
    formTwoData.assignAll(data);
  }

  // Add validation method
  // bool validateForms() {
  //   // Basic required fields validation
  //   if (formOneData['name']?.isEmpty ?? true) return false;
  //   if (formOneData['price'] == null || formOneData['price'] <= 0) return false;
  //   if (formOneData['category'] == null) return false;
  //   if (formTwoData['email']?.isEmpty ?? true) return false;
  //   if (formTwoData['phone']?.isEmpty ?? true) return false;

  //   return true;
  // }

  Future<String?> uploadProductImage(File imageFile) async {
    try {
      var accessToken = await _storageController.getAccessToken();
      // final auth = authController.auth.value;
      if (accessToken == null) {
        showSnackBar(content: "Authentication error", context: Get.context!);
        return null;
      }

      Uri endpoint = Uri.parse('https://api.picapool.com/v2/s3/upload');
      String fileName = path.basename(imageFile.path);

      var request = http.MultipartRequest('POST', endpoint);

      // Set the content type based on file extension
      MediaType? contentType;
      String ext = path.extension(imageFile.path).toLowerCase();
      if (ext == '.jpg' || ext == '.jpeg') {
        contentType = MediaType('image', 'jpeg');
      } else if (ext == '.png') {
        contentType = MediaType('image', 'png');
      }

      // Add the file to the request
      request.fields['key'] = 'images/products/$fileName';
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: contentType,
        filename: 'product-${DateTime.now().toIso8601String()}$ext',
      ));

      // Add headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $accessToken',
      });

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = await response.stream.bytesToString();
        var responseModel = ResponseModel.fromJson(jsonDecode(responseData));
        if (responseModel.success) {
          return responseModel.data['url'];
        }
      }
      // using getAccessToken method from auth controller
      // automatically handles the expiration and refreshing of the token
      // else if (response.statusCode == 401) {
      //   bool tokenUpdated = await authController.getAccessToken();
      //   if (tokenUpdated) {
      //     return uploadProductImage(imageFile);
      //   }
      // }

      showSnackBar(content: "Failed to upload image", context: Get.context!);
      return null;
    } catch (e) {
      print("Error uploading image: $e");
      showSnackBar(content: "Error uploading image", context: Get.context!);
      return null;
    }
  }

  // Method to handle multiple image uploads
  Future<List<String>> uploadProductImages(List<File> images) async {
    List<String> uploadedUrls = [];

    for (var image in images) {
      final url = await uploadProductImage(image);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    // Update the form data with new image URLs
    var currentData = formOneData.value;
    currentData['images'] = uploadedUrls;
    formOneData.value = currentData;
    update();

    return uploadedUrls;
  }
}
