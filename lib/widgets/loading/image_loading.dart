import 'package:flutter/material.dart';
import 'package:picapool/core/shimmer.dart';
import 'package:picapool/utils/theme.dart';

class ImageLoading extends StatelessWidget {
  const ImageLoading({super.key});

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
        width: double.infinity,
        height: 150,
      ),
    );
  }
}
