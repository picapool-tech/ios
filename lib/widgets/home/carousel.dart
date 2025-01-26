import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/functions/location/location_provider.dart';
import 'package:picapool/functions/offers/offers_controller.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/screens/Products/products_detailed_page.dart';
import 'package:picapool/utils/theme.dart';

class CarouselWidget extends StatefulWidget {
  const CarouselWidget({super.key});

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget>
    with TickerProviderStateMixin {
  // List<String> images = [
  //   'assets/carousel/image1.png',
  //   'assets/carousel/image2.png',
  //   'assets/carousel/image3.png',
  // ];
  final OffersController _offerController = Get.find<OffersController>();
  final LocationController _locationController = Get.find<LocationController>();

  List<String> images = [
    'assets/carousel/image1.png',
    'assets/carousel/image2.png',
    'assets/carousel/image3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OffersController>(
      init: _offerController,
      builder: (controller) {
        if (_offerController.carouselOffer.isEmpty &&
            _offerController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_offerController.carouselOffer.isEmpty) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: appTheme.primaryColor.withAlpha(150),
              image: const DecorationImage(
                image: AssetImage("assets/images/coming_soon.png"),
                fit: BoxFit.fitHeight,
              ),
            ),
          );
        }

        return carousel(controller.carouselOffer);
      },
    );
  }

  CarouselSlider carousel(List<Offer> offers) {
    return CarouselSlider.builder(
      itemCount: offers.length,
      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
        var offer = offers[itemIndex];
        debugPrint("Offer in carousel: ${offer.toJson()}");
        return carouselItem(offer);
      },
      options: CarouselOptions(
        height: 250,
        viewportFraction: 1.0,
        initialPage: 0,
        enableInfiniteScroll: false,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        enlargeFactor: 0.25,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget carouselItem(Offer offer) {
    log("Offer in carousel: ${offer.toJson()}");
    var color = determineColor(offer.units, offer.maxUnits);
    return InkWell(
      onTap: () => Get.to(
        () => OfferDetailsPage(offer: offer),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: const BoxConstraints(
              maxHeight: 180,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            clipBehavior: Clip.hardEdge,
            child: (offer.images.isEmpty)
                ? Image.asset(
                    width: double.infinity,
                    images[0],
                    fit: BoxFit.fill,
                  )
                : CachedNetworkImage(
                    width: double.infinity,
                    imageUrl: offer.images.first,
                    fit: BoxFit.fill,
                  ),
          ),
          const SizedBox(height: 10),
          if (offer.units != null || offer.maxUnits != null)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
                bottom: 5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LinearProgressIndicator(
                    value: (offer.units! / offer.maxUnits!),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    backgroundColor: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                    minHeight: 10,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Only for first ${offer.maxUnits} units",
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "${offer.maxUnits! - offer.units!}/${offer.maxUnits} left",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color determineColor(int? units, int? maxUnits) {
    if (units == null || maxUnits == null) {
      return Colors.grey;
    }

    if (units == 0 || units < maxUnits / 2) {
      return Colors.green;
    }

    if (units == maxUnits) {
      return Colors.red;
    }

    return Colors.orange;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((duration) {
      _offerController.getCarasouelOffer();
    });

    ever(
      _locationController.state,
      (LocationState state) {
        if (state.location != null && !_offerController.isLoading.value) {
          _offerController.getCarasouelOffer();
        }
      },
    );
  }
}
