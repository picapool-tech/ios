import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/functions/offers/offers_controller.dart';
import 'package:picapool/functions/user/user_controller.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/product_model.dart';
import 'package:picapool/screens/Products/send_to_whatsapp.dart';
import 'package:picapool/screens/vicinity/request_vicinity.dart';
import 'package:picapool/widgets/common/search_widget.dart';
import 'package:picapool/widgets/common/selectable_widget.dart';
import 'package:picapool/widgets/loading/chat_loading.dart';
import 'package:picapool/widgets/loading/image_loading.dart';
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

class _OfferDetailsPageState extends State<OfferDetailsPage>
    with TickerProviderStateMixin {
  final OffersController _offersController = Get.find<OffersController>();
  final UserController _userController = Get.find<UserController>();

  Future<Offer?> offerDetails = Future.value(null);

  // id and quantity
  Map<int, int> selectedProducts = {};

  final ScrollController _scrollController = ScrollController();

  bool isShowingTimer = false;
  String keyword = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: (!isShowingTimer)
              ? (hasSelectedProducts())
                  ? () async {
                      // Handle pooling action
                      if (widget.offer.top) {
                        _sendToWhatsApp();
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
          child: (!isShowingTimer)
              ? Text(
                  (!widget.offer.top) ? 'Start Pooling' : "Start Ordering",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'MontserratM',
                  ),
                )
              : getAnimation(),
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          widget.offer.name,
          maxLines: 1,
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'MontserratM',
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      extendBody: true,
      body: NestedScrollView(
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
                          return CachedNetworkImage(
                            imageUrl: widget.offer.images.lastOrNull ??
                                widget.offer.images.first,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            progressIndicatorBuilder: (context, url, progress) {
                              return const ImageLoading();
                            },
                          );
                        }
                      }(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.offer.desc,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'MontserratR',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'MontserratM',
                        color: Colors.black,
                      ),
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
              const SizedBox(height: 16),
              Expanded(
                child: _productDetailsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getAnimation() {
    final remainingDuration = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day, 18)
        .difference(DateTime.now());

    return TweenAnimationBuilder<Duration>(
      tween: Tween<Duration>(begin: remainingDuration, end: Duration.zero),
      duration: remainingDuration,
      onEnd: () {
        setState(() {
          isShowingTimer = false;
        });
      },
      builder: (context, Duration value, child) {
        return Text(
          "Activates in ${value.inHours.remainder(60)}h ${value.inMinutes.remainder(60)}m ${value.inSeconds.remainder(60)}s",
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'MontserratM',
            color: Colors.black,
          ),
        );
      },
    );
  }

  Future<Offer?> getOfferDetails(int id) async {
    return await _offersController.getOfferDetails(id);
  }

  bool hasSelectedProducts() {
    if (widget.offer.top) {
      return selectedProducts.entries.any((product) => product.value > 0);
    }
    return true;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((duration) {
      var dateTime = DateTime.now().hour;
      setState(() {
        offerDetails = _offersController.getOfferDetails(widget.offer.id);
        isShowingTimer = widget.offer.top && dateTime < 18 && dateTime >= 0;
      });
    });
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
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                maxLines: 2,
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
                  text: "$price",
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
                      text: "$originalPrice",
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

  Widget _productDetailsList() {
    return FutureBuilder<Offer?>(
        future: offerDetails,
        builder: (context, snapshot) {
          debugPrint("OFFER : ${snapshot.data}");
          if (snapshot.hasData) {
            var offer = snapshot.data;

            if (offer == null) {
              return const Center(
                child: Text("No product in this offer"),
              );
            }
            var products = offer.products ?? [];
            var filteredProducts = products
                .where(
                  (product) => product.name.toLowerCase().contains(
                        keyword.toLowerCase(),
                      ),
                )
                .toList();
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

                var item = _buildProductDetailDominos(
                  imagePath: product.images.firstOrNull,
                  title: product.name,
                  price: product.offerPrice,
                  description: product.description,
                  originalPrice: product.mrp,
                );

                return (offer.top)
                    ? SelectableWidget(
                        quantity: selectedProducts[product.id] ?? 0,
                        onQuantityChange: (value) {
                          setState(() {
                            selectedProducts[product.id] = value;
                          });
                        },
                        child: item,
                      )
                    : item;
              },
            );
          } else if (snapshot.hasError) {
            debugPrint("Error: ${snapshot.error}");
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else {
            return const ChatLoading();
          }
        });
  }

  void _sendToWhatsApp() async {
    var products = await offerDetails;
    if (products?.products == null) {
      Get.snackbar(
        'No products in this offer',
        'Please try again later',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    var listOfProducts = <Product>[];
    var selectedProducts = this
        .selectedProducts
        .entries
        .where((product) => product.value > 0)
        .toList();

    for (var product in selectedProducts) {
      for (var i = 0; i < product.value; i++) {
        listOfProducts.add(products!.products!.firstWhere(
          (element) => element.id == product.key,
        ));
      }
    }

    if (listOfProducts.isEmpty) {
      Get.snackbar(
        'No products selected',
        'Please select at least one product',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    var waLink = generateWhatsAppLink(
      _userController.user.value!.name!,
      _userController.user.value!.id,
      listOfProducts,
    );

    log(waLink);

    if (!await launchUrl(Uri.parse(waLink))) {
      Get.snackbar("Error", "Could not get WhatsApp link");
    }
  }
}
