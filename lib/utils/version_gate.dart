import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> runVersionGate(BuildContext context) async {
  final rc = FirebaseRemoteConfig.instance;

  await rc.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 10),
    //minimumFetchInterval: Duration.zero, //Only use it for Testing
    minimumFetchInterval: const Duration(hours: 12),
  ));
  await rc.fetchAndActivate();

  final info = await PackageInfo.fromPlatform();
  final version = info.version;
  final updateType = rc.getString('new_update_type');
  final changelog = rc.getString('changelog');
  final url = Platform.isIOS
      ? rc.getString('store_url_ios')
      : rc.getString('store_url_android');

  // Print for debugging
  print("🧾 App Version: $version");
  print("🧾 Update Type: $updateType");
  print("🧾 Changelog: $changelog");
  print("🧾 Store URL: $url");

  if (updateType == 'force' || updateType == 'soft') {
    showDialog(
      context: context,
      barrierDismissible: updateType != 'force',
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(
                  Icons.update,
                  size: 48,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Update Available',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'What’s new:',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                changelog.replaceAll(r'\n', '\n'),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: updateType == 'soft'
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                children: [
                  if (updateType == 'soft')
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'SKIP',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Text(
                      'UPDATE NOW',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
