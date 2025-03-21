import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picapool/features/assets/assets_controller.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/features/vicinity/vicinity_api.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/vicinity_offer_model.dart';

class VicinityController extends GetxController {
  final StorageController _storageController = Get.find<StorageController>();
  final UserController _userController = Get.find<UserController>();
  final VicinityApi _vicinityApi = VicinityApi();
  final AssetsController _assetsController = AssetsController();

  var isLoading = false.obs;
  var offers = <Offer>[].obs;

  Future<Offer?> createVicinity({
    required VicinityOffer offer,
    required XFile? pickedFile,
    required String uname,
    required String offername,
    int? tagId,
  }) async {
    isLoading.value = true;
    update();

    String? uploadedImage = '';
    if (pickedFile != null) {
      uploadedImage = await _assetsController.uploadImage(pickedFile,
          '$uname-$offername-${DateTime.now().toIso8601String()}.jpg');

      if (uploadedImage == null) {
        Get.snackbar("Error", "Not able to upload image");
        isLoading.value = false;
        update();
        return null;
      }
    }

    await _storageController.loadTags();

    var tags = _storageController.tags.value;

    var id = tagId ??
        tags
            .where((tag) => tag.tag.toLowerCase().contains("vicinity"))
            .firstOrNull
            ?.id ??
        tags
            .firstWhereOrNull((tag) => tag.tag.toLowerCase().contains("ask"))
            ?.id ??
        8;

    var newOffer = VicinityOffer(
      name: offer.name,
      images: offer.images.isNotEmpty
          ? offer.images
          : uploadedImage.isNotEmpty
              ? [uploadedImage]
              : [],
      desc: offer.desc,
      expiryAt: offer.expiryAt,
      userId: _userController.user!.id,
      tagIds: [id],
      location: offer.location,
      distance: offer.distance,
    );

    final result = await _vicinityApi.createVicinity(
      offer: newOffer,
    );

    isLoading.value = false;
    update();

    return result.fold(
      (failure) async {
        Get.snackbar('Error', failure.message,
            snackPosition: SnackPosition.TOP);
        if (uploadedImage != null) {
          await deleteImage(
              "$uname-$offername-${DateTime.now().toIso8601String()}.jpg");
        }
        return null;
      },
      (offer) {
        // offers.add(offer);
        Get.snackbar('Success', 'Offer created successfully',
            snackPosition: SnackPosition.TOP);
        return offer;
      },
    );
  }

  Future<bool> deleteImage(String imageName) async {
    isLoading.value = true;
    update();

    var accessToken = await _storageController.getAccessToken();

    if (accessToken == null) {
      return false;
    }

    final result = await _vicinityApi.deleteImage(
      fileName: imageName,
      accessToken: accessToken,
    );

    result.fold(
      (failure) {
        return false;
      },
      (success) {
        return true;
      },
    );

    isLoading.value = false;
    update();
    return false;
  }

  Future<void> searchVicinity() async {
    isLoading.value = true;
    update();

    final result = await _vicinityApi.searchVicinity();

    result.fold(
      (failure) {
        Get.snackbar('Error', failure.message,
            snackPosition: SnackPosition.BOTTOM);
      },
      (offersList) {
        offers.value = offersList;
        Get.snackbar('Success', 'Offers fetched successfully',
            snackPosition: SnackPosition.BOTTOM);
      },
    );

    isLoading.value = false;
    update();
  }
}
