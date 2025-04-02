import 'dart:ui';

import 'package:flutter/material.dart';

class BlurryContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color backgroundColor;
  final Border? border;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  const BlurryContainer({
    Key? key,
    required this.child,
    this.blur = 10,
    this.backgroundColor = Colors.transparent,
    this.border,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          // Remove width and height to let the container size to its content
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            border: border,
          ),
          child: child,
        ),
      ),
    );
  }
}
