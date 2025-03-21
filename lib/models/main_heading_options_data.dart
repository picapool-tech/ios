import 'package:flutter/material.dart';

class MainHeadingOptionsData {
  final String imagePath;
  final String text;
  final Widget destinationPage;
  final bool isDisabled;
  final bool showModelSheet;
  final void Function()? customTapAction;

  const MainHeadingOptionsData({
    required this.imagePath,
    required this.text,
    required this.destinationPage,
    this.isDisabled = false,
    this.showModelSheet = false,
    this.customTapAction,
  });
}
