import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TileButton extends StatelessWidget {
  final String title;
  final String? imagePath;
  final IconData? icon;
  final void Function() onTap;
  final bool isDisabled;
  final bool isLast;

  const TileButton({
    super.key,
    required this.title,
    this.imagePath,
    this.icon,
    required this.onTap,
    this.isDisabled = false,
    this.isLast = false,
  }) : assert(imagePath != null || icon != null,
            'Either imagePath or icon must be provided');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          leading: imagePath != null
              ? Image.asset(
                  imagePath!, // Use the provided image path
                  width: 28, // Adjust the size as needed
                  height: 28,
                  color: (isDisabled) ? Colors.grey : null,
                )
              : Icon(
                  icon,
                  color: (isDisabled) ? Colors.grey : Get.theme.primaryColor,

                  size: 28, // Adjust the size as needed
                ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: (isDisabled) ? Colors.grey : null,
                ),
          ),
          onTap: (!isDisabled) ? onTap : null,
        ),
        if (!isLast)
          const Divider(
            color: Colors.grey, // Grey color divider
            thickness: 0.5,
            height: 1,
          )
      ],
    );
  }
}
