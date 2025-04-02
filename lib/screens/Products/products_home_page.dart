import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/carousel_widget.dart';
import 'package:picapool/features/location/location_controller.dart';
import 'package:picapool/features/offers/offers_controller.dart';
import 'package:picapool/features/partners/partnerModel/partner_request_model.dart';
import 'package:picapool/features/partners/partner_controller.dart';
import 'package:picapool/features/tags/tag_controller.dart';
import 'package:picapool/models/partner_model.dart';
import 'package:picapool/models/vicinity_offer_model.dart';
import 'package:picapool/screens/products/products_detailed_page.dart';
import 'package:picapool/screens/products/selected_brand_page.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/home/coming_soon.dart';
import 'package:picapool/widgets/loading/circle_list_loading.dart';
import 'package:picapool/widgets/loading/image_list_loading.dart';

class ProductsHomepage extends StatefulWidget {
  final String brandName;
  const ProductsHomepage({Key? key, required this.brandName}) : super(key: key);

  @override
  State<ProductsHomepage> createState() => _ProductsHomepageState();
}

class _ProductsHomepageState extends State<ProductsHomepage> {
  final PartnerController _partnerController = Get.find<PartnerController>();

  final LocationController _locationController = Get.find<LocationController>();
  final OffersController _offersController = Get.find<OffersController>();

  int? tagId;

  bool showComingSoon = false;

