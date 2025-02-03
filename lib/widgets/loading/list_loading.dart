import 'package:flutter/material.dart';
import 'package:picapool/core/shimmer.dart';

class ListLoading extends StatelessWidget {
  final Widget child;
  final int count;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  const ListLoading({
    super.key,
    required this.child,
    required this.count,
    this.shrinkWrap = false,
    this.physics = const AlwaysScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.1),
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      highlightColor: Colors.grey[50]!,
      direction: ShimmerDirection.ttb,
      child: ListView.separated(
        shrinkWrap: shrinkWrap,
        physics: physics,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemCount: count,
        itemBuilder: (context, index) {
          return child;
        },
      ),
    );
  }
}
