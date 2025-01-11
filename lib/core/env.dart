import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Env {
  static final Map<String, String> _env = {};

  static Future<void> load() async {
    var file = await rootBundle.loadString(".env");
    if (file.isNotEmpty) {
      final lines = file.split('\n');
      for (var line in lines) {
        if (line.trim().isEmpty || line.startsWith('#')) continue;
        final parts = line.split('=');
        if (parts.length == 2) {
          final key = parts[0].trim();
          final value = parts[1].trim().replaceAll('"', '');
          debugPrint("Loaded $key=$value");
          _env[key] = value;
        }
      }
    } else {
      debugPrint("No .env file found");
    }
  }

  static String get(String key) {
    return _env[key]!;
  }
}
