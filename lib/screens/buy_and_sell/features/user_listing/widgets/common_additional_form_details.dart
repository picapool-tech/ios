import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/common/widgets/text_field_widgets.dart';
import 'package:picapool/features/buy_and_sell/form_controllers/common_additional_form_details_controller.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/text_field_with_custom_heading.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/widget_with_custom_heading.dart';

class CommonAdditionalFormDetails extends StatelessWidget {
  final CommonAdditionalFormDetailsController commonDetailsController;
  const CommonAdditionalFormDetails({
    super.key,
    required this.commonDetailsController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: PicaValues.largeSpacing,
        ),
        TextFieldWithCustomHeading(
          title: "MRP:",
          controller: commonDetailsController.mrpController,
          hintText: "000",
          isNumber: true,
          isCurrency: true,
          validator: commonDetailsController.validateMrp,
        ),
        const SizedBox(
          height: PicaValues.largeSpacing,
        ),
        TextFieldWithCustomHeading(
          title: "Offer Price:",
          controller: commonDetailsController.offerPriceController,
          hintText: "000",
          isNumber: true,
          isCurrency: true,
          validator: commonDetailsController.validateOfferPrice,
        ),
        const SizedBox(
          height: PicaValues.largeSpacing,
        ),
        WidgetWithCustomHeading(
          title: "Time held:",
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PicaOutlinedTextField(
                  hintText: "0 Years",
                  suffixText: "Years",
                  controller: commonDetailsController.yearsHeldController,
                  keyboardType: TextInputType.number,
                  validator: commonDetailsController.validateYear,
                ),
              ),
              const SizedBox(
                width: PicaValues.smallSpacing,
              ),
              Expanded(
                child: PicaOutlinedTextField(
                  hintText: "0 Months",
                  suffixText: "Months",
                  controller: commonDetailsController.monthsHeldController,
                  keyboardType: TextInputType.number,
                  validator: commonDetailsController.validateMonth,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: PicaValues.smallSpacing,
        ),
        InkWell(
          onTap: () {
            commonDetailsController.updateIsLessThanAMonth(
                !commonDetailsController.isLessThanAMonth.value);
          },
          child: Row(
            children: [
              Obx(
                () => Checkbox(
                  value: commonDetailsController.isLessThanAMonth.value,
                  onChanged: (value) {
                    commonDetailsController
                        .updateIsLessThanAMonth(value ?? false);
                  },
                ),
              ),
              const Text(
                "Less than a month",
              ),
            ],
          ),
        ),
        const SizedBox(
          height: PicaValues.largeSpacing,
        ),
        TextFieldWithCustomHeading(
          title: "Reason for sell: ",
          controller: commonDetailsController.reasonForSellController,
          hintText: "Write a reason why you are selling this product.",
          validator: commonDetailsController.validateReasonForSell,
        ),
      ],
    );
  }
}
