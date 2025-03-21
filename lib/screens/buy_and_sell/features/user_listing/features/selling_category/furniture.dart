import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/common_additional_form_details_controller.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/furniture_form_controller.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/features/selling_category/create_product_offer_with_category_widget.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/text_field_with_custom_heading.dart';
import 'package:picapool/screens/buy_and_sell/values/product_condition_class.dart';

class CreateFurnitureProduct extends StatefulWidget {
  const CreateFurnitureProduct({super.key});

  @override
  State<CreateFurnitureProduct> createState() => _CreateFurnitureProductState();
}

class _CreateFurnitureProductState extends State<CreateFurnitureProduct> {
  late CommonAdditionalFormDetailsController _additionalFormDetailsController;
  late FurnitureFormController _formController;
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
      title: "Furniture",
      isLoading: false.obs,
      productConditions: productElectronicsCondition,
      child: Column(
        children: [
          TextFieldWithCustomHeading(
            title: "Type",
            controller: _formController.typeController,
            hintText: "(e.g.. desk, bed)",
            validator: _formController.validateField,
          ),
          const SizedBox(
            height: PicaValues.largeSpacing,
          ),
          Row(
            children: [
              Expanded(
                child: TextFieldWithCustomHeading(
                  title: "Material:",
                  controller: _formController.materialController,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dimensions Unit",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      hint: const Text("Select unit"),
                      value: _formController.dimension,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _formController.dimension = newValue;
                          });
                        }
                      },
                      validator: (value) =>
                          value == null ? "Please select a unit" : null,
                      items: <String>["Centimeters", "Inches", "Meters", "Feet"]
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
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
                  title: "Height:",
                  controller: _formController.heightController,
                  hintText: "0",
                  validator: _formController.validateUnits,
                ),
              ),
              const SizedBox(
                width: PicaValues.largeSpacing,
              ),
              Expanded(
                child: TextFieldWithCustomHeading(
                  title: "Length:",
                  controller: _formController.lengthController,
                  hintText: "0",
                  validator: _formController.validateUnits,
                ),
              ),
              const SizedBox(
                width: PicaValues.largeSpacing,
              ),
              Expanded(
                child: TextFieldWithCustomHeading(
                  title: "Breadth:",
                  controller: _formController.breadthController,
                  hintText: "0",
                  validator: _formController.validateUnits,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Get.put(FurnitureFormController());
    _formController = Get.find<FurnitureFormController>();
    Get.put(CommonAdditionalFormDetailsController());
    _additionalFormDetailsController =
        Get.find<CommonAdditionalFormDetailsController>();
  }
}
