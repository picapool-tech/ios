import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/clothes_form_controller.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/common_additional_form_details_controller.dart';
import 'package:picapool/features/buy_and_sell/products_controller.dart';
import 'package:picapool/features/buy_and_sell/values/enums.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/features/selling_category/create_product_offer_with_category_widget.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/enum_form_field.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/text_field_with_custom_heading.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/widget_with_custom_heading.dart';
import 'package:picapool/screens/buy_and_sell/values/product_condition_class.dart';

class CreateClothesProduct extends StatefulWidget {
  const CreateClothesProduct({super.key});

  @override
  State<CreateClothesProduct> createState() => CreateClothesProductState();
}

class CreateClothesProductState extends State<CreateClothesProduct> {
  final ProductsController _productsController = Get.find<ProductsController>();
  late ClothesFormController _formController;

  late CommonAdditionalFormDetailsController _commonFormDetailsController;

  @override
  Widget build(BuildContext context) {
    return CreateProductOfferWithCategory(
      title: "Clothes",
      additionalFormDetailsController: _commonFormDetailsController,
      formKey: _formController.formKey,
      productConditions: productClothsCondition,
      onSubmit: () {
        var commonData = _commonFormDetailsController.getData();
        if (commonData == null) {
          return;
        }
        _formController.onSubmitted(commonData);
      },
      isLoading: _productsController.getLoadingState(
        ProductLoadingEnums.createProduct,
      ),
      child: Column(
        children: [
          TextFieldWithCustomHeading(
            title: "Style",
            controller: _formController.styleController,
            hintText: "(e.g.. t-shirt, jeans, dress)",
            validator: _formController.validateStyle,
          ),
          const SizedBox(
            height: PicaValues.largeSpacing,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFieldWithCustomHeading(
                  title: "Fabric",
                  controller: _formController.fabricController,
                  hintText: "Cotton, Nylon",
                  validator: _formController.validateStyle,
                ),
              ),
              const SizedBox(
                width: PicaValues.largeSpacing,
              ),
              Expanded(
                child: TextFieldWithCustomHeading(
                  title: "Brand",
                  controller: _formController.brandController,
                  hintText: "ABC",
                  validator: _formController.validateBrand,
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
            hintText: "A short description about the cloth",
            maxlines: 3,
            validator: _formController.validateDescription,
            maxWordLength: 200,
          ),
          const SizedBox(
            height: PicaValues.largeSpacing,
          ),
          WidgetWithCustomHeading(
            title: "Size",
            child: ProductContitionFormField(
              initialValue: _formController.clothSize,
              conditions: productClothSize,
              onSelected: (selectedSize) {
                _formController.clothSize = selectedSize;
              },
              displayNameGetter: (productCondition) =>
                  productCondition.name.toUpperCase(),
              validator: _formController.validateSize,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Get.put(ClothesFormController());
    _formController = Get.find<ClothesFormController>();
    Get.put(
      CommonAdditionalFormDetailsController(),
    );

    _commonFormDetailsController =
        Get.find<CommonAdditionalFormDetailsController>();
  }
}
