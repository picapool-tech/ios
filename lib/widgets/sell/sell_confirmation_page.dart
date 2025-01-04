import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:picapool/controllers/sell_form_controller.dart';
import 'package:picapool/utils/routes.dart';
import 'package:picapool/widgets/primary_button.dart';

class SellConfirmationPage extends StatefulWidget {
  const SellConfirmationPage({super.key});

  @override
  State<SellConfirmationPage> createState() => _SellConfirmationPageState();
}

class _SellConfirmationPageState extends State<SellConfirmationPage> {
  FormController get formController => Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16,),
          SizedBox(
          width: MediaQuery.of(context).size.width * 0.4, 
          height: MediaQuery.of(context).size.height * 0.4, 
          child: 
          Lottie.network('https://lottie.host/62aed981-b040-478a-89f3-67a997d90ca4/ws0WCeKT2C.json'),
          ),
          const SizedBox(height: 16,),
          const Text('Your Product is listed for selling!'),
          const SizedBox(height: 16,),
          PrimaryButton(onPressed: (){
            Get.offAllNamed(GetRoutes.home);
          } , buttonLabel: 'Go to Home')
        ],)  ,
    );
  }
}