import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picapool/functions/location/location_provider.dart';
import 'package:picapool/functions/offers/offers_controller.dart';
import 'package:picapool/models/vicinity_offer_model.dart';
import 'package:picapool/utils/date_time_helper.dart';

class PoolOffersScreen extends StatefulWidget {
  const PoolOffersScreen({super.key});

  @override
  _PoolOffersScreenState createState() => _PoolOffersScreenState();
}

class _PoolOffersScreenState extends State<PoolOffersScreen> {
  LatLng _center = const LatLng(0, 0);
  late GoogleMapController mapController;
  final OffersController _offersController = Get.find<OffersController>();
  final LocationController _locationController = Get.find<LocationController>();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
        _offersController.getOffersInVicinity(
          location: VicinityLocation(
            lat: _center.latitude,
            long: _center.longitude,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Google Map Sectionx
            Positioned.fill(
              child: GoogleMap(
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
            Positioned(
              bottom: 350,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                  children: [
                    const Text(
                      'Pools found',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: "MontserratM",
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() {
                      return Text(
                        _offersController.nearestOffers.length.toString(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontFamily: "MontserratM",
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Top Container with Dividers and 'Pools near me' Text
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.orange.withOpacity(0.6),
                        thickness: 1,
                        endIndent: 8,
                      ),
                    ),
                    const Text(
                      'Pools near me',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "MontserratM",
                        color: Colors.black,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.orange.withOpacity(0.6),
                        thickness: 1,
                        indent: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Container with Offers List
            // Positioned(
            //   bottom: 0,
            //   left: 0,
            //   right: 0,
            //   child:

            // ),
          ],
        ),
      ),
      bottomSheet: BottomSheet(
          onClosing: () {},
          showDragHandle: false,
          constraints: const BoxConstraints(maxHeight: 320),
          builder: (context) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                            color: Colors.grey.shade200,
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
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (controller.nearestOffers.isEmpty) {
                            return const Center(
                              child: Text("No offers available"),
                            );
                          }

                          return ListView.builder(
                            itemCount: controller.nearestOffers.length,
                            itemBuilder: (context, index) {
                              var offer = controller.allOffers[index];

                              return OfferContainer(
                                title: offer.name,
                                subtitle: offer.desc,
                                timeAgo: DateTimeHelper.timeAgoSince(
                                    offer.createdAt.toIso8601String()),
                                countdown: DateTimeHelper.formatDateTimeExpiry(
                                  offer.expiryAt,
                                ),
                                icon: Icons.checkroom,
                              );
                            },
                          );
                        }),

                    // ListView(
                    //   children: const [
                    //     OfferContainer(
                    //       title: 'LEVI sale',
                    //       subtitle: 'Clothes and fabric',
                    //       timeAgo: '5 mins ago',
                    //       countdown: '59:59',
                    //       icon: Icons.checkroom,
                    //     ),
                    //     OfferContainer(
                    //       title: 'KFC offer',
                    //       subtitle: 'Food and beverage',
                    //       timeAgo: '5 mins ago',
                    //       countdown: '59:59',
                    //       icon: Icons.fastfood,
                    //     ),
                    //     OfferContainer(
                    //       title: 'St. Joseph turf',
                    //       subtitle: 'Sport and fitness',
                    //       timeAgo: '10 mins ago',
                    //       countdown: '30:15',
                    //       icon: Icons.sports_soccer,
                    //     ),
                    //   ],
                    // ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

// OfferContainer widget
class OfferContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final String timeAgo;
  final String countdown;
  final IconData icon;

  const OfferContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.countdown,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: 92,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: "MontserratM",
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontFamily: "MontserratM",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(icon, color: Colors.orange),
                    const SizedBox(width: 5),
                    Text(
                      subtitle.length > 15
                          ? '${subtitle.substring(0, 12)}...'
                          : subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontFamily: "MontserratM",
                      ),
                    ),
                    const SizedBox(width: 10), // Added spacing
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.orange),
                        const SizedBox(width: 5),
                        Text(
                          countdown,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "MontserratM",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const CircleAvatar(
              radius: 15,
              backgroundColor: Colors.orange,
              child:
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
