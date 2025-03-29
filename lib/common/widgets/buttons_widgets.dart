import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/utils/theme.dart';

class PicaOutlineButton extends StatelessWidget {
  final String text;
  final Widget? icon;
  final void Function()? onPressed;
  final RxBool isLoading;

  const PicaOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: double.infinity,
      child: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return OutlinedButton.icon(
          icon: icon,
          onPressed: onPressed,
          label: Text(text),
        );
      }),
    );
  }
}

class PicaPrimaryButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final RxBool isLoading;
  final bool isSmall;
  final Color? color;
  final Widget? icon; // Add icon parameter
  final EdgeInsetsGeometry? padding; // Add padding option for more flexibility

  const PicaPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isLoading,
    this.isSmall = false,
    this.color,
    this.icon, // New parameter
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final String uniqueId = 'button_${text.hashCode}';
    return Obx(() {
      if (isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return FilledButton.icon(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: color != null ? WidgetStatePropertyAll(color) : null,
          padding: padding != null ? WidgetStatePropertyAll(padding) : null,
        ),
        label: Text(text),
        icon: icon,
      );
    });
  }
}

class PicaTextButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final Color? color;
  final RxBool isLoading;
  final Widget? icon; // Add icon parameter
  final bool iconAfterText; // Add option to place icon after text
  final EdgeInsetsGeometry? padding;

  const PicaTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isLoading,
    this.color,
    this.icon, // New parameter
    this.iconAfterText = false, // Default: icon before text
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      child: Obx(() {
        if (isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return TextButton.icon(
          onPressed: onPressed,
          style: Theme.of(context).textButtonTheme.style?.copyWith(
              foregroundColor: WidgetStatePropertyAll(
                AppTheme.currentTheme.colorScheme.onPrimary,
              ),
              padding:
                  padding != null ? WidgetStatePropertyAll(padding) : null),
          label: Text(
            text,
            style: TextStyle(
              color: AppTheme.currentTheme.primaryColor,
            ),
          ),
          icon: icon,
        );
      }),
    );
  }
}

class ReactiveButtonHelper extends GetxController {
  final RxBool _loadingState;

  ReactiveButtonHelper(this._loadingState) {
    ever(_loadingState, (_) => update());
  }

  bool getLoading() => _loadingState.value;
}
