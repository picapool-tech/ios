import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

SystemUiOverlayStyle uiOverlayStyle(
  BuildContext context, {
  Brightness? brightness,
}) {
  brightness ??= Theme.of(context).brightness;
  debugPrint(brightness.name);

  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness:
        brightness == Brightness.dark ? Brightness.light : Brightness.dark,
    statusBarBrightness:
        brightness == Brightness.dark ? Brightness.dark : Brightness.light,
    systemNavigationBarColor: Colors.transparent,
  );
}

final class PicaValues {
  static const double smallSpacing = 8;
  static const double mediumSpacing = 10;
  static const double largeSpacing = 20;
}
