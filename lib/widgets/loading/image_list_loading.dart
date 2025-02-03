import 'package:flutter/material.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/loading/list_loading.dart';

class ImageListLoading extends StatelessWidget {
  final int count;
  final Axis direction;
  const ImageListLoading({
    super.key,
    this.count = 5,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return ListLoading(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      count: count,
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
