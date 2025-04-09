import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Standard border radius for text fields
const double kTextFieldBorderRadius = 8.0;

/// Email field with validation
class PicaEmailField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? helperText;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final double borderRadius;

  const PicaEmailField({
    Key? key,
    required this.controller,
    this.labelText = 'Email',
    this.helperText,
    this.validator,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
    this.borderRadius = kTextFieldBorderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PicaOutlinedTextField(
      controller: controller,
      labelText: labelText,
      helperText: helperText,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      prefixIcon: const Icon(Icons.email_outlined),
      // validator: validator ??
      //     (value) {
      //       if (value == null || value.isEmpty) {
      //         return 'Please enter an email address';
      //       }
      //       if (!GetUtils.isEmail(value)) {
      //         return 'Please enter a valid email address';
      //       }
      //       return null;
      //     },
      onChanged: onChanged,
    );
  }
}

/// Base outline text field with consistent styling and rounded corners
class PicaOutlinedTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final bool readOnly;
  final bool autoFocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final bool filled;
  final bool isDense;
  final BoxConstraints? constraints;
  final String? suffixText;
  final String? prefixText;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final bool enabled;
  final double borderRadius;
  final TextStyle? textStyle;

  const PicaOutlinedTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.readOnly = false,
    this.autoFocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.contentPadding,
    this.fillColor,
    this.filled = false,
    this.isDense = false,
    this.constraints,
    this.suffixText,
    this.prefixText,
    this.validator,
    this.autovalidateMode,
    this.enabled = true,
    this.textStyle,
    this.borderRadius = kTextFieldBorderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      readOnly: readOnly,
      autofocus: autoFocus,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onTap: onTap,
      validator: validator,
      enabled: enabled,
      autovalidateMode: autovalidateMode,
      cursorColor: primaryColor,
      style: textStyle ?? theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        hintStyle: TextStyle(
          fontStyle: FontStyle.italic,
          color: theme.hintColor,
        ),
        errorText: errorText,
        isDense: isDense,
        constraints: constraints,
        filled: filled,
        fillColor: fillColor ??
            theme.inputDecorationTheme.fillColor ??
            theme.colorScheme.surfaceTint.withOpacity(0.1),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        suffixText: suffixText,
        prefixText: prefixText,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ), // Adjusted vertical padding
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide:
              BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
      ),
      onTapOutside: (value) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}

/// Password field with toggle visibility button
class PicaPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;

  const PicaPasswordField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.validator,
  }) : super(key: key);

  @override
  State<PicaPasswordField> createState() => _PicaPasswordFieldState();
}

/// Phone number field with formatting
class PicaPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? helperText;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Widget? suffixIcon;
  final bool enabled;

  const PicaPhoneField({
    Key? key,
    required this.controller,
    this.labelText = 'Phone Number',
    this.helperText,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PicaOutlinedTextField(
      controller: controller,
      hintText: labelText,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      prefixIcon: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("+91"),
        ],
      ),

      // Icon(
      //   Icons.local_phone_rounded,
      //   color: AppTheme.currentTheme.primaryColor,
      // ),
      enabled: enabled,
      suffixIcon: suffixIcon,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      // validator: validator,
      onChanged: onChanged,
    );
  }
}

/// Search field with search icon and clear button
class PicaSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final VoidCallback? onSubmitted;
  final Color? fillColor;
  final bool? filled;

  final RxBool value = false.obs;

  PicaSearchField({
    Key? key,
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.fillColor,
    this.onSubmitted,
    this.filled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PicaOutlinedTextField(
      controller: controller,
      hintText: hintText,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onChanged: (stringValue) {
        value.value = controller.text.isNotEmpty;
        onChanged?.call(stringValue);
      },
      onSubmitted: (_) => onSubmitted?.call(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      fillColor: fillColor,
      isDense: true,
      constraints: const BoxConstraints(maxHeight: 45),
      filled: filled ?? false,
      prefixIcon: const Icon(
        Icons.search_rounded,
      ),
      suffixIcon: Obx(
        () {
          if (value.value) {
            return IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller.clear();
                if (onChanged != null) {
                  onChanged!('');
                }
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _PicaPasswordFieldState extends State<PicaPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return PicaOutlinedTextField(
      controller: widget.controller,
      labelText: widget.labelText ?? 'Password',
      hintText: widget.hintText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      obscureText: _obscureText,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      // validator: widget.validator,
      keyboardType: TextInputType.visiblePassword,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}
