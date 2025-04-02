import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/screens/buy_and_sell/features/buy_products/widgets/floating_top_widgets.dart';
import 'package:picapool/utils/theme.dart';

class ImageWithTopWidgets extends StatelessWidget {
  static const Radius _radius = Radius.circular(15);

  final String? imageUrl;
  final String timeSinceAgo;

  final bool isSold;

  const ImageWithTopWidgets({
    super.key,
    this.imageUrl,
    required this.timeSinceAgo,
    required this.isSold,
  });

  @override
  Widget build(BuildContext context) {
    // container here is necessary as it binds the image from overflowing its parent widget
    // ignore: avoid_unnecessary_containers
    return Container(
      decoration: roundedContainer(),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          if (imageUrl == null)
            Image.asset(
              "assets/images/buy_and_sell/no_image.png",
              width: double.infinity,
              height: 100,
              fit: BoxFit.cover,
            )
          else
            CachedNetworkImage(
              imageUrl: imageUrl!,
              width: double.infinity,
              height: MediaQuery.sizeOf(context).width * 0.3,
              fit: BoxFit.cover,
              color: isSold ? Colors.grey : null,
              colorBlendMode: isSold ? BlendMode.color : null,
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingTopWidgets(
                child: Text(
                  timeSinceAgo,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              if (isSold)
                FloatingTopWidgets(
                  direction: FloatingTopWidgetDirection.right,
                  child: Text(
                    "SOLD",
                    style: Get.textTheme.labelSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
