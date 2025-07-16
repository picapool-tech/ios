import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/common/widgets/search_widget.dart';
import 'package:picapool/common/widgets/selectable_widget.dart';
import 'package:picapool/features/offers/offers_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/product_model.dart';
import 'package:picapool/screens/Products/location_selection/location_screen.dart';
import 'package:picapool/screens/Products/send_to_whatsapp.dart';
import 'package:picapool/screens/product_buy_page.dart';
import 'package:picapool/screens/vicinity/request_vicinity.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/loading/chat_loading.dart';
import 'package:picapool/widgets/loading/image_loading.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class BrandOfferModel {
  final String title;
  final String description;
  final String imageUrl;
  final bool remoteImageUrl;

  BrandOfferModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.remoteImageUrl = true,
  });

  factory BrandOfferModel.fromJson(Map<String, dynamic> json) {
    return BrandOfferModel(
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}

class OfferDetailsPage extends StatefulWidget {
  final Offer offer;

  const OfferDetailsPage({
    super.key,
    required this.offer,
  });

  @override
  State<OfferDetailsPage> createState() => _OfferDetailsPageState();
}

enum SortOrder {
  none,
  ascending,
  descending,
}

class _OfferDetailsPageState extends State<OfferDetailsPage> {
  final OffersController _offersController = Get.find<OffersController>();
  final UserController _userController = Get.find<UserController>();

  Future<Offer?> offerDetails = Future.value(null);

  // id and quantity
  Map<int, int> selectedProducts = {};

  final ScrollController _scrollController = ScrollController();

  bool isShowingTimer = false;
  bool isOfferExpired = false;
  String keyword = "";

  SortOrder _sortOrder = SortOrder.none;
  final bool _filterActive = false;

  final Map<String, dynamic> _filters = {};

  final now = DateTime.now();

  Duration _remainingDuration = Duration.zero;

  List<String> _allCategories = [];
  bool _hasCategories = false;
  bool _hasVegToggle = false;
  bool isExpanded = false;

  String get activeFilterLabel {
    if (_filters.isEmpty) return "";
    List<String> labels = [];
    _filters.forEach((key, value) {
      if (value is bool) {
        labels.add(value ? key.toTitleCase() : "No $key");
      } else {
        labels.add("$value");
      }
    });
    return "(${labels.join(", ")})";
  }

  bool get hasSelectedProducts {
    if (widget.offer.top) {
      return selectedProducts.entries.any((product) => product.value > 0);
    }
    return true;
  }

  // the start time and interval of the offer is:
  // created at offer's time indicate the start hour of the offer for each day between created day and expriy day.
  bool get isBetweenDates =>
      (now.isAtSameMomentAs(widget.offer.createdAt) ||
          now.isAfter(widget.offer.createdAt)) &&
      (now.isAtSameMomentAs(widget.offer.expiryAt) ||
          now.isBefore(widget.offer.expiryAt));

  bool get isVegOnly => _filters.containsKey("veg") && _filters["veg"] == true;

  bool get isWithinTime {
    final startTotalMinutes =
        widget.offer.createdAt.hour * 60 + widget.offer.createdAt.minute;
    final endTotalMinutes =
        widget.offer.expiryAt.hour * 60 + widget.offer.expiryAt.minute;
    final nowTotalMinutes = now.hour * 60 + now.minute;

    debugPrint(
      "Start hour: ${widget.offer.createdAt.hour}\n"
      "Start minute: ${widget.offer.createdAt.minute}\n"
      "End hour: ${widget.offer.expiryAt.hour}\n"
      "End minute: ${widget.offer.expiryAt.minute}\n"
      "Now hour: ${now.hour}\n"
      "Now minute: ${now.minute}\n"
      "Start total minutes: $startTotalMinutes\n"
      "End total minutes: $endTotalMinutes\n"
      "Now total minutes: $nowTotalMinutes",
    );

    return nowTotalMinutes >= startTotalMinutes &&
        nowTotalMinutes <= endTotalMinutes;
  }

  String get _sortOrderIndicator {
    switch (_sortOrder) {
      case SortOrder.ascending:
        return "(Ascending)";
      case SortOrder.descending:
        return "(Descending)";
      case SortOrder.none:
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: (!isShowingTimer && !isOfferExpired)
              ? (hasSelectedProducts && !isOfferExpired)
                  ? () async {
                      // Handle pooling action
                      if (widget.offer.top) {
                        // _sendToWhatsApp();
                        handleTopClick();
                        return;
                      }
                      var model = BrandOfferModel(
                          title: widget.offer.name,
                          description: widget.offer.desc,
                          imageUrl: widget.offer.images.firstOrNull ?? "",
                          remoteImageUrl:
                              widget.offer.images.firstOrNull != null);
                      Get.to(() => const RequestVicinity(), arguments: {
                        "brands": {
                          ...model.toJson(),
                        }
                      });
                    }
                  : null
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffFF8D41),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
          ),
          child: (!isShowingTimer || isOfferExpired)
              ? Text(
                  (isOfferExpired)
                      ? "Offer Expired"
                      : (!widget.offer.top)
                          ? 'Start Pooling'
                          : "Start Ordering",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'MontserratM',
                  ),
                )
              : getAnimation(),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.orange,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          widget.offer.name,
          maxLines: 1,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          IconButton(
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(
                  text: widget.offer.shareOfferString,
                  // uri: Uri.parse("https://offer.picapool.com/offers/${widget.offer?.id}"),
                  subject: "Check out this offer on Picapool!",
                  // previewThumbnail: XFile(filePath),
                ),
              );
            },
            icon: const Icon(Icons.share, color: Colors.orange),
          )
        ],
      ),
      extendBody: true,
      body: Stack(
        children: [
          OverflowBox(
            fit: OverflowBoxFit.deferToChild,
            child: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: () {
                              if (widget.offer.images.isEmpty) {
                                return Image.asset(
                                  'assets/dominos/OfferImag1.png',
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              } else {
                                return Hero(
                                  tag: widget.offer.images.lastOrNull ?? "",
                                  child: CachedNetworkImage(
                                    imageUrl: widget.offer.images.lastOrNull ??
                                        widget.offer.images.first,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    progressIndicatorBuilder:
                                        (context, url, progress) {
                                      return const ImageLoading();
                                    },
                                  ),
                                );
                              }
                            }(),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.offer.desc,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'View Details',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (widget.offer.top)
                            Text(
                              'Select one or more products to pool',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchWidget(
                      onSearch: (keyword) {
                        setState(
                          () {
                            this.keyword = keyword;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    // sorting by price and filtering icon here..
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: PicaTextButton(
                            icon: Icon(
                              Icons.sort,
                              color: Get.theme.primaryColor,
                            ),
                            text: "Sort $_sortOrderIndicator",
                            onPressed: _showSortingOptions,
                            isLoading: false.obs,
                          ),
                        ),
                        if (_hasVegToggle) ...[
                          const SizedBox(width: 20),
                          Row(
                            children: [
                              Text(
                                'Veg Mode',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              CupertinoSwitch(
                                value: isVegOnly,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      if (value) {
                                        _filters["veg"] = true;
                                      } else {
                                        _filters.remove("veg");
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ]
                        // TextButton.icon(
                        //   icon: const Icon(Icons.filter_alt_outlined),
                        //   label: Text('Filter $activeFilterLabel'),
                        //   onPressed: _showFilterOptions,
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: Colors.white,
                        //     foregroundColor: Colors.black,
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(20),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: _productDetailsList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = false;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: (_hasCategories)
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isExpanded ? MediaQuery.sizeOf(context).width * 0.8 : 70,
              height: isExpanded ? MediaQuery.sizeOf(context).height * 0.4 : 70,
              decoration: BoxDecoration(
                color: AppTheme.currentTheme.brightness == Brightness.light
                    ? Colors.black
                    : AppTheme.currentTheme.secondaryHeaderColor,
                borderRadius: BorderRadius.circular(isExpanded ? 16 : 50),
              ),
              child: isExpanded
                  ? categoryFilter()
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = true;
                        });
                      },
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.tune,
                              size: 26,
                              color: Colors.white), // cleaner filter icon
                          SizedBox(height: 2),
                          Text("Filter",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
            )
          : null,
    );
  }

  Widget categoryFilter() {
    final isActive = (_filters["category"] == null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = false;
              _filters.remove("category");
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              'All Categories',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isActive ? Colors.white : Colors.grey,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontFamily: 'MontserratM',
                  ),
            ),
          ),
        ),
        Divider(
          color: Colors.grey.shade800,
        ),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (var category in _allCategories)
                _buildFilterOptionTile(
                  filterKey: "category",
                  filterValue: category,
                  label: category,
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getAnimation() {
    if (_remainingDuration <= Duration.zero) {
      return const Text(
        "Activating...",
      );
    }

    return TweenAnimationBuilder<Duration>(
      tween: Tween<Duration>(begin: _remainingDuration, end: Duration.zero),
      duration: _remainingDuration,
      onEnd: () {
        setState(() {
          if (isBetweenDates && isWithinTime) {
            isShowingTimer = false;
          }
        });
      },
      builder: (context, Duration value, child) {
        return FittedBox(
          child: Text(
            "Activates in ${value.inHours.remainder(60)}h ${value.inMinutes.remainder(60)}m ${value.inSeconds.remainder(60)}s",
            style: const TextStyle(
              fontFamily: 'MontserratM',
              color: Colors.black,
            ),
          ),
        );
      },
    );
  }

  Future<Offer?> getOfferDetails(int id) async {
    return await _offersController.getOfferDetails(id);
  }

  void handleTopClick() {
    Get.to(() => LocationScreen(
          onLocationSelected: (address) {
            _sendToWhatsApp(address);
          },
        ));
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((duration) {
      offerDetails = _offersController.getOfferDetails(widget.offer.id)
        ..then((offer) {
          if (offer == null) return;

          // -------- Build capabilities --------
          final catSet = <String>{};
          bool vegFlag = false;
          for (final p in (offer.products ?? [])) {
            final attrs = p.attributes ?? {};
            final cat = attrs['category'];
            if (cat is String && cat.trim().isNotEmpty) catSet.add(cat);
            if (attrs.containsKey('veg')) vegFlag = true;
          }

          setState(() {
            _allCategories = catSet.toList()..sort();
            _hasCategories = _allCategories.isNotEmpty;
            _hasVegToggle = vegFlag;
          });
        });

      if (widget.offer.top) {
        _initTimer();
      }
    });
  }

  // Filter logic that checks all conditions in _filters
  bool _applyFilters(Product product) {
    if (_filters.isEmpty) return true; // no filters => show everything
    for (var entry in _filters.entries) {
      var key = entry.key; // e.g. "veg"
      var desiredValue = entry.value; // e.g. true or false
      var productValue =
          product.attributes?[key]; // e.g. product.attributes["veg"]
      if (productValue == null || productValue != desiredValue) {
        return false;
      }
    }

    // Defensive: if categories vanished (shouldn’t happen often).
    if (_hasCategories == false && _filters.containsKey('category')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _filters.remove('category'));
      });
    }

    return true;
  }

  Widget _buildCategoryFilterSection() {
    bool isCategoryFiltered = _filters.containsKey("category");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category title + remove category filter (if active)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'MontserratM',
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isCategoryFiltered)
              TextButton.icon(
                icon: const Icon(Icons.clear, color: Colors.red),
                label: const Text("Clear filter",
                    style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _filters.remove("category");
                  });
                },
              ),
          ],
        ),
        const Divider(),
        // Category list
        for (var category in _allCategories)
          _buildFilterOptionTile(
            filterKey: "category",
            filterValue: category,
            label: category,
          ),
      ],
    );
  }

  /// A reusable tile that sets a [filterKey] to [filterValue].
  Widget _buildFilterOptionTile({
    required String filterKey,
    required dynamic filterValue,
    required String label,
  }) {
    final isActive = (_filters[filterKey] == filterValue);
    return ListTile(
      title: Text(label),
      titleTextStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.normal,
            fontFamily: 'MontserratM',
          ),
      onTap: () {
        setState(() {
          isExpanded = false;
          _filters[filterKey] = filterValue;
        });
      },
    );
  }

  Widget _buildProductDetailDominos({
    required String? imagePath,
    required String title,
    required String description,
    required int? price,
    required int? originalPrice,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: (imagePath == null)
              ? Image.asset(
                  "assets/dominos/Margherita Pizza.png",
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  imageUrl: imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'MontserratM',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'MontserratR',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text.rich(
                TextSpan(
                  text: "₹ $price",
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'MontserratM',
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    const TextSpan(
                      text: ' M.R.P. ',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'MontserratR',
                        color: Colors.grey,
                      ),
                    ),
                    TextSpan(
                      text: "₹ $originalPrice",
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'MontserratR',
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// A reusable tile that removes the existing filter [filterKey].
  Widget _buildRemoveFilterTile({
    required String filterKey,
    required String label,
  }) {
    return ListTile(
      leading: const Icon(Icons.remove_circle, color: Colors.red),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _filters.remove(filterKey);
        });
      },
    );
  }

  Widget _buildVegFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Veg / Non-Veg',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'MontserratM',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Divider(),
        _buildFilterOptionTile(
          filterKey: "veg",
          filterValue: true,
          label: "Veg Only",
        ),
        _buildFilterOptionTile(
          filterKey: "veg",
          filterValue: false,
          label: "Non-Veg Only",
        ),
        // Option to remove the veg filter
        if (_filters.containsKey("veg"))
          _buildRemoveFilterTile(
            filterKey: "veg",
            label: "Remove Veg Filter",
          ),
      ],
    );
  }

  void _initTimer() {
    if (!isBetweenDates) {
      if (now.isAfter(widget.offer.expiryAt)) {
        // show that offer is expired!
        setState(() {
          isOfferExpired = true;
        });
      }

      if (now.isBefore(widget.offer.createdAt)) {
        final diff = widget.offer.createdAt.difference(now);
        setState(() {
          isShowingTimer = diff > Duration.zero;
          _remainingDuration = diff;
        });
        return;
      }

      return;
    }

    if (!isWithinTime) {
      final nextTime = now.copyWith(
          hour: widget.offer.createdAt.hour,
          minute: widget.offer.createdAt.minute);

      final diff = nextTime.difference(now);
      setState(() {
        isShowingTimer = diff > Duration.zero;
        _remainingDuration = diff;
      });
      return;
    }
  }

  Widget _productDetailsList() {
    return FutureBuilder<Offer?>(
      future: offerDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ChatLoading();
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: Text("No product in this offer"),
          );
        }

        debugPrint("OFFER : ${snapshot.data}");

        var products = snapshot.data?.products ?? [];

        // 1) Filter products based on keyword
        String keywordLower = keyword.toLowerCase();
        var filteredProducts = products.where((product) {
          bool matchesKeyword =
              product.name.toLowerCase().contains(keywordLower);
          bool passesFilters = _applyFilters(product);
          return matchesKeyword && passesFilters;
        }).toList();

        // 2) Sort products based on _sortOrder price
        switch (_sortOrder) {
          case SortOrder.ascending:
            filteredProducts
                .sort((a, b) => a.offerPrice!.compareTo(b.offerPrice!));
            break;
          case SortOrder.descending:
            filteredProducts
                .sort((a, b) => b.offerPrice!.compareTo(a.offerPrice!));
            break;
          default:
            break;
        }

        if (filteredProducts.isEmpty) {
          return const Center(
            child: Text("No matching products found"),
          );
        }

        return ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          shrinkWrap: true,
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            if (selectedProducts.length <= index) {
              if (!selectedProducts.containsKey(product.id)) {
                selectedProducts[product.id] = 0;
              }
            }

            return (widget.offer.top)
                ? SelectableWidget(
                    quantity: selectedProducts[product.id] ?? 0,
                    onQuantityChange: (value) {
                      setState(() {
                        selectedProducts[product.id] = value;
                      });
                    },
                    product: product,
                  )
                : _buildProductDetailDominos(
                    imagePath: product.images.firstOrNull,
                    title: product.name,
                    price: product.offerPrice,
                    description: product.description,
                    originalPrice: product.mrp,
                  );
          },
        );
      },
    );
  }

  void _sendToWhatsApp(String address) async {
    var products = await offerDetails;
    if (products?.products == null) {
      Get.snackbar(
        'No products in this offer',
        'Please try again later',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    var listOfProducts = <Product, int>{};
    // Create a map of product IDs to their counts (filtered to only include products with count > 0)
    var productCountMap = Map.fromEntries(
        selectedProducts.entries.where((entry) => entry.value > 0));

    // Use the filtered map to populate listOfProducts
    for (var entry in productCountMap.entries) {
      var productId = entry.key;
      var quantity = entry.value;

      var product = products!.products!.firstWhere(
        (element) => element.id == productId,
      );

      // Add the product to listOfProducts 'quantity' times
      listOfProducts[product] = quantity;
    }

    if (listOfProducts.isEmpty) {
      Get.snackbar(
        'No products selected',
        'Please select at least one product',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    var waLink = generateWhatsAppLinkWithAddress(
      username: _userController.user!.username!,
      userId: _userController.user!.id,
      products: listOfProducts,
      address: address,
      offerId: widget.offer.id,
    );

    log(waLink);

    if (!await launchUrl(Uri.parse(waLink))) {
      Get.snackbar("Error", "Could not get WhatsApp link");
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      useSafeArea: true,
      isScrollControlled: true, // allows the sheet to expand
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title + clear button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Options',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'MontserratM',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_filters.isNotEmpty)
                          TextButton.icon(
                            icon: const Icon(Icons.clear, color: Colors.red),
                            label: const Text('Clear All'),
                            onPressed: () {
                              Navigator.pop(ctx);
                              setState(() {
                                _filters.clear();
                              });
                            },
                          ),
                      ],
                    ),
                    const Divider(),
                    // Section 1: Veg / Non-Veg
                    _buildVegFilterSection(),
                    const SizedBox(height: 16),
                    // Section 2: Category
                    _buildCategoryFilterSection(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSortingOptions() {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      useSafeArea: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sorting Options',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'MontserratM',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              ListTile(
                leading: (_sortOrder == SortOrder.ascending)
                    ? const Icon(Icons.check, color: Colors.green)
                    : const SizedBox.shrink(),
                title: const Text('Price Ascending'),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _sortOrder = SortOrder.ascending;
                  });
                },
              ),
              ListTile(
                leading: (_sortOrder == SortOrder.descending)
                    ? const Icon(Icons.check, color: Colors.green)
                    : const SizedBox.shrink(),
                title: const Text('Price Descending'),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _sortOrder = SortOrder.descending;
                  });
                },
              ),
              ListTile(
                leading: (_sortOrder == SortOrder.none)
                    ? const Icon(Icons.check, color: Colors.green)
                    : const SizedBox.shrink(),
                title: const Text('No Sorting'),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _sortOrder = SortOrder.none;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
