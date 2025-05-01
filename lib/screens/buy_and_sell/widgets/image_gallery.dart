import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/photo_gallery_viewer.dart';
import 'package:picapool/utils/theme.dart';

class ImageGallery extends StatefulWidget {
  final List<String> imageUrl;

  const ImageGallery({
    super.key,
    required this.imageUrl,
  });

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.width * 0.8,
      child: widget.imageUrl.isEmpty
          ? Image.asset("assets/images/buy_and_sell/no_image.png")
          : Column(
              children: [
                Expanded(
                  flex: 5,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(
                        fullscreenDialog: true,
                        () => PhotoGalleryViewer(
                          imageUrls: widget.imageUrl,
                          loadFromNetwork: true,
                          initialIndex: _selectedIndex,
                          showIndicator: true,
                        ),
                        transition: Transition.zoom,
                        popGesture: true,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: roundedContainer().copyWith(
                        color: AppTheme.currentTheme.cardColor,
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrl[_selectedIndex],
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.currentTheme.colorScheme.secondary,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),

                // Visual divider to separate sections
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),

                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.imageUrl.length,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: roundedContainer().copyWith(
                              color: _selectedIndex == index
                                  ? AppTheme.currentTheme.colorScheme.secondary
                                  : Colors.grey.withOpacity(0.3),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CachedNetworkImage(
                                imageUrl: widget.imageUrl[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme
                                          .currentTheme.colorScheme.secondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
