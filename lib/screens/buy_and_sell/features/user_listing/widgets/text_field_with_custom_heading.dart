import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:picapool/common/widgets/text_field_widgets.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/widget_with_custom_heading.dart';

class TextFieldWithCustomHeading extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String hintText;
  final int? maxlines;
  final int? maxWordLength;
  final bool isNumber;
  final bool isCurrency;
  final bool showNumberFormatting;
  final String? errorText;
  final String? suffixText;
  final String? Function(String?)? validator;

  const TextFieldWithCustomHeading({
    super.key,
    required this.title,
    required this.controller,
    required this.hintText,
    this.maxlines,
    this.maxWordLength,
    this.isNumber = false,
    this.isCurrency = false,
    this.showNumberFormatting = true,
    this.errorText,
    this.validator,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    return WidgetWithCustomHeading(
      title: title,
      child: PicaOutlinedTextField(
        controller: controller,
        hintText: hintText,
        maxLines: maxlines,
        maxLength: maxWordLength,
        errorText: errorText,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : null,
        inputFormatters:
            (isNumber && isCurrency) ? _buildInputFormatters() : null,
        prefixText: (isNumber && isCurrency) ? "₹" : null,
        suffixText: suffixText,
        onChanged:
            (isNumber && showNumberFormatting) ? _formatIndianCurrency : null,
        validator: validator,
      ),
    );
  }

  List<TextInputFormatter> _buildInputFormatters() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      TextInputFormatter.withFunction((oldValue, newValue) {
        // Prevent multiple decimal points
        if (newValue.text.isEmpty) return newValue;
        if (newValue.text.contains('.')) {
          if (newValue.text.indexOf('.') != newValue.text.lastIndexOf('.')) {
            return oldValue;
          }
          // Limit to 2 decimal places
          final parts = newValue.text.split('.');
          if (parts.length > 1 && parts[1].length > 2) {
            return oldValue;
          }
        }
        return newValue;
      }),
    ];
  }

  void _formatIndianCurrency(String value) {
    if (value.isEmpty) return;

    // Remove any existing formatting (₹ and commas)
    String plainNumber = value.replaceAll('₹', '').replaceAll(',', '');

    // Don't format if the field is being edited at the decimal point
    if (plainNumber.endsWith('.')) return;

    try {
      // Parse the number and format with Indian currency style
      final number = double.parse(plainNumber);
      final formatter = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '', // No symbol as we add it as prefix
        decimalDigits: plainNumber.contains('.') ? 2 : 0,
      );

      String formatted = formatter.format(number);

      // Update the controller without triggering onChanged again
      if (value != formatted) {
        final selection = controller.selection;
        controller.text = formatted;
        // Maintain cursor position relative to the end
        final newPosition =
            formatted.length - (value.length - selection.baseOffset);
        controller.selection = TextSelection.collapsed(
            offset: newPosition > 0 ? newPosition : formatted.length);
      }
    } catch (e) {
      // If parsing fails, leave the input as is
    }
  }
}
