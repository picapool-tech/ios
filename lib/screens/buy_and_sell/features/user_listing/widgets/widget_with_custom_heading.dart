import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WidgetWithCustomHeading extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isRequired;
  const WidgetWithCustomHeading({
    super.key,
    required this.title,
    required this.child,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: title,
                style: Get.textTheme.bodyLarge,
              ),
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: Get.textTheme.bodyLarge?.copyWith(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        child,
      ],
    );
  }
}
