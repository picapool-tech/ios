import 'package:flutter/material.dart';

class PermissionOptionsWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isEnabled;

  const PermissionOptionsWidget({
    super.key,
    required this.icon,
    required this.isEnabled,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.orange, size: 28),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: "MontserratR",
              ),
            ),
          ],
        ),
        Icon(
          Icons.check_circle,
          color: (isEnabled) ? Colors.green : Colors.grey,
          size: 28,
        ),
      ],
    );
  }
}
