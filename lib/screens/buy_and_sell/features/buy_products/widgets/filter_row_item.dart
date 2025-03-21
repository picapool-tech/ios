import 'package:flutter/material.dart';
import 'package:picapool/screens/buy_and_sell/values/filter_data.dart';
import 'package:picapool/utils/theme.dart';

class FilterRowItem extends StatelessWidget {
  final FilterDataEnum filterData;
  final bool isSelected;
  final bool isFirst;
  final void Function(FilterDataEnum selected)? onClick;
  const FilterRowItem({
    super.key,
    required this.filterData,
    this.isSelected = true,
    required this.onClick,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onClick?.call(filterData),
      child: Container(
        decoration: roundedContainer(radius: 6).copyWith(
          color: isSelected
              ? AppTheme.currentTheme.colorScheme.secondary
              : AppTheme.currentTheme.scaffoldBackgroundColor,
        ),
        margin: EdgeInsets.only(left: isFirst ? 15 : 0, right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "${filterData.assetImage}${filterData.title.toLowerCase()}.png",
              width: 40,
              height: 40,
              fit: BoxFit.fitHeight,
            ),
            const SizedBox(
              width: 4,
            ),
            Text(
              filterData.title,
              style: TextStyle(
                color: isSelected
                    ? AppTheme.currentTheme.colorScheme.onSecondary
                    : null,
              ),
            )
          ],
        ),
      ),
    );
  }
}
