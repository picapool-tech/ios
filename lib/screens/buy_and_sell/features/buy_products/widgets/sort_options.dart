import 'package:flutter/material.dart';
import 'package:picapool/screens/buy_and_sell/values/enums.dart';
import 'package:picapool/utils/theme.dart';

class ProductSortOptions extends StatelessWidget {
  final Function(SortOption)? onSortSelected;
  final SortOption? currentSort;
  final Function()? removeSort;
  const ProductSortOptions({
    super.key,
    this.onSortSelected,
    this.currentSort,
    this.removeSort,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Sort products by',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.currentTheme.primaryColor,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  removeSort?.call();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        const Divider(),
        ...SortOption.values.map(
          (option) => ListTile(
            leading: Icon(
              _getIconForSortOption(option),
              color: currentSort == option ? Colors.orange : Colors.grey,
            ),
            title: Text(
              option.label,
              style: TextStyle(
                color: currentSort == option ? Colors.orange : Colors.black,
                fontWeight:
                    currentSort == option ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: () {
              if (onSortSelected != null) {
                onSortSelected!(option);
              }
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  IconData _getIconForSortOption(SortOption option) {
    switch (option) {
      case SortOption.newestFirst:
        return Icons.calendar_today;
      case SortOption.oldestFirst:
        return Icons.history;
      case SortOption.priceHighToLow:
        return Icons.trending_down;
      case SortOption.priceLowToHigh:
        return Icons.trending_up;
    }
  }
}
