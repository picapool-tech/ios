import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picapool/functions/offers/offers_controller.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/utils/date_time_helper.dart';
import 'package:picapool/utils/svg_icon.dart';

enum PoolingStatus { active, completed, notActive }

class PoolingHistory extends StatefulWidget {
  const PoolingHistory({super.key});

  @override
  State<PoolingHistory> createState() => _PoolingHistoryState();
}

class _PoolingHistoryState extends State<PoolingHistory> {
  final TextEditingController _searchController = TextEditingController();
  final OffersController _offersController = Get.find<OffersController>();

  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _offersController.getAllUsersOffer();
    _searchController.addListener(searchStarted);
  }

  void searchStarted() {
    setState(() {
      searchQuery = _searchController.text;
    });
  }

  /// Determines the pooling status based on the expiry date.
  PoolingStatus _determinePoolingStatus(DateTime expiryAt) {
    final currentTime = DateTime.now();
    if (expiryAt.isAfter(currentTime)) {
      return PoolingStatus.active;
    } else if (expiryAt.isBefore(currentTime)) {
      return PoolingStatus.completed;
    } else {
      return PoolingStatus.notActive;
    }
  }

  /// Retrieves the color associated with the pooling status.
  Color _getColorForStatus(PoolingStatus status) {
    const Map<PoolingStatus, Color> poolingStatusColors = {
      PoolingStatus.active: Color(0xffFF8D41), // Orange
      PoolingStatus.completed: Colors.green,
      PoolingStatus.notActive: Colors.grey,
    };
    return poolingStatusColors[status] ?? Colors.black;
  }

  /// Builds a tag widget based on the pooling status.
  Widget _buildTag(PoolingStatus status) {
    String label;
    switch (status) {
      case PoolingStatus.active:
        label = "Active";
        break;
      case PoolingStatus.completed:
        label = "Completed";
        break;
      case PoolingStatus.notActive:
      default:
        label = "Not Active";
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: _getColorForStatus(status),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ).paddingSymmetric(horizontal: 4, vertical: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff02005D),
      appBar: AppBar(
        title: const Text(
          'Pooling History',
          style: TextStyle(
            fontFamily: "MontserratM",
            fontSize: 24,
            color: Color(0xffFFFFFF),
          ),
        ),
        automaticallyImplyLeading: true,
        elevation: 0,
        backgroundColor: const Color(0xff02005D),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          // Search Bar remains unchanged
          Container(
              height: 63,
              color: const Color(0xff02005D),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xff797979), width: 2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                    child: SearchBar(
                      elevation: WidgetStateProperty.resolveWith<double>(
                          (Set<WidgetState> states) => 0.0),
                      hintText: "Search",
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) =>
                            const Color(0xff9A9A9A).withOpacity(0.2),
                      ),
                      controller: _searchController,
                      hintStyle: WidgetStateProperty.resolveWith<TextStyle?>(
                        (Set<WidgetState> states) {
                          return GoogleFonts.montserrat(
                              color: const Color(0xffFFFFFF),
                              fontSize: 14,
                              fontWeight: FontWeight.w300);
                        },
                      ),
                      textStyle: WidgetStateProperty.resolveWith<TextStyle?>(
                        (Set<WidgetState> states) {
                          return GoogleFonts.montserrat(
                              color: const Color(0xffFFFFFF),
                              fontSize: 14,
                              fontWeight: FontWeight.w300);
                        },
                      ),
                      leading: const Padding(
                        padding: EdgeInsets.fromLTRB(9, 0, 4, 0),
                        child: SvgIcon(
                          "assets/icons/search.svg",
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 10),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                color: Colors.white,
              ),
              width: Size.infinite.width,
              padding: const EdgeInsets.all(18),
              child: GetBuilder<OffersController>(
                  init: _offersController,
                  builder: (controller) {
                    if (controller.poolingOffers.isEmpty &&
                        controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.poolingOffers.isEmpty) {
                      return const Center(
                        child: Text("No pooling history available"),
                      );
                    }

                    var filteredOffer = controller.poolingOffers.where((model) {
                      var offername = model.name;
                      var searchList =
                          searchQuery.trim().toLowerCase().split(" ");
                      for (var element in searchList) {
                        if (offername.toLowerCase().contains(element)) {
                          return true;
                        }
                      }
                      return false;
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredOffer.length,
                      itemBuilder: (context, index) {
                        return _buildOfferCard(filteredOffer[index]);
                      },
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(Offer offer) {
    final poolingStatus = _determinePoolingStatus(offer.expiryAt);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _getColorForStatus(poolingStatus)),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Offer Icon or Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
            ),
            clipBehavior: Clip.hardEdge,
            child: (offer.images.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: offer.images.first,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    fit: BoxFit.cover,
                  )
                : Image.asset("assets/images/request_vicinity.png"),
            // Image.network(
            //   offer.images.first,
            //   fit: BoxFit.cover,
            //   // placeholder: (context, url) =>
            //   //     Image.asset("assets/images/placeholder.png"),
            //   // errorWidget: (context, url, error) => const Icon(Icons.error),
            // ),
          ),
          const SizedBox(width: 16.0),
          // Offer Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.name.replaceAll("- FROM BRANDS", ""),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: "MontserratM",
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTag(poolingStatus),
                    Text(
                      DateTimeHelper.timeAgoSince(
                          offer.expiryAt.toIso8601String()),
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
