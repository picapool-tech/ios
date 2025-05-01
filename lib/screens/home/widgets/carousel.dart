import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/features/location/location_controller.dart';
import 'package:picapool/features/offers/offers_controller.dart';
import 'package:picapool/features/offers/values/offer_loading_enums.dart';
import 'package:picapool/screens/home/widgets/carousel_view.dart';
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

        return CarouselWidgetView(offers: _offerController.carouselOffer);
      },
    );
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
