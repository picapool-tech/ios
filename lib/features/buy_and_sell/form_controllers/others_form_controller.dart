import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/dialog_widgets.dart';
import 'package:picapool/features/buy_and_sell/products_controller.dart';
import 'package:picapool/features/buy_and_sell/values/common_details_model.dart';
import 'package:picapool/features/buy_and_sell/values/model.dart';
import 'package:picapool/features/storage/storage_controller.dart';

class OthersFormController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final StorageController _storageController = Get.find<StorageController>();

  final RxList<Map<String, String>> customFields = <Map<String, String>>[].obs;
  final customFieldNameController = TextEditingController();
  final customFieldValueController = TextEditingController();

  void addCustomField() {
    if (customFieldNameController.text.isEmpty ||
        customFieldValueController.text.isEmpty) {
      Get.snackbar(
        'Invalid Input',
        'Both field name and value are required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    customFields.add({
      'name': customFieldNameController.text.trim(),
      'value': customFieldValueController.text.trim(),
    });

    customFieldNameController.clear();
    customFieldValueController.clear();
  }

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
          });
    }
  }

  void onSubmit(CommonDetailsModel commonDetails) {
    if (!validate()) {
      return;
    }

    var productModel = ProductRequestModel.getWithCommondDetails(
      commonDetails,
      name: nameController.text,
      description: descriptionController.text,
      userId: _storageController.user.value!.id,
      offerIds: [],
    );

    productModel.imagesFile = commonDetails.images;

    // Add all custom fields to attributes
    for (var field in customFields) {
      productModel.attributes[field['name']!] = field['value'];
    }

    createProduct(productModel);
  }

  void removeCustomField(int index) {
    customFields.removeAt(index);
  }

  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }
}
