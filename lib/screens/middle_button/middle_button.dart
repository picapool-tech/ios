import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picapool/features/location/location_controller.dart';
import 'package:picapool/features/offers/offers_controller.dart';
import 'package:picapool/features/offers/values/offer_loading_enums.dart';
import 'package:picapool/models/tag_model.dart';
import 'package:picapool/models/vicinity_offer_model.dart';
import 'package:picapool/screens/public_chat/chat_page.dart';
import 'package:picapool/screens/vicinity/values/map_style.dart';
import 'package:picapool/utils/date_time_helper.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/home/divider.dart';
import 'package:picapool/widgets/loading/offer_loading.dart';

// OfferContainer widget
class OfferContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final String timeAgo;
  final String countdown;
  final IconData icon;
  final List<Tag> tags;

  const OfferContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.countdown,
    required this.icon,
    required this.tags,
  });

  Widget bottomLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: (tags.isEmpty)
              ? Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                )
              : Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: tags.first.icon,
                      width: 13,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text(
                        tags.first.tag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontFamily: "MontserratM",
                        ),
                      ),
                    ),
                  ],
                ),
        ),

        const SizedBox(width: 10), // Added spacing
        Row(
          children: [
            const Icon(
              Icons.access_time,
              color: Colors.orange,
              size: 14,
            ),
            const SizedBox(width: 5),
            Text(
              countdown,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: "MontserratM",
                  ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: roundedContainer().copyWith(
        border: Border.all(color: Colors.grey.shade300),
        color: AppTheme.currentTheme.colorScheme.surface,
      ),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          // title and description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                topLayout(context),
                const SizedBox(
                  height: 10,
                ),
                bottomLayout(context),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          // icon
          const CircleAvatar(
            radius: 14,
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.orange,
              size: 14,
            ),
          ),
        ],
      ),
    );
    //   Padding(
    //     padding: const EdgeInsets.symmetric(vertical: 8.0),
    //     child: Container(
    //       height: 92,
    //       padding: const EdgeInsets.all(16.0),
    //       decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(20),
    //         border: Border.all(color: Colors.grey.shade300),
    //       ),
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //           Expanded(
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Row(
    //                   children: [
    //                     Expanded(
    //                       child: Text(
    //                         title.replaceAll("- FROM BRANDS", ""),
    //                         overflow: TextOverflow.ellipsis,
    //                         style: const TextStyle(
    //                           fontWeight: FontWeight.bold,
    //                           fontSize: 18,
    //                           fontFamily: "MontserratM",
    //                         ),
    //                       ),
    //                     ),
    //                     const SizedBox(
    //                       width: 8,
    //                     ),
    //                     Text(
    //                       timeAgo,
    //                       style: const TextStyle(
    //                         color: Colors.grey,
    //                         fontFamily: "MontserratM",
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //                 const SizedBox(height: 8),
    //                 Row(
    //                   children: [
    //                     Expanded(
    //                       child: FutureBuilder<Tag?>(
    //                           future: getTag(),
    //                           builder: (context, snapshot) {
    //                             if (snapshot.hasData) {
    //                               var tag = snapshot.data;
    //                               if (tag != null) {
    //                                 return Row(
    //                                   children: [
    //                                     Icon(icon, color: Colors.orange),
    //                                     const SizedBox(width: 5),
    //                                     Expanded(
    //                                       child: Text(
    //                                         tag.tag,
    //                                         maxLines: 1,
    //                                         overflow: TextOverflow.ellipsis,
    //                                         style: const TextStyle(
    //                                           color: Colors.grey,
    //                                           fontFamily: "MontserratM",
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 );
    //                               }
    //                             }

    //                             return Text(
    //                               subtitle,
    //                               maxLines: 1,
    //                               overflow: TextOverflow.ellipsis,
    //                               style: const TextStyle(
    //                                 color: Colors.grey,
    //                                 fontFamily: "MontserratM",
    //                               ),
    //                             );
    //                           }),
    //                     ),
    //                     const SizedBox(width: 10), // Added spacing
    //                     Expanded(
    //                       child: Row(
    //                         children: [
    //                           const Icon(Icons.access_time, color: Colors.orange),
    //                           const SizedBox(width: 5),
    //                           Text(
    //                             countdown,
    //                             style: const TextStyle(
    //                               fontWeight: FontWeight.bold,
    //                               fontFamily: "MontserratM",
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ],
    //             ),
    //           ),
    //           const CircleAvatar(
    //             radius: 15,
    //             backgroundColor: Colors.orange,
    //             child:
    //                 Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
  }

  Widget topLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title.replaceAll("- FROM BRANDS", ""),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: "MontserratM",
                ),
          ),
        ),
        Text(
          timeAgo,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class PoolOffersScreen extends StatefulWidget {
  const PoolOffersScreen({super.key});

  @override
  State<PoolOffersScreen> createState() => _PoolOffersScreenState();
}

class _PoolOffersScreenState extends State<PoolOffersScreen> {
  LatLng _center = const LatLng(0, 0);
  late GoogleMapController mapController;
  final OffersController _offersController = Get.find<OffersController>();
  final LocationController _locationController = Get.find<LocationController>();

  final List<Marker> markers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: const PreferredSize(
          preferredSize: Size(double.infinity, kBottomNavigationBarHeight),
          child: ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
            clipBehavior: Clip.hardEdge,
            child: CustomDivider(
              text: "Pools near me",
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Google Map Sectionx
            Positioned.fill(
              child: GoogleMap(
                style: (Theme.of(context).brightness == Brightness.dark)
                    ? MapStyle().getDarkModeJson
                    : null,
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 14.0,
                ),
                myLocationEnabled: true,
                markers: {
                  Marker(
                    markerId: const MarkerId('1'),
                    position: _center,
                    infoWindow: const InfoWindow(
                      title: 'Your location',
                      snippet: 'You are here',
                    ),
                  ),
                  ...markers,
                },
                circles: {
                  Circle(
                    circleId: const CircleId('1'),
                    center: _center,
                    radius: 1000,
                    fillColor: Colors.blue.withOpacity(0.1),
                    strokeColor: Colors.blue,
                    strokeWidth: 2,
                  ),
                },
              ),
            ),
            // Pools found container
            // Positioned(
            //   bottom: 350,
            //   right: 16,
            //   child: Container(
            //     padding: const EdgeInsets.all(12),
            //     decoration: BoxDecoration(
            //       color: AppTheme.currentTheme.canvasColor,
            //       borderRadius: BorderRadius.circular(15),
            //       boxShadow: [
            //         BoxShadow(
            //           color: Colors.black.withOpacity(0.1),
            //           spreadRadius: 2,
            //           blurRadius: 4,
            //         ),
            //       ],
            //     ),
            //     child: Column(
            //       children: [
            //         const Text(
            //           'Pools found',
            //           style: TextStyle(
            //             color: Colors.grey,
            //           ),
            //         ),
            //         const SizedBox(height: 4),
            //         Obx(() {
            //           return Text(
            //             _offersController.nearestOffers.length.toString(),
            //             style: const TextStyle(
            //               fontSize: 28,
            //               fontWeight: FontWeight.bold,
            //               color: Colors.orange,
            //               fontFamily: "MontserratM",
            //             ),
            //           );
            //         }),
            //       ],
            //     ),
            //   ),
            // ),
            // Top Container with Dividers and 'Pools near me' Text
          ],
        ),
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.currentTheme.canvasColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pools found',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Obx(
              () {
                if (_offersController
                    .getLoadingState(OfferLoadingEnums.middleButton)
                    .value) {
                  return const CircularProgressIndicator();
                }
                return Text(
                  _offersController.nearestOffers.length.toString(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
      bottomSheet: DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.9,
        snap: false,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppTheme.currentTheme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gray container with divider and prefix icon
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Colors.orange,
                        indent: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_offer, color: Colors.orange),
                            SizedBox(width: 8),
                            Text(
                              'All Offers',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: "MontserratM",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: Colors.orange,
                        indent: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: GetBuilder<OffersController>(
                      init: _offersController,
                      builder: (controller) {
                        if (controller.nearestOffers.isEmpty &&
                            controller.isLoading.value) {
                          return const OfferLoading();
                        }

                        if (controller.nearestOffers.isEmpty) {
                          return const Center(
                            child: Text("No offers available"),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: controller.nearestOffers.length,
                          padding: const EdgeInsets.only(bottom: 10),
                          itemBuilder: (context, index) {
                            var offer = controller.nearestOffers[index];

                            return InkWell(
                              onTap: () {
                                // Navigate to offer details
                                if (offer.chats?.first == null) {
                                  Get.snackbar(
                                    "No chat found",
                                    "Not chat found for offer ${offer.name}",
                                  );
                                  return;
                                }
                                Get.to(
                                  () => ChatPage(
                                    chat: offer.chats!.first,
                                    chatTitle: offer.name,
                                    offer: offer,
                                  ),
                                );
                              },
                              child: OfferContainer(
                                title: offer.name,
                                subtitle: offer.desc,
                                timeAgo: DateTimeHelper.timeAgoSince(
                                    offer.createdAt.toIso8601String()),
                                countdown: DateTimeHelper.formatDateTimeExpiry(
                                  offer.expiryAt,
                                ),
                                icon: Icons.checkroom,
                                tags: offer.tags ?? [],
                              ),
                            );
                          },
                        );
                      }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void createMarkersWithOffer() {
    // Create markers with offers
    for (var offer in _offersController.nearestOffers) {
      markers.add(
        Marker(
          markerId: MarkerId(offer.id.toString()),
          position: LatLng(
            offer.location!.lat,
            offer.location!.long,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: offer.name,
            snippet: offer.desc,
          ),
        ),
      );
    }

    setState(() {
      markers;
    });
  }

  Future<void> fetchLocation() async {
    if (_locationController.state.value.location == null) {
      debugPrint("FETCHING LOCATION");
      await _locationController.getLocation();
      updateCenter();
    } else {
      updateCenter();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLocation();
    WidgetsBinding.instance.addPostFrameCallback((duration) async {
      if (_locationController.state.value.location != null) {
        debugPrint("MAP IS UPDATED: WITH LOCATION : $_center");

        await _offersController.getOffersInVicinity(
          location: VicinityLocation(
            lat: _center.latitude,
            long: _center.longitude,
          ),
        );

        createMarkersWithOffer();
      }
    });
  }

  void updateCenter() {
    if (_locationController.state.value.location != null) {
      debugPrint(
          "UPDATING CENTER : ${_locationController.state.value.location}");
      setState(() {
        _center = LatLng(
          _locationController.state.value.location!.latitude,
          _locationController.state.value.location!.longitude,
        );
      });
    } else {
      debugPrint("Location is null");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
}
