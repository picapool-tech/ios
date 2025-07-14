import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/features/offers/offers_controller.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/product_model.dart';
import 'package:picapool/screens/buy_and_sell/features/buy_products/widgets/image_with_top_widgets.dart';
import 'package:picapool/screens/buy_and_sell/features/product_details/product_details.dart';
import 'package:picapool/utils/date_time_helper.dart';
import 'package:picapool/utils/theme.dart';

class NearbyProductsItem extends StatelessWidget {
  final Product product;
  final Offer offer;
  const NearbyProductsItem({
    super.key,
    required this.product,
    required this.offer,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        var offersController = Get.find<OffersController>();
        Get.to(
          () => ProductDetails(
            product: product,
            offer: offer,
            offersController: offersController,
          ),
        );
      },
      child: Card(
        elevation: product.isProductSold() ? 0 : 1,
        color: AppTheme.currentTheme.scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageWithTopWidgets(
                imageUrl: product.images.firstOrNull,
                timeSinceAgo: DateTimeHelper.timeAgoSince(
                  product.createdAt.toIso8601String(),
                ),
                isSold: product.isProductSold(),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(
                height: 4,
              ),
              RichText(
                text: TextSpan(
                  text: '₹ ${product.price ?? product.mrp ?? "N/A"}',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(decoration: TextDecoration.lineThrough),
                  children: [
                    // if (product.offerPrice != null)
                    TextSpan(
                      text: " ${offer.price ?? product.offerPrice ?? "N/A"}",
                      style: const TextStyle(
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
