import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/loading_widgets.dart';
import 'package:picapool/utils/theme.dart';

class PicaOutlineButton extends StatelessWidget {
  final String text;
  final Widget? icon;
  final void Function()? onPressed;
  final RxBool isLoading;
  final bool isSmall;

  const PicaOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    required this.isLoading,
    this.isSmall = false, // Default: not small
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return OutlinedButton.icon(
        icon: icon,
        onPressed: () {
          if (onPressed == null) {
            return;
          }
          HapticFeedback.lightImpact();
          onPressed?.call();
        },
        label: Text(text),
        style: ButtonStyle(
          fixedSize: !isSmall
              ? WidgetStatePropertyAll(
                  Size(Get.size.width, 48.0),
                )
              : null,
        ),
      );
    });
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
    return Obx(() {
      return AnimatedSwitcher(
        duration: Durations.short4,
        // switchInCurve: Curves.elasticIn,
        // switchOutCurve: Curves.elasticOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            // fixedCrossAxisSizeFactor: 0.8,
            child: child,
          );
        },
        child: isLoading.value
            ? const Center(
                key: ValueKey('loading_indicator'),
                child: StaggeredDotsWave(
                  size: kTextTabBarHeight * 0.8,
                  color: Colors.orange,
                ),
              )
            : FilledButton.icon(
                key: ValueKey('primary_button'),
                onPressed: () {
                  if (onPressed == null) {
                    return;
                  }
                  HapticFeedback.lightImpact();
                  onPressed?.call();
                },
                style: ButtonStyle(
                  fixedSize: !isSmall
                      ? WidgetStatePropertyAll(
                          Size(Get.size.width, 48.0),
                        )
                      : null,
                  backgroundColor:
                      color != null ? WidgetStatePropertyAll(color) : null,
                  padding:
                      padding != null ? WidgetStatePropertyAll(padding) : null,
                ),
                label: Text(text),
                icon:
                    icon ?? const SizedBox.shrink(), // Use icon or empty widget
              ),
      );

      // if (isLoading.value) {
      //   return const Center(
      //     child: CircularProgressIndicator(),
      //   );
      // }

      // return FilledButton.icon(
      //   onPressed: onPressed,
      //   style: ButtonStyle(
      //     backgroundColor: color != null ? WidgetStatePropertyAll(color) : null,
      //     padding: padding != null ? WidgetStatePropertyAll(padding) : null,
      //   ),
      //   label: Text(text),
      //   icon: icon,
      // );
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
  final bool isSmall;

  const PicaTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isLoading,
    this.color,
    this.icon, // New parameter
    this.iconAfterText = false, // Default: icon before text
    this.padding,
    this.isSmall = false, // Default: not small
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      return TextButton.icon(
        onPressed: () {
          if (onPressed == null) {
            return;
          }
          HapticFeedback.lightImpact();
          onPressed?.call();
        },
        style: Theme.of(context).textButtonTheme.style?.copyWith(
            foregroundColor: WidgetStatePropertyAll(
              AppTheme.currentTheme.colorScheme.onPrimary,
            ),
            fixedSize: !isSmall
                ? WidgetStatePropertyAll(
                    Size(Get.size.width, 48.0),
                  )
                : null,
            padding: padding != null ? WidgetStatePropertyAll(padding) : null),
        label: Text(
          text,
          style: TextStyle(
            color: AppTheme.currentTheme.primaryColor,
          ),
        ),
        icon: icon,
      );
    });
  }
}

class ReactiveButtonHelper extends GetxController {
  final RxBool _loadingState;

  ReactiveButtonHelper(this._loadingState) {
    ever(_loadingState, (_) => update());
  }

  bool getLoading() => _loadingState.value;
}
