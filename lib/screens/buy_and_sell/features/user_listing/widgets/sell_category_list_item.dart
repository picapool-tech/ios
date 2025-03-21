import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/screens/buy_and_sell/values/filter_data.dart';
import 'package:picapool/utils/theme.dart';

class SellCategoryListItem extends StatelessWidget {
  final FilterDataEnum filterData;

  const SellCategoryListItem({super.key, required this.filterData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          filterData.destination,
        );
      },
      child: Container(
        decoration: roundedContainer().copyWith(
          color: AppTheme.currentTheme.scaffoldBackgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "${filterData.assetImage}${filterData.title.toLowerCase()}.png",
              height: 50,
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              filterData.title,
              style: Get.textTheme.bodySmall,
            )
          ],
        ),
      ),
    );
  }
}
