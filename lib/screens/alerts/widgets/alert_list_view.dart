import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/features/chats/extension/offer_chat_extension.dart';
import 'package:picapool/features/offers/offers_controller.dart';
import 'package:picapool/features/offers/values/offer_loading_enums.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/screens/alerts/widgets/alert_item.dart';
import 'package:picapool/widgets/loading/offer_loading.dart';

class AlertsList extends StatefulWidget {
  final int selectedCategory;
  final OffersController offersController;

  const AlertsList({
    Key? key,
    required this.selectedCategory,
    required this.offersController,
  }) : super(key: key);

  @override
  State<AlertsList> createState() => _AlertsListState();
}

class _AlertsListState extends State<AlertsList> {
  List<bool> expandedStates = [];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OffersController>(
      init: widget.offersController,
      builder: (controller) {
        // Get correct offers list based on selected category
        final offers = _getOffersForCategory(controller);

        // Handle loading and empty states
        if (offers == null) {
          return const Center(child: Text("No offers"));
        }

        if (offers.isEmpty && controller.isLoading.value) {
          return const OfferLoading();
        }

        if (offers.isEmpty) {
          return const Center(child: Text("No offers"));
        }

        // Initialize expanded states if needed
        if (expandedStates.length != offers.length) {
          expandedStates = List<bool>.filled(offers.length, false);
        }

        // Render offer list
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            return AlertListItem(
              offer: offers[index],
              isExpanded: expandedStates[index],
              onTap: () => _toggleExpanded(index),
              onJoinChat: () => _joinChat(offers[index]),
              isLoading:
                  controller.getLoadingState(OfferLoadingEnums.fetchingChat),
            );
          },
        );
      },
    );
  }

  List<Offer>? _getOffersForCategory(OffersController controller) {
    if (widget.selectedCategory == 0) {
      return controller.offers;
    } else {
      return controller.offersByTagId[widget.selectedCategory];
    }
  }

  void _joinChat(Offer offer) async {
    // Chat joining functionality moved from main class
    Get.find<ChatController>().joinOfferChat(offer);
  }

  void _toggleExpanded(int index) {
    setState(() {
      expandedStates[index] = !expandedStates[index];
    });
  }
}
