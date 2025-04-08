import 'package:flutter/material.dart';

class MainHeadingOptionsData {
  final String imagePath;
  final String text;
  final String routePath;
  final bool isDisabled;
  final bool showModelSheet;
  final void Function()? customTapAction;

  const MainHeadingOptionsData({
    required this.imagePath,
    required this.text,
    required this.routePath,
    this.isDisabled = false,
    this.showModelSheet = false,
    this.customTapAction,
  });
}
