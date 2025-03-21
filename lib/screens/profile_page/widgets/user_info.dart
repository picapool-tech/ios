import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/functions/model_bottom_sheet_caller.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/screens/profile_page/functions/edit_profile/edit_profile.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return GetBuilder<StorageController>(
      init: Get.find<StorageController>(),
      builder: (controller) {
        var user = controller.user.value!;
        var auth = controller.auth.value!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile image
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade300,
                foregroundImage: (user.pic != null)
                    ? CachedNetworkImageProvider(
                        user.pic!,
                        errorListener: (p0) {},
                      )
                    : const AssetImage(
                        'assets/icons/Frame 64.png', // Replace with your image
                        // width: 100,
                        // height: 100,
                      ) as ImageProvider,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      child: Text(
                        user.name ?? "",
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "@${user.username ?? "nousername"}",
                      style: textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      auth.mobile ?? "",
                      style: textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            _showEditProfileModelSheet(context);
                          },
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/icons/Frame 153.png",
                                height: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Edit Profile",
                                style: TextStyle(
                                  fontFamily: "MontserratM",
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileModelSheet(BuildContext context) {
    showPicaModelBottomSheet(
      context: context,
      hideDragHandle: true,
      child: const EditProfile(),
    );
  }
}
