import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/dialog_widgets.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/validators/vehicle_validation_mixin.dart';
import 'package:picapool/features/buy_and_sell/products_controller.dart';
import 'package:picapool/features/buy_and_sell/values/common_details_model.dart';
import 'package:picapool/features/buy_and_sell/values/model.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/screens/buy_and_sell/values/filter_data.dart';
import 'package:picapool/screens/buy_and_sell/values/product_condition_class.dart';

class VehicleFormController extends GetxController with VehicleValidationMixin {
  TextEditingController typeController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController kmsDrivenController = TextEditingController();
  TextEditingController specificationController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final StorageController _storageController = Get.find<StorageController>();

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
      category: FilterDataEnum.vehicle.name,
    );

    var additional = {
      "releaseYear": yearController.text,
      "brand": brandController.text,
      "KMsDriven": kmsDrivenController.text,
      "specifications": specificationController.text,
    };
    productModel.imagesFile = commonDetails.images;
    productModel.attributes.addAll(additional);

    createProduct(productModel);
  }

  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }
}
