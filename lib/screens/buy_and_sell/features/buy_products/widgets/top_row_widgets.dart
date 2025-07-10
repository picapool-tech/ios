import 'package:flutter/material.dart';
import 'package:picapool/common/functions/model_bottom_sheet_caller.dart';
import 'package:picapool/common/widgets/text_field_widgets.dart';
import 'package:picapool/screens/buy_and_sell/features/buy_products/widgets/sort_options.dart';
import 'package:picapool/screens/buy_and_sell/values/enums.dart';
import 'package:picapool/utils/theme.dart';
import 'package:pull_down_button/pull_down_button.dart';

class TopRowWidgets extends StatelessWidget {
  final TextEditingController searchController;
  final Function(SortOption)? onSortSelected;
  final SortOption? currentSort;
  final Function()? removeSort;

  const TopRowWidgets({
    super.key,
    required this.searchController,
    this.onSortSelected,
    this.currentSort,
    this.removeSort,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PicaSearchField(
            controller: searchController,
            filled: true,
            showBorder: false,
            fillColor: AppTheme.currentTheme.scaffoldBackgroundColor,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        PullDownButton(
          routeTheme: PullDownMenuRouteTheme(
            backgroundColor: AppTheme.currentTheme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          itemBuilder: (context) => [
            PullDownMenuTitle(
              title: Row(
                children: [
                  Text("Sort by"),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (removeSort != null) {
                        removeSort!();
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Clear",
                      style: TextStyle(
                        color: AppTheme.currentTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...SortOption.values.map(
              (option) => PullDownMenuItem.selectable(
                selected: currentSort == option,
                title: option.label,
                icon: _getIconForSortOption(option),
                onTap: () {
                  if (onSortSelected != null) {
                    onSortSelected!(option);
                  }
                },
              ),
            ),
          ],
          buttonBuilder: (context, showMenu) => IconButton.filled(
            padding: const EdgeInsets.all(10),
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: (currentSort != null)
                      ? BorderSide(
                          color: AppTheme.currentTheme.primaryColor,
                        )
                      : BorderSide.none,
                ),
              ),
              backgroundColor: WidgetStatePropertyAll(
                AppTheme.currentTheme.scaffoldBackgroundColor,
              ),
            ),
            onPressed: showMenu,
            icon: Icon(
              Icons.sort,
              color: (currentSort != null)
                  ? AppTheme.currentTheme.primaryColor
                  : null,
            ),
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

  void _showSortingOption(BuildContext context) {
    showPicaModelBottomSheet(
      context: context,
      child: ProductSortOptions(
        onSortSelected: onSortSelected,
        currentSort: currentSort,
        removeSort: removeSort,
      ),
    );
  }
}
