import 'package:get/get.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/offers/offers_api.dart';
import 'package:picapool/models/offer_model.dart';

class OffersController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var offers = <Offer>[].obs;
  final AuthController _authController = Get.find<AuthController>();

  Future<void> fetchOffers() async {
    isLoading.value = true;
    errorMessage.value = '';
    update();

    final result =
        await OffersApi.getOffers(_authController.auth.value!.accessToken!);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message,
            snackPosition: SnackPosition.TOP);
      },
      (offersList) {
        offers.value = offersList;
      },
    );

    isLoading.value = false;
    update();
  }
}
