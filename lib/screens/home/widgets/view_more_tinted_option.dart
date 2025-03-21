import 'package:flutter/material.dart';
import 'package:picapool/utils/theme.dart';

class ViewMoreTintedOption extends StatelessWidget {
  final void Function() onPressed;

  const ViewMoreTintedOption({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(21),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.currentTheme.highlightColor,
          borderRadius: BorderRadius.circular(21),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "View more",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.currentTheme.primaryColor,
                    ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_drop_down_circle,
                size: 16,
                color: AppTheme.currentTheme.primaryColor,
              )
            ],
          ),
        ),
      ),
    );
  }
}
