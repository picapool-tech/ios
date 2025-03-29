import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:picapool/utils/theme.dart';

class CategoryButton extends StatelessWidget {
  final String label;
  final bool selected;
  final String image;
  final String assetImage;
  final VoidCallback onTap;

  const CategoryButton({
    super.key,
    required this.label,
    required this.image,
    required this.onTap,
    this.selected = false,
    this.assetImage = "",
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          foregroundColor: selected ? Colors.white : Colors.black,
          backgroundColor:
              selected ? AppTheme.currentTheme.primaryColor : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        onPressed: onTap,
        icon: (assetImage.isNotEmpty)
            ? Image.asset(assetImage, width: 20, height: 20)
            : CachedNetworkImage(
                imageUrl: image,
                width: 20,
                height: 20,
                // color: selected ? Colors.white : null,
                // colorBlendMode: BlendMode.multiply,
              ),
        label: Text(
          label,
        ),
      ),
    );
  }
}
