import 'package:get/get.dart';
import 'package:picapool/functions/partners/partnerModel/partner_request_model.dart';
import 'package:picapool/functions/partners/partner_api.dart';
import 'package:picapool/models/partner_model.dart';

class PartnerController extends GetxController {
  final PartnerApi _partnerApi = PartnerApi();

  var isLoading = false.obs;
  var partners = <Partner>[].obs;

  Future<List<Partner>> searchPartner(PartnerRequestModel data) async {
    isLoading(true);
    update();
    try {
      var response = await _partnerApi.searchPartner(data);
      response.fold(
        (error) => Get.snackbar(
          "Error",
          error.message,
        ),
        (listOfPartners) => partners.assignAll(
          listOfPartners,
        ),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "$e",
      );
    } finally {
      isLoading(false);
      update();
    }
    return partners;
  }
}
