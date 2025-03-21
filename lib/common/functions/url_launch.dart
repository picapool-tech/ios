import 'package:flutter/material.dart';
import 'package:picapool/core/core.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

FutureVoid launchUrl(String url) async {
  if (!await launcher.launchUrl(Uri.parse(url))) {
    debugPrint("$url cannot be launched");
  }
}
