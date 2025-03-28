import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/features/auth/auth_controller.dart';

class LogoutWidget extends StatelessWidget {
  const LogoutWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Log out!",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            "Do you really want to log out of your account?",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 20),
          // Log Out Button
          PicaPrimaryButton(
            onPressed: () async {
              await Get.find<AuthController>().logout();

              if (context.mounted) {
                Get.back();
              }
            },
            text: "Log Out",
            isLoading: false.obs,
          ),
          // Go Back Button
          PicaOutlineButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            text: "Go Back",
            isLoading: false.obs,
          ),
        ],
      ),
    );
  }
}
