import 'package:flutter/material.dart';
import 'package:picapool/utils/colors.dart';

extension ColorLightDark on Color {
  Color darker([double amount = 0.4]) => darken(this, amount);
  Color lighter([double amount = 0.4]) => lighten(this, amount);
}
