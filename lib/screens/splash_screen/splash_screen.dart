import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/images/ic_launcher.png",
          width: Get.width * 0.5,
          height: Get.width * 0.5,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
