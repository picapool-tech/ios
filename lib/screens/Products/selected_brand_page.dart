import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/common/widgets/carousel_widget.dart';
import 'package:picapool/features/partners/partner_controller.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/partner_model.dart';
import 'package:picapool/screens/products/products_detailed_page.dart';
import 'package:picapool/screens/products/view_products_page.dart';
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
  final CarouselControllerImpl _bigBannerCaouselController =
      CarouselControllerImpl();

  Widget banner({
    required String? image,
    required VoidCallback onTap,
    double? height,
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
                    height: height,
                  )
                : Hero(
                    tag: image,
                    child: CachedNetworkImage(
                      width: double.infinity,
                      imageUrl: image,
                      height: height,
                      fit: BoxFit.cover,
                    ),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
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
              "  Offers  ",
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
        _showOffers(
          withoutTop: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Row(
          children: [
            if (widget.partner.pic == null)
              Image.asset(
                'assets/dominos/logo.jpg', // Replace with your PlayStation logo asset
                width: 30,
                height: 30,
              )
            else
              Hero(
                tag: widget.partner.id,
                child: CachedNetworkImage(
                  imageUrl: widget.partner.pic!,
                  width: 30,
                  height: 30,
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Text(
              widget.partner.ownername ?? '',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (_partnerController.isLoading.value &&
              _partnerController.partner.value == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_partnerController.partner.value == null &&
              !_partnerController.isLoading.value) {
            return const Center(
              child: Text("No data found"),
            );
          }

          return showProductInfo();
        }),
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
    });
  }

  Column showProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: PicaPrimaryButton(
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
                text: "Go to store",
                isLoading: false.obs,
              ),
            ),
            const SizedBox(width: 8), // Space between buttons

            Expanded(
              child: PicaOutlineButton(
                onPressed: () async {
                  if (_partnerController.partner.value == null) {
                    Get.snackbar(widget.partner.username ?? "No products",
                        "No products available at this time.");
                    return;
                  }

                  Get.to(
                    () => ViewProductsPage(
                      partnerName: widget.partner.username ?? '',
                      products:
                          _partnerController.partner.value?.products ?? [],
                    ),
                  );
                },
                text: "View products",
                isLoading: false.obs,
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: const Color(0xffFFE9DA),
                //   side: const BorderSide(color: Color(0xffFF6600)),
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   padding: const EdgeInsets.symmetric(vertical: 10),
                // ),
                // child: const Padding(
                //   padding: EdgeInsets.symmetric(
                //     horizontal: 10.0,
                //   ),
                //   child: Row(
                //     mainAxisSize:
                //         MainAxisSize.min, // To minimize the button width
                //     children: [
                //       Text(
                //         'View products',
                //         style: TextStyle(
                //           fontFamily: "MontserratR",
                //           fontWeight: FontWeight.bold,
                //           color: Color(0xffFF8D41),
                //         ),
                //       ),
                //       // Space between text and icon
                //       // Icon with size
                //     ],
                //   ),
                // ),
              ),
            )
          ],
        ),
        const SizedBox(height: 20), // Space between buttons and search bar

        if (_partnerController.getPartner?.offers != null &&
            _partnerController.getPartner!.offers!.isNotEmpty) ...[
          _showLimitedOffers(),
          const SizedBox(height: 20),
          bigBanner(),
        ]
        // Limited Offers
      ],
    );
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
      final offers = _partnerController.partner.value!.offers;

      if (offers == null || offers.isEmpty) {
        return const Text("No offers available at this time.");
      }

      final filteredOffers = withoutTop
          ? offers.where((offer) => offer.top == false).toList()
          : offers.where((offer) => offer.top == true).toList();

      if (filteredOffers.isEmpty) {
        return const Text("No offers at this time.");
      }
      debugPrint("Filtered Offers: ${filteredOffers.length}");

      if (withoutTop) {
        return ListView.builder(
          itemCount: filteredOffers.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final offer = filteredOffers[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
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
        );
      } else {
        return CarouseldWiget(
            count: filteredOffers.length,
            height: 340,
            itemBuilder: (context, index, realindex) {
              Offer offer = filteredOffers[index];
              return banner(
                image: offer.images.last,
                height: 400,
                onTap: () {
                  // Define what happens when the banner is tapped
                  Get.to(
                    () => OfferDetailsPage(offer: offer),
                  );
                },
              );
            });
      }

      // SizedBox(
      //   width: double.infinity,
      //   height: 200,
      //   child: CarouselSlider.builder(
      //     itemCount: filteredOffers.length,
      //     options: CarouselOptions(
      //       autoPlay: true,
      //       enlargeCenterPage: true,
      //       viewportFraction: 1,
      //       aspectRatio: 1.0,
      //       onPageChanged: (index, reason) => onPageChange?.call(index),
      //     ),
      //     carouselController: carouselController,
      //     itemBuilder: (context, index, realIndex) {
      //       final offer = filteredOffers[index];
      //       return Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //         child: banner(
      //           image: offer.images.isNotEmpty ? offer.images.first : null,
      //           onTap: () {
      //             // Define what happens when the banner is tapped
      //             Get.to(
      //               () => OfferDetailsPage(offer: offer),
      //             );
      //           },
      //         ),
      //       );
      //     },
      //   ),
      // const SizedBox(height: 10),
      // Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: filteredOffers.asMap().entries.map((entry) {
      //     return GestureDetector(
      //       onTap: () => _carouselController.animateToPage(entry.key),
      //       child: Container(
      //         width: 8.0,
      //         height: 8.0,
      //         margin:
      //             const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      //         decoration: BoxDecoration(
      //           shape: BoxShape.circle,
      //           color: (Theme.of(context).brightness == Brightness.dark
      //                   ? Colors.white
      //                   : Colors.black)
      //               .withOpacity(_current == entry.key ? 0.9 : 0.4),
      //         ),
      //       ),
      //     );
      //   }).toList(),
      // ),
      // );

      // return banner(
      //   image: filteredOffers.images.isNotEmpty ? offers[0].images.first : null,
      //   onTap: () {
      //     // Define what happens when the banner is tapped
      //   },
      // );
    });
  }
}
