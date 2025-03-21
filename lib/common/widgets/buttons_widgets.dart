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

  const PicaPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isLoading,
    this.isSmall = false,
  });

  Size get getSize => const Size(320, 100);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 100,
      ),
      width: !isSmall ? double.infinity : 100,
      child: Obx(() {
        debugPrint("PRIMARY BUTTON : ${isLoading.value}");
        if (isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return FilledButton(
          onPressed: onPressed,
          style: isSmall
              ? const ButtonStyle(
                  fixedSize: WidgetStatePropertyAll(
                    Size.fromWidth(100),
                  ),
                )
              : null,
          child: FittedBox(
            child: Text(
              text,
            ),
          ),
        );
      }),
    );
  }
}

class PicaTextButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final Color? color;
  final RxBool isLoading;

  const PicaTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isLoading,
    this.color,
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
        return buttonContent(context);
      }),
    );
  }

  Widget buttonContent(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: Theme.of(context).textButtonTheme.style?.copyWith(
            foregroundColor: WidgetStatePropertyAll(
              AppTheme.currentTheme.colorScheme.onPrimary,
            ),
          ),
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.currentTheme.primaryColor,
        ),
      ),
    );
  }
}
