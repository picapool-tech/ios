import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/functions/partners/partner_controller.dart';
import 'package:picapool/models/partner_model.dart';
import 'package:picapool/screens/Products/products_detailed_page.dart';
import 'package:picapool/screens/Products/view_products_page.dart';
import 'package:url_launcher/url_launcher.dart';

class PlayStationPage extends StatefulWidget {
  final Partner partner;
  const PlayStationPage({
    super.key,
    required this.partner,
  });

  @override
  State<PlayStationPage> createState() => _PlayStationPageState();
}

class _PlayStationPageState extends State<PlayStationPage> {
  final PartnerController _partnerController = Get.find<PartnerController>();

  Widget banner({
    required String? image,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: (image == null)
                ? Image.asset(
                    width: double.infinity,
                    'assets/dominos/OfferImag1.png', // Replace with your offer image asset
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    width: double.infinity,
                    imageUrl: image,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            top: 10,
            right: 10,
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
                  fontFamily: 'MontserratM',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bigBanner() {
    return _showOffers(withoutTop: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 60,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            if (widget.partner.pic == null)
              Image.asset(
                'assets/dominos/logo.jpg', // Replace with your PlayStation logo asset
                width: 30,
                height: 30,
              )
            else
              CachedNetworkImage(
                imageUrl: widget.partner.pic!,
                width: 30,
                height: 30,
              ),
            const SizedBox(width: 8),
            Text(
              widget.partner.ownername ?? '',
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'MontserratM',
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Define what happens when the button is tapped
                      if (widget.partner.link == null) {
                        return;
                      }
                      if (!await launchUrl(Uri.parse(widget.partner.link!))) {
                        Get.snackbar(
                          'Error',
                          'Could not open the link',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFF8D41),
                      // side: BorderSide(color: Color(0xffFF6600)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min, // To minimize the button width
                        children: [
                          Text(
                            'Go to store',
                            style: TextStyle(
                                fontFamily: "MontserratR",
                                fontWeight: FontWeight.bold,
                                color: Color(0xffffffff)),
                          ),
                          SizedBox(width: 5), // Space between text and icon
                          Icon(Icons.arrow_circle_right_outlined,
                              size: 20,
                              color: Color(
                                0xffFFFFFF,
                              )), // Icon with size
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Space between buttons
                Obx(
                  () {
                    if (_partnerController.partner.value == null) {
                      return const SizedBox.shrink();
                    }
                    return Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_partnerController.partner.value == null) {
                            return;
                          }
                          Get.to(
                            () => ViewProductsPage(
                              partnerName: widget.partner.username ?? '',
                              products:
                                  _partnerController.partner.value?.products ??
                                      [],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffFFE9DA),
                          side: const BorderSide(color: Color(0xffFF6600)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize
                                .min, // To minimize the button width
                            children: [
                              Text(
                                'View products',
                                style: TextStyle(
                                    fontFamily: "MontserratR",
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xffFF8D41)),
                              ),
                              // Space between text and icon
                              // Icon with size
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20), // Space between buttons and search bar
            // Search Bar
            // Container(
            //   height: 40,
            //   decoration: BoxDecoration(
            //     color: Colors.grey[200],
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   child: const TextField(
            //     decoration: InputDecoration(
            //       hintText: 'Find Offers and Brands',
            //       hintStyle: TextStyle(
            //         color: Color(0xff000000),
            //         fontFamily: "MontserratR",
            //       ),
            //       prefixIcon: Icon(Icons.search, color: Colors.orange),
            //       border: InputBorder.none,
            //       contentPadding:
            //           EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 20),
            // Offer Banner
            bigBanner(),
            const SizedBox(height: 20),
            // Limited Offers
            _showLimitedOffers()
          ],
        ),
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
    _partnerController.partner.value = null;
  }

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((duration) async {
      await _partnerController.getPartnerById(
        id: widget.partner.id,
        products: true,
        offers: true,
      );

      // partner?.then((vo) {
      //   debugPrint("PARTNER IS : ${vo?.toJson()}");
      // });
    });
  }

  Widget _showLimitedOffers() {
    return Column(
      children: [
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
              "  Limited Offers  ",
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
        const SizedBox(height: 10),
        _showOffers(),
      ],
    );
  }

  Widget _showOffers({
    bool withoutTop = false,
  }) {
    return Obx(() {
      if (_partnerController.partner.value == null) {
        return const SizedBox.shrink();
      }

      final offers = _partnerController.partner.value!.offers;

      if (offers == null || offers.isEmpty) {
        return const SizedBox.shrink();
      }

      var filteredOffers =
          offers.where((offer) => offer.top && !withoutTop).toList();

      if (filteredOffers.isEmpty) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        height: 200,
        child: PageView.builder(
          itemCount: filteredOffers.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final offer = filteredOffers[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: banner(
                image: offer.images.isNotEmpty ? offer.images.first : null,
                onTap: () {
                  // Define what happens when the banner is tapped
                  Get.to(
                    () => OfferDetailsPage(offer: offer),
                  );
                },
              ),
            );
          },
        ),
      );

      // return banner(
      //   image: filteredOffers.images.isNotEmpty ? offers[0].images.first : null,
      //   onTap: () {
      //     // Define what happens when the banner is tapped
      //   },
      // );
    });
  }
}
