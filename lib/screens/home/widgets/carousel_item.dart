import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/screens/Products/products_detailed_page.dart';
import 'package:picapool/utils/theme.dart';

class CarouselItem extends StatelessWidget {
  final Offer offer;
  const CarouselItem({
    super.key,
    required this.offer,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(
        () => OfferDetailsPage(offer: offer),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              // constraints: const BoxConstraints(
              //   maxHeight: 150,
              // ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              clipBehavior: Clip.hardEdge,
              child: (offer.images.isEmpty)
                  ? Image.asset(
                      width: double.infinity,
                      'assets/images/buy_and_sell/no_image.png',
                      fit: BoxFit.fill,
                    )
                  : CachedNetworkImage(
                      width: double.infinity,
                      imageUrl: offer.images.first,
                      fit: BoxFit.fill,
                    ),
            ),
          ),
          if (offer.units != null && offer.maxUnits != null) ...[
            const SizedBox(height: 10),
            Container(
              decoration: roundedContainer().copyWith(
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(10),
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
          ]
        ],
      ),
    );
  }
}
