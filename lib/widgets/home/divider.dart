import 'package:flutter/material.dart';
import 'package:picapool/utils/theme.dart';

class CustomDivider extends StatelessWidget {
  final String text;
  final double verticalPadding;
  final Widget? child;
  final Color? color;
  final Color? textColor;
  const CustomDivider({
    super.key,
    required this.text,
    this.verticalPadding = 15.0,
    this.child,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          divider(),
          if (child == null)
            Text(
              text.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
                // letterSpacing: 1,
              ),
            )
          else
            child!,
          divider(),
        ],
      ),
    );
  }

  Widget divider() {
    return Expanded(
      child: Divider(
        height: 0.5,
        thickness: 1.5,
        color: color ?? AppTheme.currentTheme.primaryColor,
        indent: 4,
        endIndent: 4,
      ),
    );
  }
}
