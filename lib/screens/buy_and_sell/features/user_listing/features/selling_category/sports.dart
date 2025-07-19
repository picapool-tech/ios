import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/common_additional_form_details_controller.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/electronics_form_controller.dart';
import 'package:picapool/features/buy_and_sell/products_controller.dart';
import 'package:picapool/features/buy_and_sell/values/enums.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/features/selling_category/create_product_offer_with_category_widget.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/text_field_with_custom_heading.dart';
import 'package:picapool/screens/buy_and_sell/values/product_condition_class.dart';

class Sports extends StatefulWidget {
  const Sports({super.key});

  @override
  State<Sports> createState() => _SportsState();
}

class _SportsState extends State<Sports> {
  final ProductsController _productsController = Get.find<ProductsController>();
  late ElectronicsFormController _formController;
  late CommonAdditionalFormDetailsController
      _commonAdditionalFormDetailsController;

  @override
  Widget build(BuildContext context) {
    return CreateProductOfferWithCategory(
      additionalFormDetailsController: _commonAdditionalFormDetailsController,
      formKey: _formController.formKey,
      onSubmit: () {
        var data = _commonAdditionalFormDetailsController.getData();
        if (data != null) {
          _formController.onSubmit(data);
        }
      },
      title: "Sports",
      isLoading: _productsController
          .getLoadingState(ProductLoadingEnums.createProduct),
      productConditions: productClothsCondition,
      child: Column(
        children: [
          TextFieldWithCustomHeading(
            title: "Type",
            controller: _formController.deviceTypeController,
            hintText: "(e.g.. bat, badminton)",
            validator: _formController.validateField,
          ),
          const SizedBox(
            height: PicaValues.largeSpacing,
          ),
          Row(
            children: [
              Expanded(
                child: TextFieldWithCustomHeading(
                  title: "Model name:",
                  controller: _formController.modelNameController,
                  hintText: "abc",
                  validator: _formController.validateField,
                ),
              ),
              const SizedBox(
                width: PicaValues.largeSpacing,
              ),
              Expanded(
                child: TextFieldWithCustomHeading(
                  title: "Brand:",
                  controller: _formController.brandController,
                  hintText: "ABC",
                  validator: _formController.validateField,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: PicaValues.largeSpacing,
          ),
          TextFieldWithCustomHeading(
            title: "Add description",
            controller: _formController.descriptionController,
            hintText: "A short description about the product",
            maxlines: 3,
            validator: _formController.validateField,
            maxWordLength: 200,
          ),
          const SizedBox(
            height: PicaValues.largeSpacing,
          ),
          TextFieldWithCustomHeading(
            title: "Accessories included:",
            controller: _formController.accessoriesController,
            hintText: "abc",
            validator: _formController.validateField,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Get.put(ElectronicsFormController());
    _formController = Get.find<ElectronicsFormController>();
    Get.put(CommonAdditionalFormDetailsController());
    _commonAdditionalFormDetailsController =
        Get.find<CommonAdditionalFormDetailsController>();
  }
}
