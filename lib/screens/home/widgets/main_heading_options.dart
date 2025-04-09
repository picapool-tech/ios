import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/models/main_heading_options_data.dart';
import 'package:picapool/utils/theme.dart';

class MainHeadingOptionsWidget extends StatelessWidget {
  final MainHeadingOptionsData mainHeadingOptionData;
  final bool smallIcon;
  const MainHeadingOptionsWidget({
    super.key,
    required this.mainHeadingOptionData,
    this.smallIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return GestureDetector(
      onTap: (!mainHeadingOptionData.isDisabled)
          ? () {
              Get.toNamed(mainHeadingOptionData.routePath);
            }
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: roundedContainer().copyWith(
              color: Colors.transparent,
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.asset(
              // "assets/images/share_cab.png",
              mainHeadingOptionData.imagePath,
              width: smallIcon ? size.width * 0.2 : size.width * 0.26,
              color: (mainHeadingOptionData.isDisabled) ? Colors.white : null,
              colorBlendMode: BlendMode.color,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            mainHeadingOptionData.text,
            style: Theme.of(context).textTheme.labelSmall,
            // "Share a cab",
          )
        ],
      ),
    );
  }
}
