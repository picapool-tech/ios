import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:picapool/widgets/loading/image_loading.dart';

class ImageWidget extends StatelessWidget {
  final String imageUrl;
  final String fallBackAssetImageUrl;

  final double? width;
  final double? height;

  final BoxFit? fit;

  const ImageWidget({
    super.key,
    required this.imageUrl,
    required this.fallBackAssetImageUrl,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0), // Adjust the radius as needed
      child: CachedNetworkImage(
        width: width,
        height: height,
        fit: fit,
        imageUrl: imageUrl,
        errorWidget: (context, url, error) => Image.asset(
          fallBackAssetImageUrl,
        ),
        placeholder: (context, url) => ImageLoading(
          width: width ?? 100,
          height: height ?? 100,
        ),
      ),
    );
  }
}
