import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/controllers/sell_form_controller.dart';
import 'package:picapool/screens/sell/select_category_page.dart';
import 'package:picapool/utils/routes.dart';
import 'package:picapool/widgets/Sell_Form_Page0.dart' as page0;
import 'package:picapool/widgets/sell/build_field.dart';

class SellFormTwo extends StatefulWidget {
  @override
  State<SellFormTwo> createState() => _SellFormTwoState();
}

class _SellFormTwoState extends State<SellFormTwo> {
  bool isLessThanMonth = false; // To track the state of the checkbox
  TextEditingController yearsController = TextEditingController();
  TextEditingController monthsController = TextEditingController();
  TextEditingController reasonForSellController = TextEditingController();
  TextEditingController sellingPriceController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final formController = Get.find<FormController>();

    final sellformTwoKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xffFF8D41)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Almost done',
                    style: TextStyle(
                      fontFamily: "MontserratM",
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: sellformTwoKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StepIndicator(currentStep: 3),
                    const SizedBox(height: 20),
                    const Text(
                      "Time Held",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'MontserratR',
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Visibility(
                      visible: !isLessThanMonth,
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            child: buildSmallTextField(
                              controller: yearsController,
                              hintText: 'Y',
                              enabled: !isLessThanMonth,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Years",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'MontserratR',
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            width: 80,
                            child: buildSmallTextField(
                              controller: monthsController,
                              hintText: 'M',
                              enabled: !isLessThanMonth,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Months",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'MontserratR',
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CheckboxListTile(
                        title: const Text("Less than a month"),
                        value: isLessThanMonth,
                        onChanged: (newValue) {
                          setState(() {
                            isLessThanMonth = newValue ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: const Color(0xffFF8D41),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    buildUnderlineTextField(
                        label: 'Reason for sell:',
                        hintText: '',
                        textEditingController: reasonForSellController),
                    const SizedBox(height: 20),
                    buildUnderlineTextField(
                        label: 'Selling price:',
                        hintText: '',
                        textEditingController: sellingPriceController),
                    const SizedBox(height: 20),
                    buildTextField(
                        label: 'Phone number:',
                        hintText: '',
                        errorText: "This field is required",
                        textEditingController: phoneNumberController,
                        onEditingComplete: () {}),
                    const SizedBox(height: 20),
                    buildTextField(
                        label: 'Email ID:',
                        hintText: '',
                        errorText: "This field is required",
                        textEditingController: emailIdController,
                        onEditingComplete: () {}),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (sellformTwoKey.currentState?.validate() ??
                              false) {
                            formController.saveFormTwoData(saveFormTwoData());
                            formController.instantiateCreateProduct(context);
                            Get.toNamed(GetRoutes.sellProductsConfirmationPage);
                          } else {
                            showSnackBar(
                                content: 'Please fill all the fields',
                                context: context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffFF8D41),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sell now',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontFamily: "MontserratSB"),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> saveFormTwoData() {
    Map<String, dynamic> formTwoData = {};

    // Time held
    if (!isLessThanMonth) {
      formTwoData['timeHeldYears'] = int.tryParse(yearsController.text) ?? 0;
      formTwoData['timeHeldMonths'] = int.tryParse(monthsController.text) ?? 0;
    } else {
      formTwoData['timeHeldMonths'] = 1; // Less than a month
    }

    // Required fields
    formTwoData['reasonForSell'] = reasonForSellController.text.trim();
    formTwoData['sellingPrice'] =
        double.tryParse(sellingPriceController.text) ?? 0.0;
    formTwoData['phone'] = phoneNumberController.text.trim();
    formTwoData['email'] = emailIdController.text.trim();

    print('Form Two Data: $formTwoData');
    return formTwoData;
  }
}
