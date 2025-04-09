import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/screens/home/widgets/carousel_item.dart';

class CarouselWidgetView extends StatelessWidget {
  final List<Offer> offers;
  const CarouselWidgetView({
    super.key,
    required this.offers,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: offers.length,
      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
        var offer = offers[itemIndex];
        debugPrint("${offer.id} : ${offer.name}");
        return CarouselItem(offer: offer);
      },
      options: CarouselOptions(
        viewportFraction: 1,
        initialPage: 0,
        aspectRatio: 16 / 9,
        enableInfiniteScroll: false,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        enlargeFactor: 0.9,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
