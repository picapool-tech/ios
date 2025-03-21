import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/dialog_widgets.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/validators/clothes_validation_mixin.dart';
import 'package:picapool/features/buy_and_sell/products_controller.dart';
import 'package:picapool/features/buy_and_sell/values/common_details_model.dart';
import 'package:picapool/features/buy_and_sell/values/model.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/screens/buy_and_sell/values/product_condition_class.dart';

class ClothesFormController extends GetxController with ClothesValidationMixin {
  var styleController = TextEditingController();
  var fabricController = TextEditingController();
  var brandController = TextEditingController();
  var descriptionController = TextEditingController();
  var mrpController = TextEditingController();

  final ProductsController _productsController = Get.find<ProductsController>();
  final StorageController _storageController = Get.find<StorageController>();

  final formKey = GlobalKey<FormState>();
  final commonDetailsFormKey = GlobalKey<FormState>();

  ProductCondition? clothSize;

  void createProduct(ProductRequestModel productModel) async {
    var product =
        await Get.find<ProductsController>().createProduct(productModel);
    if (product != null) {
      showPicaAlertDialog(
        message: "Your listing has been created",
        confirmText: "Sounds Good",
        onConfirm: () {
          Get.back();
          formKey.currentState?.reset();
          Get.back();
        },
      );
    } else {
      showPicaAlertDialog(
        message: "Your listing has not been created",
        confirmText: "Try again",
        onConfirm: () {
          createProduct(productModel);
          Get.back();
        },
        cancelText: "Cancel",
        onCancel: () {
          Get.back();
        },
      );
    }
  }

  bool isValid() {
    var value = formKey.currentState?.validate() ?? false;
    var validClothSize = clothSize != null;
    return value && validClothSize;
  }

  void onSubmitted(CommonDetailsModel commondDetails) async {
    if (!isValid()) {
      return;
    }
    var modelJson = {
      'name': styleController.text,
      'description': descriptionController.text,
      'phone': _storageController.auth.value?.mobile ?? "+918521086453",
      'userId': _storageController.user.value!.id,
      "attributes": {
        ...commondDetails.toJsonForAttributes(),
      },
      ...commondDetails.toJsonRequired(),
      'offerIds': [],
      'imagesFile': commondDetails.images,
    };

    var productModel = ProductRequestModel.fromJson(modelJson);
    productModel.imagesFile = commondDetails.images;

    createProduct(productModel);
  }
}
