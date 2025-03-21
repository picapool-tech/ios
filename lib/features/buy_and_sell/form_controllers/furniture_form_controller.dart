import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/dialog_widgets.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/validators/furniture_validation_mixin.dart';
import 'package:picapool/features/buy_and_sell/products_controller.dart';
import 'package:picapool/features/buy_and_sell/values/common_details_model.dart';
import 'package:picapool/features/buy_and_sell/values/model.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/screens/buy_and_sell/values/product_condition_class.dart';

class FurnitureFormController extends GetxController
    with FurnitureValidationMixin {
  final TextEditingController typeController = TextEditingController();
  final TextEditingController materialController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController breadthController = TextEditingController();

  final StorageController _storageController = Get.find<StorageController>();

  String? dimension;
  GlobalKey<FormState> formKey = GlobalKey();
  ProductCondition? productCondition;

  void createProduct(ProductRequestModel productModel) async {
    var product =
        await Get.find<ProductsController>().createProduct(productModel);
    if (product != null) {
      showPicaAlertDialog(
        message: "Your listing has been created",
        confirmText: "Sounds Good",
        onConfirm: () {
          formKey.currentState?.reset();
          Get.back();
        },
      );
    } else {
      showPicaAlertDialog(
        message: "Your listing has not been created",
        confirmText: "Try again",
        onConfirm: () {
          Get.back();
          formKey.currentState?.reset();
          Get.back();
        },
        cancelText: "Cancel",
        onCancel: () {
          Get.back();
        },
      );
    }
  }

  void onSubmit(CommonDetailsModel commonDetails) async {
    if (!validate()) {
      return;
    }

    var productModel = ProductRequestModel.getWithCommondDetails(
      commonDetails,
      name: typeController.text,
      description: descriptionController.text,
      userId: _storageController.user.value!.id,
      offerIds: [],
    );

    productModel.imagesFile = commonDetails.images;
    var additional = {
      'material': materialController.text,
      'brand': brandController.text,
      'dimension':
          "${heightController.text} x ${lengthController.text} x ${breadthController.text} ${dimension!}",
    };

    productModel.attributes.addAll(additional);

    createProduct(productModel);
  }

  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }
}
