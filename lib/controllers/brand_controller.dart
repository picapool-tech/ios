import 'dart:async';
import 'package:get/get.dart';
import 'package:picapool/models/brands/entities/brand_entity.dart';
import 'package:picapool/services/brands/brands_service.dart';

enum BrandsState { brandsLoading, brandsLoaded, brandsCantLoad }
enum CreateBrandState { creating, created, error }
enum IndividualBrandsState { brandsLoading, brandsLoaded, brandsCantLoad }

class BrandController extends GetxController {
  BrandsState brandsState = BrandsState.brandsLoaded;
  CreateBrandState createBrandState = CreateBrandState.created;
  IndividualBrandsState individualBrandsState = IndividualBrandsState.brandsLoading;
  
  List<Brand> brandsList = <Brand>[];
  List<String> imageURLs = <String>[];
  int currentIndex = 0;

  /// Get all brands
  Future<void> getAllBrands() async {
    brandsState = BrandsState.brandsLoading;
    update();

    try {
      final List<Brand> response = await BrandsService.getAllBrands();
      if (response.isNotEmpty || response != []) {
        brandsList = response;
        // brandsList = response.data ?? [];
        brandsState = BrandsState.brandsLoaded;
      } else {
        brandsState = BrandsState.brandsCantLoad;
      }
    } catch (e) {
      brandsState = BrandsState.brandsCantLoad;
      print('Error getting brands list: $e');
    }
    update();
  }

  /// Create a new brand
  // Future<void> createBrand(Map<String, dynamic> createBrandPayload) async {
  //   createBrandState = CreateBrandState.creating;
  //   update();

  //   final CreateBrandResponse response = await BrandsServices.createBrand(createBrandPayload);
  //   if (response.success ?? false) {
  //     createBrandState = CreateBrandState.created;
  //     await getAllBrands();  // Refresh the brands list after creation
  //   } else {
  //     createBrandState = CreateBrandState.error;
  //   }
  //   update();
  // }
}
