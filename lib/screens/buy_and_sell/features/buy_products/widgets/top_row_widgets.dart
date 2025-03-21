import 'package:flutter/material.dart';
import 'package:picapool/common/functions/model_bottom_sheet_caller.dart';
import 'package:picapool/common/widgets/text_field_widgets.dart';
import 'package:picapool/screens/buy_and_sell/features/buy_products/widgets/sort_options.dart';
import 'package:picapool/screens/buy_and_sell/values/enums.dart';
import 'package:picapool/utils/theme.dart';

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
            fillColor: AppTheme.currentTheme.scaffoldBackgroundColor,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        const SizedBox(
          width: 4,
        ),
        IconButton.filled(
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
          onPressed: () => _showSortingOption(context),
          icon: Icon(
            Icons.sort,
            color: (currentSort != null)
                ? AppTheme.currentTheme.primaryColor
                : null,
          ),
        )
      ],
    );
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
