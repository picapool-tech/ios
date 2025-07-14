import 'package:flutter/material.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/condition_widget.dart';
import 'package:picapool/screens/buy_and_sell/values/product_condition_class.dart';
import 'package:picapool/utils/theme.dart';

class ProductContitionFormField extends FormField<ProductCondition> {
  ProductContitionFormField({
    super.key,
    required List<ProductCondition> conditions,
    required String Function(ProductCondition) displayNameGetter,
    String? Function(ProductCondition)? assetLocationGetter,
    required super.initialValue,
    required Function(ProductCondition) onSelected,
    required super.validator,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    String? labelText,
  }) : super(
          builder: (FormFieldState<ProductCondition> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Your existing widget
                ProductContiditonWidget(
                  conditions: conditions,
                  onSelected: (ProductCondition value) {
                    state.didChange(value);
                    onSelected(value);
                  },
                  displayNameGetter: displayNameGetter,
                  assetLocationGetter: assetLocationGetter,
                  crossAxisAlignment: crossAxisAlignment,
                  initialValue:
                      state.value, // Add this parameter to your widget
                ),
                // Show error message if validation fails
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                        color: AppTheme.currentTheme.colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
}
