import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/features/offers/offers_controller.dart';
import 'package:picapool/features/offers/values/offer_loading_enums.dart';
import 'package:picapool/features/tags/tag_controller.dart';
import 'package:picapool/screens/buy_and_sell/features/buy_products/widgets/empty_states.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/user_item_listing_item.dart';

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

            return UserItemListingItem(offer: offer, product: product);
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
