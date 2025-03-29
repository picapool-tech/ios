import 'package:flutter/material.dart';
import 'package:picapool/utils/theme.dart';

class CaptionTextWithIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  const CaptionTextWithIcon({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.orange),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            color: AppTheme.currentTheme.hintColor,
          ),
        ),
      ],
    );
  }
}
