import 'package:flutter/material.dart';
import 'package:picapool/widgets/loading/circle_loading.dart';

class CircleListLoading extends StatelessWidget {
  final Axis direction;
  final int count;
  final Widget? additionalChild;
  const CircleListLoading({
    super.key,
    this.direction = Axis.horizontal,
    this.count = 5,
    this.additionalChild,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: CircleLoading(
            child: additionalChild,
          ),
        );
      }),
    );
  }
}
