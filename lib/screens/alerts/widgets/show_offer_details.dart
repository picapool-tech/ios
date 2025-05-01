import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/features/offers/offers_controller.dart';
import 'package:picapool/features/offers/values/offer_loading_enums.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/screens/alerts/widgets/alert_item.dart';
import 'package:picapool/screens/public_chat/chat_page.dart';

class ShowOfferDetails extends StatefulWidget {
  final int offerId;
  const ShowOfferDetails({
    super.key,
    required this.offerId,
  });

  @override
  State<ShowOfferDetails> createState() => _ShowOfferDetailsState();
}

class _ShowOfferDetailsState extends State<ShowOfferDetails> {
  final OffersController _offersController = Get.find<OffersController>();

  Offer? offer;
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_offersController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (_offersController.offerDetails.value == null) {
        return const Center(
          child: Text('No offer details available'),
        );
      }

      var offer = _offersController.offerDetails.value!;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Yay! you've found a new offer",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          AlertListItem(
            offer: offer,
            isExpanded: isExpanded,
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            onJoinChat: () async {
              try {
                Chat? chat = await _offersController.getChatFromOfferId(
                  offerId: widget.offerId,
                );

                if (chat != null) {
                  // Get.back();
                  log("Chat found: ${chat.id}");
                  await navigator?.push(
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        chat: chat,
                        chatTitle: offer.name,
                        offer: offer,
                      ),
                    ),
                  );
                  log("Get.to executed");
                }
              } catch (e) {
                log("Error found here $e");
              }
            },
            isLoading: _offersController
                .getLoadingState(OfferLoadingEnums.fetchingChat),
          ),
        ],
      );
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _offersController.getOfferDetails(widget.offerId);
    });
  }
}
