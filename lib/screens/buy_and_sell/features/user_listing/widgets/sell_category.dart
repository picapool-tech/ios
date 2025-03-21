import 'package:flutter/material.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/sell_category_list_item.dart';
import 'package:picapool/screens/buy_and_sell/values/filter_data.dart';

class SellCategory extends StatelessWidget {
  const SellCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: FilterDataEnum
          .values.length, // Example count, replace with your actual data length
      itemBuilder: (context, index) {
        FilterDataEnum data = FilterDataEnum.values[index];
        return SellCategoryListItem(
          filterData: data,
        );
      },
    );
  }
}
