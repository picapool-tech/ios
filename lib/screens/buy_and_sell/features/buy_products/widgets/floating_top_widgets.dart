import 'package:flutter/material.dart';
import 'package:picapool/utils/theme.dart';

enum FloatingTopWidgetDirection {
  left,
  right,
}

class FloatingTopWidgets extends StatelessWidget {
  static const Radius _radius = Radius.circular(15);

  static const leftRadius = BorderRadius.only(
    topRight: _radius,
    bottomRight: _radius,
  );
  static const rightRadius = BorderRadius.only(
    topLeft: _radius,
    bottomLeft: _radius,
  );

  static const circleRadius = BorderRadius.all(_radius);

  final FloatingTopWidgetDirection direction;
  final bool isCircle;
  final Widget child;
  final void Function()? onPressed;

  const FloatingTopWidgets({
    super.key,
    this.direction = FloatingTopWidgetDirection.left,
    this.isCircle = false,
    required this.child,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: isCircle
              ? circleRadius
              : direction == FloatingTopWidgetDirection.left
                  ? leftRadius
                  : rightRadius,
          color: AppTheme.currentTheme.scaffoldBackgroundColor,
        ),
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: child,
      ),
    );
  }
}
