import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/common_additional_form_details_controller.dart';
import 'package:picapool/features/buy_and_sell/products_controller.dart';
import 'package:picapool/features/buy_and_sell/values/enums.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/common_additional_form_details.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/enum_form_field.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/image_container_with_picker.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/widget_with_custom_heading.dart';
import 'package:picapool/screens/buy_and_sell/values/product_condition_class.dart';
import 'package:picapool/utils/image_utils.dart';

class CreateProductOfferWithCategory<T extends Enum> extends StatelessWidget {
  final CommonAdditionalFormDetailsController additionalFormDetailsController;
  final GlobalKey<FormState> formKey;
  final Widget child;
  final void Function() onSubmit;
  final String title;
  final RxBool isLoading;
  final List<ProductCondition> productConditions;

  const CreateProductOfferWithCategory({
    super.key,
    required this.additionalFormDetailsController,
    required this.child,
    required this.formKey,
    required this.onSubmit,
    required this.title,
    required this.isLoading,
    required this.productConditions,
  });

  ProductsController get _controller => Get.find<ProductsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(PicaValues.largeSpacing),
        child: AbsorbPointer(
          absorbing: isLoading.value,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Obx(
                  () => ImageContainerWithPicker(
                    onClicked: () {
                      _pickImages();
                    },
                    onImageRemoveTap: (index) {
                      additionalFormDetailsController.removeImage(index);
                    },
                    // value is uses specifically for obx to not throw error
                    images: additionalFormDetailsController.images.value,
                    hintText:
                        "Adding multiple images helps your sells to go up",
                  ),
                ),
                const SizedBox(
                  height: PicaValues.largeSpacing,
                ),
                child,
                const SizedBox(
                  height: PicaValues.largeSpacing,
                ),
                WidgetWithCustomHeading(
                  title: "Product condition: ",
                  child: ProductContitionFormField(
                    conditions: productConditions,
                    onSelected: (ProductCondition selectedCondition) {
                      additionalFormDetailsController.productCondition.value =
                          selectedCondition;
                    },
                    displayNameGetter: (ProductCondition productCondition) =>
                        productCondition.name,
                    assetLocationGetter: (productCondition) =>
                        productCondition.assetLocation,
                    initialValue:
                        additionalFormDetailsController.productCondition.value,
                    validator:
                        additionalFormDetailsController.validateCondition,
                  ),
                ),
                const SizedBox(
                  height: PicaValues.largeSpacing,
                ),
                CommonAdditionalFormDetails(
                  commonDetailsController: additionalFormDetailsController,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kBottomNavigationBarHeight,
          padding: const EdgeInsets.all(5),
          child: PicaPrimaryButton(
            text: "Sell now",
            onPressed: () {
              formKey.currentState?.validate();
              onSubmit();
            },
            isLoading:
                _controller.getLoadingState(ProductLoadingEnums.createProduct),
          ),
        ),
      ),
    );
  }

  void _pickImages() async {
    var listOfImages = await ImageUtils.pickImages();
    additionalFormDetailsController.addImages(listOfImages ?? []);
  }
}
