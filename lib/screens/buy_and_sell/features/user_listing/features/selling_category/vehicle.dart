import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/common_additional_form_details_controller.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/vehicle_form_controller.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/features/selling_category/create_product_offer_with_category_widget.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/text_field_with_custom_heading.dart';
import 'package:picapool/screens/buy_and_sell/values/product_condition_class.dart';

class VehicleCategory extends StatefulWidget {
  const VehicleCategory({super.key});

  @override
  State<VehicleCategory> createState() => _VehicleCategoryState();
}

class _VehicleCategoryState extends State<VehicleCategory> {
  late VehicleFormController _formController;
  late CommonAdditionalFormDetailsController _additionalFormDetailsController;
  @override
  Widget build(BuildContext context) {
    return CreateProductOfferWithCategory(
        additionalFormDetailsController: _additionalFormDetailsController,
        formKey: _formController.formKey,
        onSubmit: () {
          var data = _additionalFormDetailsController.getData();
          if (data != null) {
            _formController.onSubmit(data);
          }
        },
        title: "Vehicle",
        isLoading: false.obs,
        productConditions: productElectronicsCondition,
        child: Column(
          children: [
            TextFieldWithCustomHeading(
              title: "Type",
              controller: _formController.typeController,
              hintText: "(e.g.. Bike, Car)",
              validator: _formController.validateField,
            ),
            const SizedBox(
              height: PicaValues.largeSpacing,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFieldWithCustomHeading(
                    title: "Year:",
                    controller: _formController.yearController,
                    hintText: "abc",
                    isNumber: true,
                    showNumberFormatting: false,
                    isCurrency: false,
                    validator: _formController.validateYear,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFieldWithCustomHeading(
                    title: "KMs driven:",
                    controller: _formController.kmsDrivenController,
                    hintText: "2000",
                    isNumber: true,
                    isCurrency: false,
                    suffixText: "KM",
                    validator: _formController.validateKmsDriven,
                  ),
                ),
                const SizedBox(
                  width: PicaValues.largeSpacing,
                ),
                Expanded(
                  child: TextFieldWithCustomHeading(
                    title: "Specifications",
                    controller: _formController.specificationController,
                    hintText: "abc",
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
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
    Get.put(VehicleFormController());
    _formController = Get.find<VehicleFormController>();
    Get.put(CommonAdditionalFormDetailsController());
    _additionalFormDetailsController =
        Get.find<CommonAdditionalFormDetailsController>();
  }
}