  @override
  Widget build(BuildContext context) {
    return (showComingSoon)
        ? ComingSoon(
            title: widget.brandName,
          )
        : Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: Text(widget.brandName),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(
                            indent: 40,
                            thickness: 1,
                            color: Color(0xffFF8D41),
                          ),
                        ),
                        Text(
                          "  Brands  ",
                          style: TextStyle(
                              fontSize: 16, fontFamily: "MontserratM"),
                        ),
                        Expanded(
                          child: Divider(
                            endIndent: 40,
                            thickness: 1,
                            color: Color(0xffFF8D41),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GetBuilder<PartnerController>(builder: (controller) {
                      if (controller.isLoading.value &&
                          controller.partners.isEmpty) {
                        return const SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: CircleListLoading(),
                        );
                      }

                      if (controller.partners.isEmpty) {
                        return const Center(child: Text('No partners found'));
                      }

                      return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              controller.partners.length,
                              (index) => _buildBrandItem(
                                controller.partners[index],
                              ),
                            ),
                          ));
                    }),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        if (_partnerController.partners.isEmpty) {
                          return;
                        }
                        _showBrandBottomSheet(
                          context,
                          _partnerController.partners,
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "View Brands",
                            style: TextStyle(
                              color: Color(0xffFF8D41),
                              fontSize: 14,
                              fontFamily: "MontserratM",
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_drop_down_circle_outlined,
                            color: Color(0xffFF8D41),
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (tagId != null) _largeBanner(),
                    const SizedBox(height: 20),
                    if (tagId != null) _bestOffers(),
                  ],
                ),
              ),
            ),
          );
  }

  @override
  void dispose() {
    super.dispose();
    _partnerController.partners.clear();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var location = _locationController.state.value.location;
      if (location == null) {
        debugPrint("Location is null in Pooling categories");
        await _locationController.getLocation();
      }
      location = _locationController.state.value.location;

      if (location == null) {
        return;
      }

      var tagController = Get.find<TagController>();

      if (tagController.tags.isEmpty) {
        await tagController.getAllTags();
      }

      var tag = tagController.getTagsByTagName(widget.brandName);
      if (tag == null) {
        debugPrint("tag is null");
        setState(() {
          showComingSoon = true;
        });
        return;
      }
      setState(() {
        tagId = tag.id;
      });
      await _partnerController.searchPartner(
        PartnerRequestModel(
          radius: 5000,
          location: VicinityLocation(
            lat: location.latitude,
            long: location.longitude,
          ),
          tags: [tag.id],
        ),
      );
      if (_partnerController.partners.isEmpty) {
        setState(() {
          showComingSoon = true;
        });
        return;
      }
      _offersController.getOffersByTagId(tag.id);
    });
  }

  Widget offerImageBanner(
      {required String? imageUrl,
      required VoidCallback onTap,
      double? height}) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: (imageUrl == null)
                ? Image.asset(
                    width: double.infinity,
                    height: height,
                    'assets/dominos/OfferImag1.png',
                    fit: BoxFit.cover,
                  )
                : Hero(
                    tag: imageUrl,
                    child: CachedNetworkImage(
                      width: double.infinity,
                      height: height,
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'See Details',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _bestOffers() {
    return GetBuilder(
      init: _offersController,
      builder: (controller) {
        if (controller.isLoading.value &&
            controller.offersByTagId[tagId] == null) {
          return const ImageListLoading();
        }

        if (controller.offersByTagId[tagId] == null ||
            controller.offersByTagId[tagId]!.isEmpty) {
          return const Center(
            child: Text('No offers found'),
          );
        }
        var offers = controller.offersByTagId[tagId]!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            var offer = offers[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: offerImageBanner(
                imageUrl: offer.images.firstOrNull,
                onTap: () {
                  Get.to(
                    () => OfferDetailsPage(offer: offer),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBrandItem(Partner partner) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => PlayStationPage(
            partner: partner,
          ),
        );
        // }
      },
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 120,
        ),
        margin: const EdgeInsets.only(right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: roundedContainer(radius: 100),
              clipBehavior: Clip.hardEdge,
              child: (partner.pic != null)
                  ? Hero(
                      tag: partner.id,
                      child: CachedNetworkImage(
                        imageUrl: partner.pic!,
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.error,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ),
                    )
                  : Image.asset(
                      'assets/dominos/logo.jpg',
                    ),
            ),
            const SizedBox(height: 8),
            Wrap(
              children: [
                Text(
                  partner.ownername ?? '',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: "MontserratR",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _largeBanner() {
    return GetBuilder(
      init: _offersController,
      builder: (controller) {
        if (controller.isLoading.value &&
            controller.offersByTagId[tagId] == null) {
          return const ImageListLoading();
        }

        if (controller.offersByTagId[tagId] == null ||
            controller.offersByTagId[tagId]!.isEmpty) {
          return const Center(
            child: Text('No offers found'),
          );
        }
        var offers = controller.offersByTagId[tagId]!;

        return CarouseldWiget(
          count: offers.length,
          height: 340,
          itemBuilder: (context, index, realIndex) {
            var offer = offers[index];
            return offerImageBanner(
              imageUrl: offer.images.lastOrNull,
              onTap: () {
                Get.to(
                  () => OfferDetailsPage(offer: offer),
                );
              },
            );
          },
        );
      },
    );
  }

  // String _getBrandRating(String brandName) {
  //   switch (brandName.toLowerCase()) {
  //     case 'skullcandy':
  //       return '4.1';
  //     case 'bose':
  //       return '4.6';
  //     case 'apple inc':
  //       return '4.8';
  //     case 'playstation':
  //       return '4.8';
  //     default:
  //       return '4.0';
  //   }
  // }

  void _showBrandBottomSheet(BuildContext context, List<Partner> brands) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(
                    child: Divider(
                      indent: 40,
                      thickness: 1,
                      color: Color(0xffFF8D41),
                    ),
                  ),
                  Text(
                    "  Brands  ",
                    style: TextStyle(fontSize: 16, fontFamily: "MontserratM"),
                  ),
                  Expanded(
                    child: Divider(
                      endIndent: 40,
                      thickness: 1,
                      color: Color(0xffFF8D41),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15.0,
                    mainAxisSpacing: 15.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: brands.length,
                  itemBuilder: (BuildContext context, int index) {
                    final brand = brands[index];
                    return _buildBrandItem(brand);
                    // return Container(
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(15),
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       CachedNetworkImage(
                    //         imageUrl: brand.pic ?? '',
                    //         width: 40,
                    //         fit: BoxFit.contain,
                    //       ),
                    //       Text(
                    //         brand.ownername ?? '',
                    //         style: const TextStyle(
                    //           fontSize: 16,
                    //           fontFamily: "MontserratM",
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
