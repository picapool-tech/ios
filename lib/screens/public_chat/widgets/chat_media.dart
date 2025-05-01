import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/photo_gallery_viewer.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/loading/image_loading.dart';

class ChatMedia extends StatelessWidget {
  final List<String>? images;
  const ChatMedia({
    super.key,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return (images == null || images!.isEmpty)
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_rounded,
                size: 50,
                color:
                    AppTheme.currentTheme.colorScheme.secondary.withAlpha(100),
              ),
              Text(
                "No Media",
                style: TextStyle(
                  color: AppTheme.currentTheme.colorScheme.secondary,
                ),
              ),
            ],
          )
        : GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: images!.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Get.to(
                    () => PhotoGalleryViewer(
                      imageUrls: images!,
                      loadFromNetwork: true,
                      showIndicator: true,
                      initialIndex: index,
                    ),
                    fullscreenDialog: true,
                    transition: Transition.zoom,
                  );
                },
                child: Hero(
                  tag: images![index],
                  transitionOnUserGestures: true,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: CachedNetworkImage(
                      imageUrl: images![index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: ImageLoading(),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
              );
            },
          );
  }
}
