import 'package:flutter/material.dart';

class TileButton extends StatelessWidget {
  final String title;
  final String imagePath;
  final void Function() onTap;
  final bool isDisabled;
  final bool isLast;

  const TileButton({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
    this.isDisabled = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          leading: Image.asset(
            imagePath, // Use the provided image path
            width: 28, // Adjust the size as needed
            height: 28,
            color: (isDisabled) ? Colors.grey : null,
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: (isDisabled) ? Colors.grey : null,
                ),
          ),
          onTap: (!isDisabled) ? onTap : null,
        ),
        if (!isLast)
          const Divider(
            color: Colors.grey, // Grey color divider
            thickness: 0.5,
            height: 1,
          )
      ],
    );
  }
}
