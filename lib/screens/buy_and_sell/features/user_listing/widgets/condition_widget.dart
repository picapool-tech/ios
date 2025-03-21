import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:picapool/screens/buy_and_sell/values/product_condition_class.dart';
import 'package:picapool/utils/theme.dart';

class ProductContiditonWidget extends StatefulWidget {
  final List<ProductCondition> conditions;
  final void Function(ProductCondition) onSelected;
  final String Function(ProductCondition) displayNameGetter;
  final String? Function(ProductCondition)? assetLocationGetter;
  final CrossAxisAlignment crossAxisAlignment;
  final ProductCondition? initialValue;
  const ProductContiditonWidget({
    super.key,
    required this.conditions,
    required this.onSelected,
    required this.displayNameGetter,
    this.initialValue,
    this.assetLocationGetter,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  State<ProductContiditonWidget> createState() =>
      _ProductContiditonWidgetState();
}

class _ProductContiditonWidgetState<T extends Enum>
    extends State<ProductContiditonWidget> {
  ProductCondition? _selectedCondition;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widget.conditions.map((condition) {
        final String displayName = widget.displayNameGetter(condition);
        final String? assetLocation =
            widget.assetLocationGetter?.call(condition);
        return Expanded(
          child: ChoiceChip(
            label: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (assetLocation != null) ...[
                  SvgPicture.asset(
                    height: 50,
                    assetLocation,
                    colorFilter: isSelected(condition)
                        ? ColorFilter.mode(
                            AppTheme.currentTheme.colorScheme.onSurface,
                            BlendMode.dstIn,
                          )
                        : null,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
                FittedBox(
                  child: Text(
                    displayName,
                    style: TextStyle(
                      color: isSelected(condition)
                          ? AppTheme.currentTheme.colorScheme.onSecondary
                          : AppTheme.currentTheme.colorScheme.onSurface,
                      fontWeight: isSelected(condition)
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            selected: isSelected(condition),
            backgroundColor: AppTheme.currentTheme.scaffoldBackgroundColor,
            selectedColor: AppTheme.currentTheme.colorScheme.onPrimary,
            side: BorderSide(
              color: isSelected(condition)
                  ? AppTheme.currentTheme.colorScheme.secondary
                  : AppTheme.currentTheme.dividerColor,
            ),
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: isSelected(condition) ? 2 : 0,
            shadowColor: AppTheme.currentTheme.shadowColor,
            showCheckmark: false,
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  isSelected(condition);
                  // Also update in the controller if needed
                  _selectedCondition = condition;
                }
              });
              widget.onSelected(condition);
            },
          ),
        );
      }).toList(),
    );
  }

  bool isSelected(ProductCondition condition) {
    if (_selectedCondition == null) {
      return false;
    }
    return _selectedCondition == condition;
  }
}
