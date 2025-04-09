import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

Color getColorFromString(String username) {
  List<int> hash = md5.convert(utf8.encode(username)).bytes;

  int hue = ((hash[0] | (hash[1] << 8)) % 360); // 0-359 degrees
  double saturation = 0.9; // vivid!
  double value = 0.9; // bright!

  return HSVColor.fromAHSV(1.0, hue.toDouble(), saturation, value).toColor();
}
