import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/common/widgets/dotted_border.dart';
import 'package:picapool/common/widgets/text_field_widgets.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/common_additional_form_details_controller.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/others_form_controller.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/features/selling_category/create_product_offer_with_category_widget.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/text_field_with_custom_heading.dart';
import 'package:picapool/screens/buy_and_sell/values/product_condition_class.dart';
import 'package:picapool/utils/theme.dart';

class CreateOthersCategoryProduct extends StatefulWidget {
  const CreateOthersCategoryProduct({super.key});

  @override
  State<CreateOthersCategoryProduct> createState() =>
      _CreateOthersCategorStateyProduct();
}

class _CreateOthersCategorStateyProduct
    extends State<CreateOthersCategoryProduct> {
  late OthersFormController _formController;
  late CommonAdditionalFormDetailsController _additionalFormDetailsController;

  @override
  Widget build(BuildContext context) {
    return CreateProductOfferWithCategory(
      additionalFormDetailsController: _additionalFormDetailsController,
      formKey: _formController.formKey,
      onSubmit: () {
        var data = _additionalFormDetailsController.getData();
        if (data == null) {
          return;
        }
        _formController.onSubmit(data);
      },
      title: "Others",
      isLoading: false.obs,
      productConditions: productElectronicsCondition,
      child: Column(
        children: [
          TextFieldWithCustomHeading(
            title: "Product name",
            controller: _formController.nameController,
            hintText: "Product name",
          ),
          const SizedBox(
            height: PicaValues.largeSpacing,
          ),
          TextFieldWithCustomHeading(
            title: "Add description",
            controller: _formController.descriptionController,
            hintText: "A short description about the product",
            maxlines: 3,
            maxWordLength: 200,
          ),
          const SizedBox(
            height: PicaValues.largeSpacing,
          ),
          Obx(
            () => _formController.customFields.isEmpty
                ? CustomPaint(
                    painter: DottedBorderPainter(
                      color: AppTheme.currentTheme.dividerColor,
                      strokeWidth: 1,
                      dashLength: 4,
                      dashGap: 4,
                      borderRadius: 15,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          'No custom fields added yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _formController.customFields.length,
                    itemBuilder: (context, index) {
                      final field = _formController.customFields[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      field['name']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(field['value']!),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () =>
                                    _formController.removeCustomField(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(
            height: PicaValues.smallSpacing,
          ),
          CustomPaint(
            painter: DottedBorderPainter(
              color: AppTheme.currentTheme.primaryColor,
              strokeWidth: 1,
              dashLength: 4,
              dashGap: 4,
              borderRadius: 15,
            ),
            child: Container(
              decoration: roundedContainer().copyWith(
                color: AppTheme.currentTheme.dividerColor.withAlpha(1),
              ),
              clipBehavior: Clip.hardEdge,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PicaOutlinedTextField(
                    controller: _formController.customFieldNameController,
                    labelText: 'Field Name',
                    hintText: 'E.g., Color, Size, Material',
                  ),
                  const SizedBox(height: 12),
                  PicaOutlinedTextField(
                    controller: _formController.customFieldValueController,
                    labelText: 'Field Value',
                    hintText: 'E.g., Red, Large, Metal',
                  ),
                  const SizedBox(height: 16),
                  PicaPrimaryButton(
                    onPressed: _formController.addCustomField,
                    text: 'ADD FIELD',
                    isLoading: false.obs,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Get.put(OthersFormController());
    _formController = Get.find<OthersFormController>();
    Get.put(CommonAdditionalFormDetailsController());
    _additionalFormDetailsController =
        Get.find<CommonAdditionalFormDetailsController>();
  }
}
