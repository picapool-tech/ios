import 'package:flutter/material.dart';
import 'package:picapool/core/shimmer.dart';
import 'package:picapool/utils/theme.dart';

class ImageLoading extends StatelessWidget {
  final double? height;
  final double? width;
  const ImageLoading({
    super.key,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.1),
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      highlightColor: Colors.grey[50]!,
      direction: ShimmerDirection.ltr,
      child: Container(
        decoration: roundedContainer().copyWith(
          color: Colors.grey[300],
        ),
        width: width ?? double.infinity,
        height: height ?? 150,
      ),
    );
  }
}
