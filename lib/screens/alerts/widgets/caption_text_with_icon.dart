import 'package:flutter/material.dart';

class CaptionTextWithIcon extends StatelessWidget {
  final IconData icon;
  final Widget label;
  const CaptionTextWithIcon({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.orange),
        const SizedBox(width: 5),
        label,
      ],
    );
  }
}
