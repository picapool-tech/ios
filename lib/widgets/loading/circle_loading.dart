import 'package:flutter/material.dart';
import 'package:picapool/core/shimmer.dart';

class CircleLoading extends StatelessWidget {
  final Widget? child;

  const CircleLoading({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.1),
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      highlightColor: Colors.grey[50]!,
      direction: ShimmerDirection.ttb,
      child: Column(
        children: [
          const CircleAvatar(
            radius: 25,
          ),
          const SizedBox(
            height: 8,
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
