import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/features/location/location_controller.dart';
import 'package:picapool/features/offers/offers_controller.dart';
import 'package:picapool/features/offers/values/offer_loading_enums.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/screens/products/products_detailed_page.dart';
import 'package:picapool/widgets/loading/carousel_loading.dart';

class CarouselWidget extends StatefulWidget {
  const CarouselWidget({super.key});

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  final OffersController _offerController = Get.find<OffersController>();
  final LocationController _locationController = Get.find<LocationController>();

  List<String> images = [
    'assets/carousel/image1.png',
    'assets/carousel/image2.png',
    'assets/carousel/image3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        var isLoading =
            _offerController.getLoadingState(OfferLoadingEnums.carousel).value;

        if (_offerController.carouselOffer.isEmpty && isLoading) {
          return const CarouselLoading();
        }

        if (_offerController.carouselOffer.isEmpty) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).primaryColor.withAlpha(150),
              image: const DecorationImage(
                image: AssetImage("assets/images/coming_soon.png"),
                fit: BoxFit.fitHeight,
              ),
            ),
          );
        }

        return carousel(_offerController.carouselOffer);
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
    // var color = determineColor(offer.units, offer.maxUnits);
    return InkWell(
      onTap: () => Get.to(
        () => OfferDetailsPage(offer: offer),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: const BoxConstraints(
              maxHeight: 150,
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
                  TweenAnimationBuilder<double>(
                    tween:
                        Tween<double>(begin: 0.0, end: offer.units!.toDouble()),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: ((value) / offer.maxUnits!),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.red),
                      backgroundColor: Colors.red[100],
                      borderRadius: BorderRadius.circular(5),
                      minHeight: 10,
                    ),
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
                        "${offer.units!}/${offer.maxUnits} units",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
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

    WidgetsBinding.instance.addPostFrameCallback((duration) async {
      if (!await _locationController.isLocationEnabled()) {
        return;
      }
      _offerController.getCarasouelOffer();
    });

    ever(
      _locationController.state,
      (LocationState state) async {
        if (!await _locationController.isLocationEnabled()) {
          return;
        }
        if (state.location != null &&
            !_offerController
                .getLoadingState(OfferLoadingEnums.carousel)
                .value) {
          _offerController.getCarasouelOffer();
        }
      },
    );
  }
}
