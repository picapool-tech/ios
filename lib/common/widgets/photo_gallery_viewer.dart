import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'dart:math' as math;

class PhotoGalleryViewer extends StatefulWidget {
  /// List of image sources to display in gallery
  final List<String> imageUrls;

  /// Initial page index to display (defaults to 0)
  final int initialIndex;

  /// Background color for the gallery
  final Color backgroundColor;

  /// Show position indicator at the bottom
  final bool showIndicator;

  /// Load images from network or assets
  final bool loadFromNetwork;

  /// Custom page change callback
  final Function(int)? onPageChanged;

  final void Function(int)? onDeleteImage;

  const PhotoGalleryViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.backgroundColor = Colors.black,
    this.showIndicator = true,
    this.loadFromNetwork = true,
    this.onPageChanged,
    this.onDeleteImage,
  });

  @override
  State<PhotoGalleryViewer> createState() => _PhotoGalleryViewerState();
}

class _ImageWithLoading extends StatefulWidget {
  final String imageUrl;
  final bool loadFromNetwork;

  const _ImageWithLoading({
    required this.imageUrl,
    required this.loadFromNetwork,
  });

  @override
  State<_ImageWithLoading> createState() => _ImageWithLoadingState();
}

class _ImageWithLoadingState extends State<_ImageWithLoading> {
  bool _isLoading = true;
  bool _hasError = false;
  late ImageProvider _imageProvider;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_hasError) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: Colors.white70,
            size: 60,
          ),
          SizedBox(height: 16),
          Text(
            'Failed to load image',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      );
    }

    return Hero(
      tag: widget.imageUrl,
      child: Image(
        image: _imageProvider,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
              color: Colors.white,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image,
                color: Colors.white70,
                size: 60,
              ),
              SizedBox(height: 16),
              Text(
                'Failed to load image',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _imageProvider = widget.loadFromNetwork
        ? CachedNetworkImageProvider(widget.imageUrl)
        : AssetImage(widget.imageUrl) as ImageProvider;

    _loadImage();
  }

  void _loadImage() {
    final ImageStream stream = _imageProvider.resolve(ImageConfiguration.empty);

    stream.addListener(ImageStreamListener(
      (ImageInfo info, bool synchronous) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      onError: (Object exception, StackTrace? stackTrace) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      },
    ));
  }
}

class _PhotoGalleryViewerState extends State<PhotoGalleryViewer> {
  late int currentIndex;
  late PageController _pageController;
  final List<TransformationController> _transformationControllers = [];

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      Get.back();
    }
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Gallery with swipe functionality
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              // Reset zoom when changing pages
              _resetZoom();

              setState(() {
                currentIndex = index;
              });
              if (widget.onPageChanged != null) {
                widget.onPageChanged!(index);
              }
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onDoubleTap: _resetZoom,
                child: InteractiveViewer(
                  transformationController: _transformationControllers[index],
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: _ImageWithLoading(
                      imageUrl: widget.imageUrls[index],
                      loadFromNetwork: widget.loadFromNetwork,
                    ),
                  ),
                ),
              );
            },
          ),

          // Close button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          Positioned(
            top: 40,
            right: 80,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.red, size: 30),
              onPressed: () {
                setState(() {
                  widget.imageUrls.removeAt(currentIndex);
                });

                widget.onDeleteImage!(currentIndex);
              },
            ),
          ),

          // Page indicator
          if (widget.showIndicator && widget.imageUrls.length > 1)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Current position text
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "${currentIndex + 1} of ${widget.imageUrls.length}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

          // Dot indicators
          if (widget.showIndicator && widget.imageUrls.length > 1)
            Positioned(
              bottom: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (index) => Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _transformationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Create transformation controllers for each image
    for (int i = 0; i < widget.imageUrls.length; i++) {
      _transformationControllers.add(TransformationController());
    }
  }

  void _resetZoom() {
    _transformationControllers[currentIndex].value = Matrix4.identity();
  }
}
