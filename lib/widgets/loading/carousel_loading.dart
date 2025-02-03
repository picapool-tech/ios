import 'package:flutter/material.dart';
import 'package:picapool/core/shimmer.dart';
import 'package:picapool/utils/theme.dart';

class CarouselLoading extends StatelessWidget {
  const CarouselLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.1),
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      highlightColor: Colors.grey[50]!,
      direction: ShimmerDirection.ltr,
      child: Column(children: [
        Container(
          width: double.infinity,
          height: 120,
          decoration: roundedContainer().copyWith(
            color: Colors.grey[200],
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
          width: double.infinity,
          height: 50,
          decoration: roundedContainer(radius: 8).copyWith(
            color: Colors.grey[200],
          ),
        ),
      ]),
    );
  }
}
