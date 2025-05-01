import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:picapool/common/extensions/color_extensions.dart';
import 'package:picapool/common/extensions/string_extensions.dart';

class UserProfilePictureWidget extends StatelessWidget {
  final String? imageUrl;
  final double? size;
  final String username;
  final String? assetImage;
  final bool showAssetImage;
  final double? radius;

  const UserProfilePictureWidget({
    super.key,
    this.imageUrl,
    this.size,
    required this.username,
    this.assetImage,
    this.showAssetImage = false,
    this.radius,
  }) : assert(
          imageUrl != null || (!showAssetImage || assetImage != null),
          'Either imageUrl or assetImage must be provided',
        );

  @override
  Widget build(BuildContext context) {
    var colorFromUsername = username.toColor;

    return CircleAvatar(
      radius: radius,
      backgroundImage: imageUrl != null
          ? CachedNetworkImageProvider(
              imageUrl!,
            )
          : (showAssetImage)
              ? AssetImage(assetImage!) as ImageProvider
              : null,
      backgroundColor: colorFromUsername.lighter(0.38),
      child: imageUrl == null
          ? Text(
              username.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: colorFromUsername.darker(0.1),
              ),
            )
          : null,
    );
  }
}
