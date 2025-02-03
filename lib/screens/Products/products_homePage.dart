import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/functions/location/location_provider.dart';
import 'package:picapool/functions/offers/offers_controller.dart';
import 'package:picapool/functions/partners/partnerModel/partner_request_model.dart';
import 'package:picapool/functions/partners/partner_controller.dart';
import 'package:picapool/functions/tags/tag_controller.dart';
import 'package:picapool/models/partner_model.dart';
import 'package:picapool/models/vicinity_offer_model.dart';
import 'package:picapool/screens/Products/products_detailed_page.dart';
import 'package:picapool/screens/Products/selected_brand_page.dart';
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
            backgroundColor: const Color(0xffffffff),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border.all(color: const Color(0xffF0F0F0), width: 1),
                      shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.orange),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
              title: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Find Offers and Brands',
                    hintStyle: TextStyle(
                      color: Color(0xff000000),
                      fontFamily: "MonsterratR",
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.orange),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  ),
                ),
              ),
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
                      onTap: (_partnerController.partners.isEmpty)
                          ? null
                          : () {
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
                    // const SizedBox(height: 20),
                    // _buildCommunitySaleCard(),
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
        await _locationController.getLocation();
        return;
      }
      var tags = Get.find<TagController>();
      var tag = tags.getTagsByTagName(widget.brandName);
      if (tag == null) {
        setState(() {
          showComingSoon = true;
        });
        return;
      }
      setState(() {
        tagId = tag.id;
      });
      _partnerController.searchPartner(
        PartnerRequestModel(
          radius: 5000,
          location: VicinityLocation(
            lat: location.latitude,
            long: location.longitude,
          ),
          tags: [tag.id],
        ),
      );
      _offersController.getOffersByTagId(tag.id);
    });
  }

  Widget offerImageBanner({
    required String? imageUrl,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: (imageUrl == null)
                ? Image.asset(
                    width: double.infinity,
                    'assets/dominos/OfferImag1.png',
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    width: double.infinity,
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
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
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: offers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            var offer = offers[index];
            return offerImageBanner(
              imageUrl: offer.images.firstOrNull,
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
        margin: const EdgeInsets.only(right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: (partner.pic != null)
                  ? Hero(
                      tag: partner.id,
                      child: CachedNetworkImage(
                        imageUrl: partner.pic!,
                      ),
                    )
                  : Image.asset(
                      'assets/dominos/logo.jpg',
                    ),
            ),
            // Container(
            //   width: 60,
            //   height: 60,
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle,
            //     color: Colors.white,
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.grey.withOpacity(0.3),
            //         spreadRadius: 1,
            //         blurRadius: 5,
            //         offset: const Offset(0, 3),
            //       ),
            //     ],
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.all(12),
            //     child:
            // (partner.pic != null)
            //         ? CachedNetworkImage(
            //             imageUrl: partner.pic!,
            //             fit: BoxFit.contain,
            //           )
            //         : Image.asset(
            //             'assets/dominos/logo.jpg',
            //             fit: BoxFit.contain,
            //           ),
            //   ),
            // ),
            const SizedBox(height: 8),
            Text(
              partner.ownername ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: "MontserratR",
              ),
            ),
          ],
        ),
      ),
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
            color: Colors.white,
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
