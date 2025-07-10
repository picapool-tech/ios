import 'package:flutter/material.dart';
import 'package:picapool/models/main_heading_options_data.dart';
import 'package:picapool/screens/home/values/main_heading_options.dart';
import 'package:picapool/screens/home/widgets/main_heading_options.dart';

class PoolingCategoriesList extends StatelessWidget {
  final List<MainHeadingOptionsData>? poolingCategories;

  const PoolingCategoriesList({super.key, this.poolingCategories});

  @override
  Widget build(BuildContext context) {
    final poolingCategoriesItems =
        poolingCategories ?? MainHeadingOptions.poolingCategories;
    return Column(
      spacing: 12,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 12,
          children: List.generate(2, (index) {
            return Expanded(
              child: MainHeadingOptionsHorizontalWidget(
                mainHeadingOptionData: poolingCategoriesItems[index],
                smallIcon: true,
              ),
            );
          }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 12,
          children: List.generate(2, (index) {
            return Expanded(
              child: MainHeadingOptionsHorizontalWidget(
                mainHeadingOptionData: poolingCategoriesItems[index + 2],
                smallIcon: true,
              ),
            );
          }),
        ),
      ],
    );
  }
}
