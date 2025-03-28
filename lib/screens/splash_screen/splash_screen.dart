import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/images/ic_launcher.png",
          width: 100,
          height: 100,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
