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

class ProductsHomepage extends StatefulWidget {
  final int currentIndex;
  const ProductsHomepage({Key? key, required this.currentIndex})
      : super(key: key);

  @override
  State<ProductsHomepage> createState() => _ProductsHomepageState();
}

class _ProductsHomepageState extends State<ProductsHomepage> {
  final PartnerController _partnerController = Get.find<PartnerController>();

  final LocationController _locationController = Get.find<LocationController>();
  final OffersController _offersController = Get.find<OffersController>();

  int? tagId;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (pop, result) {
        if (!pop) {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xffffffff),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xffF0F0F0), width: 1),
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
          actions: const [
            // Padding(
            //   padding: const EdgeInsets.only(right: 16.0),
            //   child: CircleAvatar(
            //     backgroundImage: (_userController.user.value?.pic != null)
            //         ? CachedNetworkImageProvider(
            //             _userController.user.value!.pic!)
            //         : const AssetImage('assets/icons/Frame 64.png')
            //             as ImageProvider,
            //   ),
            // ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
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
                GetBuilder<PartnerController>(builder: (controller) {
                  if (controller.isLoading.value &&
                      controller.partners.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
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
                      : () => _showBrandBottomSheet(
                            context,
                            _partnerController.partners,
                          ),
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

                // const SizedBox(height: 20),
                // _buildCommunitySaleCard(),
                // const SizedBox(height: 20),
                // _buildCommunitySaleCard(),
                // const SizedBox(height: 20),
                // _buildCommunitySaleCard(),
                // const SizedBox(height: 20),
                // _buildCommunitySaleCard(),
              ],
            ),
          ),
        ),
      ),
    );
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
      _partnerController.searchPartner(
        PartnerRequestModel(
          radius: 1000,
          location: VicinityLocation(
            lat: location.latitude,
            long: location.longitude,
          ),
        ),
      );
      var tags = Get.find<TagController>();
      var tag = tags.getTagsByTagName("food");
      if (tag != null) {
        await _offersController.getOffersByTagId(tag.id);
        setState(() {
          tagId = tag.id;
        });
      }
    });
  }

  // Widget _buildCommunitySaleCard() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.black,
  //       borderRadius: BorderRadius.circular(15),
  //     ),
  //     child: offerImageBanner(),
  //   );
  // }

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
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                  ),
          ),
                // if (_partnerController.partners.isEmpty) return;
                // var offer = _partnerController.partners.firstOrNull?.offers;
      
                // if (offer == null || offer.isEmpty) return;
      
                // Get.to(() => OfferDetailsPage(offer: offer.first));
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
          return const Center(child: CircularProgressIndicator());
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
        // if (brand['name'] == 'Dominos') {
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
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: (partner.pic != null)
                    ? CachedNetworkImage(
                        imageUrl: partner.pic!,
                        fit: BoxFit.contain,
                      )
                    : Image.asset(
                        'assets/dominos/logo.jpg',
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              partner.ownername ?? '',
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

  Color _getBrandColor(String brandName) {
    switch (brandName.toLowerCase()) {
      case 'skullcandy':
        return Colors.orange;
      case 'bose':
        return Colors.black;
      case 'apple inc':
        return Colors.white;
      case 'playstation':
        return Colors.deepPurple;
      default:
        return Colors.white;
    }
  }

  String _getBrandDistance(String brandName) {
    switch (brandName.toLowerCase()) {
      case 'skullcandy':
        return '2 km away';
      case 'bose':
        return '24 km away';
      case 'apple inc':
        return '12 km away';
      case 'playstation':
        return '12 km away';
      default:
        return '10 km away';
    }
  }

  String _getBrandRating(String brandName) {
    switch (brandName.toLowerCase()) {
      case 'skullcandy':
        return '4.1';
      case 'bose':
        return '4.6';
      case 'apple inc':
        return '4.8';
      case 'playstation':
        return '4.8';
      default:
        return '4.0';
    }
  }

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
                    crossAxisCount: 2,
                    crossAxisSpacing: 15.0,
                    mainAxisSpacing: 15.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: brands.length,
                  itemBuilder: (BuildContext context, int index) {
                    final brand = brands[index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: CachedNetworkImage(
                              imageUrl: brand.pic ?? '',
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                              // color:
                              //     _getBrandColor(brand['name']!) == Colors.white
                              //         ? null
                              //         : Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  brand.ownername ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: "MontserratM",
                                    fontWeight: FontWeight.bold,
                                    // color: _getBrandColor(brand['name']!) ==
                                    //         Colors.white
                                    //     ? Colors.black
                                    //     : Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getBrandRating(brand.ownername ?? ''),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        // color: _getBrandColor(brand['name']!) ==
                                        //         Colors.white
                                        //     ? Colors.grey
                                        //     : Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getBrandDistance(brand.ownername ?? ''),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    // color: _getBrandColor(brand['name']!) ==
                                    //         Colors.white
                                    //     ? Colors.grey
                                    //     : Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
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
