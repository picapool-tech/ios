import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picapool/common/widgets/dialog_widgets.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/validators/common_details_validator_mixin.dart';
import 'package:picapool/features/buy_and_sell/values/common_details_model.dart';
import 'package:picapool/models/product_model.dart';
import 'package:picapool/screens/buy_and_sell/values/product_condition_class.dart';

class CommonAdditionalFormDetailsController extends GetxController
    with CommonDetailsValidatorMixin {
  var images = <XFile>[].obs;
  var isLessThanAMonth = false.obs;
  Rx<ProductCondition?> productCondition = Rx(null);
  final TextEditingController mrpController = TextEditingController();
  final TextEditingController offerPriceController = TextEditingController();
  final TextEditingController yearsHeldController = TextEditingController();
  final TextEditingController monthsHeldController = TextEditingController();
  final TextEditingController reasonForSellController = TextEditingController();

  CommonAdditionalFormDetailsController();

  void addImages(List<XFile> newImages) {
    if (newImages.isNotEmpty) {
      images.addAll(newImages);
    }
  }

  void fillForUpdate(Product product) async {
    var attributes = product.attributes!;
    var condition = productBooksCondition.indexWhere(
        (condition) => condition.name == attributes['productCondition']);

    mrpController.text = product.mrp?.toString() ?? '0';
    offerPriceController.text = product.offerPrice?.toString() ?? '0';

    yearsHeldController.text = attributes['yearHeld'] ?? '0';
    monthsHeldController.text = attributes['monthsHeld'] ?? '0';
    isLessThanAMonth.value = attributes['timeHeld'] != null ? true : false;

    reasonForSellController.text = attributes['reasonForSell'];

    productCondition.value = productBooksCondition[condition];
    update();
  }

  CommonDetailsModel? getData() {
    if (!validate()) {
      return null;
    }
    var commonDetails = CommonDetailsModel(
      images: images,
      productCondition: productCondition.value!,
      mrp: mrpController.text,
      offerPrice: offerPriceController.text,
      yearsHeld:
          yearsHeldController.text.isEmpty ? "0" : yearsHeldController.text,
      monthsHeld:
          monthsHeldController.text.isEmpty ? "0" : monthsHeldController.text,
      reasonForSell: reasonForSellController.text,
      email: "notrequired@email.com",
      isLessThanAMonth: isLessThanAMonth.value,
    );

    return commonDetails;
  }

  void removeImage(int index) {
    images.removeAt(index);
  }

  void updateIsLessThanAMonth(bool value) {
    isLessThanAMonth.value = value;
  }

  bool validate() {
    if (images.isEmpty) {
      showPicaAlertDialog(
        message: "Please add images for your product listing",
        confirmText: "Okay",
        onConfirm: () => Get.back(),
      );
      return false;
    }

    if (productCondition.value == null) {
      return false;
    }

    if (yearsHeldController.text.isEmpty &&
        monthsHeldController.text.isEmpty &&
        !isLessThanAMonth.value) {
      showPicaAlertDialog(
        message:
            "You need to fill atleast any one year, month or less than a month option.",
        confirmText: "Okay",
        onConfirm: () {
          Get.back();
        },
      );
    }

    debugPrint(mrpController.text);
    debugPrint(offerPriceController.text);
    debugPrint(yearsHeldController.text);
    debugPrint(monthsHeldController.text);
    debugPrint(reasonForSellController.text);

    return mrpController.text.isNotEmpty &&
        offerPriceController.text.isNotEmpty &&
        reasonForSellController.text.isNotEmpty;
  }
}
