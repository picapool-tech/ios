import 'dart:io';

class Env {
  static final Map<String, String> _env = {};

  static Future<void> load() async {
    final file = File('.env');
    if (await file.exists()) {
      final lines = await file.readAsLines();
      for (var line in lines) {
        if (line.trim().isEmpty || line.startsWith('#')) continue;
        final parts = line.split('=');
        if (parts.length == 2) {
          final key = parts[0].trim();
          final value = parts[1].trim().replaceAll('"', '');
          _env[key] = value;
        }
      }
    }
  }

  static String get(String key) {
    return _env[key]!;
  }
}
