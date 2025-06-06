import 'package:flutter/material.dart';

class CaptionTextWithIcon extends StatelessWidget {
  final IconData icon;
  final Widget label;
  final Color? color;
  const CaptionTextWithIcon({
    super.key,
    required this.icon,
    required this.label,
    this.color = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 5),
        label,
      ],
    );
  }
}
