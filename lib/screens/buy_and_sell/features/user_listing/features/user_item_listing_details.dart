import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/dialog_widgets.dart';
import 'package:picapool/features/offers/offers_controller.dart';
import 'package:picapool/features/offers/values/offer_loading_enums.dart';
import 'package:picapool/features/tags/tag_controller.dart';
import 'package:picapool/screens/buy_and_sell/features/buy_products/widgets/empty_states.dart';
import 'package:picapool/screens/buy_and_sell/features/product_details/product_details.dart';
import 'package:picapool/utils/theme.dart';

class UserItemListingDetails extends StatefulWidget {
  const UserItemListingDetails({super.key});

  @override
  State<UserItemListingDetails> createState() => _UserItemListingDetailsState();
}

class _UserItemListingDetailsState extends State<UserItemListingDetails> {
  final OffersController _controller = Get.find<OffersController>();
  final TagController _tagController = Get.find<TagController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OffersController>(
      init: _controller,
      builder: (controller) {
        if (_controller.poolingOffers.isEmpty &&
            _controller
                .getLoadingState(OfferLoadingEnums.poolingHistory)
                .value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (_controller.poolingOffers.isEmpty) {
          return Container(
            height: Get.size.height * 0.5,
            alignment: Alignment.topCenter,
            child: const EmptyStates(
              customMessage: "You've not listed any products",
            ),
          );
        }

        var offers = _controller.poolingOffers.value;
        var tagId = _tagController.getTagsByTagName("buy")?.id;
        tagId ??= 3;

        var buyOffers = offers
            .where((offer) => offer.tags?.firstOrNull?.id == tagId)
            .toList();

        return ListView.builder(
          itemCount: buyOffers.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          primary: false,
          itemBuilder: (context, index) {
            var offer = buyOffers[index];
            var product = offer.products!.first;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExpansionTile(
                  title: Text(offer.name),
                  subtitle: Text(
                      '₹${offer.products!.first.offerPrice!.toStringAsFixed(2)}'),
                  childrenPadding: const EdgeInsets.all(5),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor:
                      AppTheme.currentTheme.scaffoldBackgroundColor,
                  collapsedBackgroundColor:
                      AppTheme.currentTheme.scaffoldBackgroundColor,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.description),
                          const SizedBox(height: 8.0),
                          Text(
                              'Condition: ${product.attributes?['productCondition']}'),
                          const SizedBox(height: 8.0),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Get.to(
                                  () => ProductDetails(
                                    product: product,
                                    offer: offer,
                                    offersController: controller,
                                  ),
                                );
                              },
                              child: const Text("More details"),
                            ),
                          ),
                          Center(
                            child: FilledButton(
                              onPressed: (!offer.isOfferExpired())
                                  ? () async {
                                      showPicaLoadingDialog();
                                      var updatedOffer =
                                          await _controller.updateOffer(
                                              updatedOffer: offer.copyWith(
                                                  expiryAt: DateTime.now()));
                                      hidePicaDialog();
                                      if (updatedOffer != null) {
                                        await _controller
                                            .getAllUserCreatedOffer();
                                      }
                                    }
                                  : null,
                              child: (offer.isOfferExpired())
                                  ? const Text("PRODUCT SOLD")
                                  : const Text("Mark product as sold"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0), // Added space after each item
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.getAllUserCreatedOffer();
    });
  }
}
