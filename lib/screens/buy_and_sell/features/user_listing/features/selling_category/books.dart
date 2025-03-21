import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/books_form_controller.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/common_additional_form_details_controller.dart';
import 'package:picapool/features/buy_and_sell/products_controller.dart';
import 'package:picapool/features/buy_and_sell/values/enums.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/features/selling_category/create_product_offer_with_category_widget.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/text_field_with_custom_heading.dart';
import 'package:picapool/screens/buy_and_sell/values/product_condition_class.dart';

class CreateBookProducts extends StatefulWidget {
  const CreateBookProducts({super.key});

  @override
  State<CreateBookProducts> createState() => _CreateBookProductsState();
}

class _CreateBookProductsState extends State<CreateBookProducts> {
  final ProductsController _productsController = Get.find<ProductsController>();
  late CommonAdditionalFormDetailsController _additionalFormDetailsController;
  late BooksFormController _formController;
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
      title: "Books",
      isLoading: _productsController
          .getLoadingState(ProductLoadingEnums.createProduct),
      productConditions: productBooksCondition,
      child: Column(
        children: [
          TextFieldWithCustomHeading(
            title: "Title:",
            controller: _formController.titleController,
            hintText: "ABC",
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
                  title: "Author:",
                  controller: _formController.authorController,
                  hintText: "abc",
                  validator: _formController.validateField,
                ),
              ),
              const SizedBox(
                width: PicaValues.largeSpacing,
              ),
              Expanded(
                child: TextFieldWithCustomHeading(
                  title: "Genre:",
                  controller: _formController.genreController,
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
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Get.put(BooksFormController());
    _formController = Get.find<BooksFormController>();
    Get.put(CommonAdditionalFormDetailsController());
    _additionalFormDetailsController =
        Get.find<CommonAdditionalFormDetailsController>();
  }
}
