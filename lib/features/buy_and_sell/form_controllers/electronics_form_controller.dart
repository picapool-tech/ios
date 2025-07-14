import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/dialog_widgets.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/validators/electronics_validation_mixin.dart';
import 'package:picapool/features/buy_and_sell/products_controller.dart';
import 'package:picapool/features/buy_and_sell/values/common_details_model.dart';
import 'package:picapool/features/buy_and_sell/values/product_request_model.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/screens/buy_and_sell/values/filter_data.dart';

class ElectronicsFormController extends GetxController
    with ElectronicsValidationMixin {
  final TextEditingController deviceTypeController = TextEditingController();
  final TextEditingController modelNameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController accessoriesController = TextEditingController();

  final StorageController _storageController = Get.find<StorageController>();

  final GlobalKey<FormState> formKey = GlobalKey();

  void createProduct(ProductRequestModel productModel) async {
    var product =
        await Get.find<ProductsController>().createProduct(productModel);
    if (product != null) {
      showPicaAlertDialog(
        message: "Your listing has been created",
        confirmText: "Sounds Good",
        onConfirm: () {
          Get.back(closeOverlays: true, canPop: true);
          formKey.currentState?.reset();
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
      name: deviceTypeController.text,
      description: descriptionController.text,
      userId: _storageController.user.value!.id,
      offerIds: [],
      category: FilterDataEnum.electronics.name,
    );

    var additional = {
      'modelName': modelNameController.text,
      'accessories': accessoriesController.text,
      'brand': brandController.text,
    };

    productModel.attributes.addAll(additional);

    productModel.imagesFile = commonDetails.images;

    createProduct(productModel);
  }

  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }
}
