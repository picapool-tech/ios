import 'package:flutter/material.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/models/main_heading_options_data.dart';
import 'package:picapool/screens/home/values/main_heading_options.dart';
import 'package:picapool/screens/home/widgets/main_heading_options.dart';

class PoolingCategoriesList extends StatelessWidget {
  final List<MainHeadingOptionsData> poolingCategories;

  const PoolingCategoriesList(
      {super.key,
      this.poolingCategories = MainHeadingOptions.poolingCategories});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (index) {
            return MainHeadingOptionsWidget(
              mainHeadingOptionData: poolingCategories[index],
              smallIcon: true,
            );
          }),
        ),
        const SizedBox(
          height: PicaValues.largeSpacing,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (index) {
            return MainHeadingOptionsWidget(
              mainHeadingOptionData: poolingCategories[index + 3],
              smallIcon: true,
            );
          }),
        ),
      ],
    );
  }
}
