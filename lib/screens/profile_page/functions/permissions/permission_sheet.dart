import 'package:flutter/material.dart';
import 'package:picapool/screens/profile_page/widgets/permission_options_widget.dart';
import 'package:picapool/utils/permission_util.dart';
import 'package:picapool/utils/theme.dart';

class PermissionSheet extends StatefulWidget {
  const PermissionSheet({super.key});

  @override
  State<PermissionSheet> createState() => _PermissionSheetState();
}

class _PermissionSheetState extends State<PermissionSheet> {
  late PermissionUtil permissionUtil;

  late Future<bool> locationEnabled;
  late Future<bool> notificationEnabled;
  late Future<bool> galleryEnabled;
  late Future<bool> cameraEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Edit your Preferences!",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          "Enable or Disable your settings",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.currentTheme.colorScheme.primaryContainer
                .withOpacity(0.2),
            border: Border.all(color: Colors.orange, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              FutureBuilder<bool>(
                  future: locationEnabled,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return InkWell(
                        onTap: () async {
                          if (snapshot.data ?? false) {
                            return;
                          } else {
                            await permissionUtil.requestLocationPermission();
                            locationEnabled =
                                permissionUtil.isLocationPermissionGranted();
                            setState(() {});
                          }
                        },
                        child: PermissionOptionsWidget(
                          icon: Icons.location_on,
                          title: "Location Access",
                          isEnabled: snapshot.data!,
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  }),
              const Divider(thickness: 1.5),
              FutureBuilder<bool>(
                  future: notificationEnabled,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return InkWell(
                        onTap: () async {
                          if (snapshot.data ?? false) {
                            return;
                          } else {
                            await permissionUtil
                                .requestNotificationPermission();
                            locationEnabled = permissionUtil
                                .isNotificationPermissionGranted();
                            setState(() {});
                          }
                        },
                        child: PermissionOptionsWidget(
                          icon: Icons.notifications,
                          title: "Notifications",
                          isEnabled: snapshot.data!,
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  }),
              const Divider(thickness: 1.5),
              FutureBuilder<bool>(
                future: galleryEnabled,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return InkWell(
                      onTap: () async {
                        if (snapshot.data ?? false) {
                          return;
                        } else {
                          await permissionUtil.requestPhotoPermission();
                          galleryEnabled =
                              permissionUtil.isPhotoPermissionGranted();
                          setState(() {});
                        }
                      },
                      child: PermissionOptionsWidget(
                        icon: Icons.photo,
                        title: "Photos Library",
                        isEnabled: snapshot.data!,
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
              const Divider(thickness: 1.5),
              FutureBuilder<bool>(
                future: cameraEnabled,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return InkWell(
                      onTap: () async {
                        if (snapshot.data ?? false) {
                          return;
                        } else {
                          await permissionUtil.requestCameraPermission();
                          cameraEnabled =
                              permissionUtil.isCameraPermissionGranted();
                          setState(() {});
                        }
                      },
                      child: PermissionOptionsWidget(
                        icon: Icons.camera,
                        title: "Camera",
                        isEnabled: snapshot.data!,
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    permissionUtil = PermissionUtil();

    locationEnabled = permissionUtil.isLocationPermissionGranted();
    notificationEnabled = permissionUtil.isNotificationPermissionGranted();
    galleryEnabled = permissionUtil.isPhotoPermissionGranted();
    cameraEnabled = permissionUtil.isCameraPermissionGranted();
  }
}
