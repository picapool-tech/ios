import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/dialog_widgets.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/validators/books_validation_mixin.dart';
import 'package:picapool/features/buy_and_sell/products_controller.dart';
import 'package:picapool/features/buy_and_sell/values/common_details_model.dart';
import 'package:picapool/features/buy_and_sell/values/model.dart';
import 'package:picapool/features/storage/storage_controller.dart';

class BooksFormController extends GetxController with BooksValidationMixin {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final StorageController _storageController = Get.find<StorageController>();
  final ProductsController _productController = Get.find<ProductsController>();

  GlobalKey<FormState> formKey = GlobalKey();

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

  void onSubmit(CommonDetailsModel commonData) async {
    if (!validate()) {
      return;
    }

    var productModel = ProductRequestModel.getWithCommondDetails(
      commonData,
      name: titleController.text,
      description: descriptionController.text,
      userId: _storageController.user.value!.id,
      offerIds: [],
    );

    var additional = {
      'author': authorController.text,
      'genre': genreController.text,
    };

    productModel.attributes.addAll(additional);
    productModel.imagesFile = commonData.images;
    createProduct(productModel);
  }

  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }
}
