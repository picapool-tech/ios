import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:picapool/common/values/map_style.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/controllers/live_offer_controller.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/features/location/location_provider.dart';
import 'package:picapool/models/live_offer/search_cabs_payload.dart';
import 'package:picapool/models/live_offer/search_cabs_response.dart';
import 'package:picapool/screens/public_chat/chat_page.dart';
import 'package:picapool/utils/date_time_utils.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/cab/create_live_offer.dart';

// Common address row widget - removed duplicate function inside class
Widget buildAddressRow(String label, String address) {
  return Row(
    children: [
      Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: "MontserratM",
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              address,
              style: const TextStyle(fontFamily: "MontserratM"),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ],
  );
}

// Empty state widget - extracted from inline code
Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.no_transfer, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          "No cabs available in this area",
          style: GoogleFonts.montserrat(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

// Common offer card widget - moved outside of class
Widget _buildOfferCard(SearchCabsResponse offer, BuildContext context) {
  var controller = Get.find<ChatController>();
  return Container(
    width: MediaQuery.of(context).size.width * 0.7,
    margin: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildAddressRow("From", offer.fromAddress ?? "EMPTY"),
        buildAddressRow(
          "To",
          offer.toAddress ?? "EMPTY",
        ),
        SizedBox(
          width: double.infinity,
          child: PicaPrimaryButton(
            onPressed: () async {
              final controller = Get.find<ChatController>();
              // Show loading within button only
              controller.isLoading.value = true;

              var chatAndOffer =
                  await controller.getChatFromLiveOfferId(offer.id!);
              controller.isLoading.value = false;

              if (chatAndOffer == null) {
                Get.snackbar(
                  "Oops!",
                  "Chat of this live offer doesn't exist",
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              Get.to(
                () => ChatPage(
                  chat: chatAndOffer.chat,
                  chatTitle: offer.toAddress ?? "Chat",
                  liveOffer: chatAndOffer.liveOffer,
                ),
              );
            },
            text: "Join now",
            isLoading: controller.isLoading,
          ),
        ),
      ],
    ),
  );
}

class LocationSearchDelegate extends SearchDelegate<Prediction> {
  final GoogleMapsPlaces places;

  LocationSearchDelegate({required this.places});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, Prediction()),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.length < 3) {
      return Center(child: Text('Enter at least 3 characters'));
    }

    return FutureBuilder<PlacesAutocompleteResponse>(
      future: places.autocomplete(query, sessionToken: 'search_session'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData ||
            !snapshot.data!.isOkay ||
            snapshot.data!.predictions.isEmpty) {
          return Center(child: Text('No results found'));
        }

        final predictions = snapshot.data!.predictions;

        return ListView.builder(
          itemCount: predictions.length,
          itemBuilder: (context, index) {
            final prediction = predictions[index];
            return ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(prediction.description ?? ''),
              onTap: () => close(context, prediction),
            );
          },
        );
      },
    );
  }
}

class ShareCabScreen extends StatefulWidget {
  const ShareCabScreen({super.key});

  @override
  State<ShareCabScreen> createState() => _ShareCabScreenState();
}

class _ShareCabScreenState extends State<ShareCabScreen> {
  static const LatLng _defaultCenter = LatLng(25.276987, 55.296249);
  DateTime _selectedDate = DateTime.now();
  late GoogleMapsPlaces _places;
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};

  late TextEditingController _fromController;
  late LocationController _locationController;
  String formattedDate = '';
  LatLng? selectedLocationLatLng;

  late LiveOfferController liveOfferController;

  final int defaultRadius = 5000;
  LatLng? selectedFromLocation;
  bool _isMapInitialized = false;
  String? _currentAddress;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Share a Cab',
          textAlign: TextAlign.left,
          style: TextStyle(fontFamily: "MontserratSB"),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: GetBuilder<LiveOfferController>(
        builder: (liveOfferController) {
          if (liveOfferController.searchLiveOfferState ==
              SearchLiveOfferState.creating) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          return Container(
            color: Colors.white,
            child: Column(
              children: [
                // Location search field
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4.0),
                  child: _buildFromLocationField(),
                ),

                // Date selector
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: _buildDateSelector(),
                ),

                // Map section and bottom container
                Expanded(
                  child: _buildMapAndOffersList(screenWidth, screenHeight),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomAppBar(
        color: Color.fromARGB(255, 228, 228, 228),
        height: 65,
        elevation: 7,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildCreateButton(),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    _fromController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController();
    _locationController = Get.find<LocationController>();
    liveOfferController = Get.find<LiveOfferController>();
    _places =
        GoogleMapsPlaces(apiKey: 'AIzaSyBoAHaJWyiCrTL4UnoE0I7jEpYja872Psk');

    formattedDate = _formatDateForDisplay(_selectedDate);

    // Initialize location and search in one go
    _initializeLocationAndSearch();
  }

  Widget _buildAvailableRidesContainer(double screenHeight) {
    return Container(
      height: screenHeight * 0.33,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Available Rides",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: "MontserratSB"),
          ),
          const SizedBox(height: 16),
          GetBuilder<LiveOfferController>(
            builder: (liveOffersController) {
              return liveOffersController.searchLiveOfferState ==
                          SearchLiveOfferState.created &&
                      liveOffersController.searchCabsList != null &&
                      liveOffersController.searchCabsList!.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount:
                            liveOffersController.searchCabsList?.length ?? 0,
                        itemBuilder: (context, index) {
                          final offer =
                              liveOffersController.searchCabsList![index];
                          return _buildOfferCard(offer, context);
                        },
                      ),
                    )
                  : _buildEmptyState();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCabsInfoContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 5,
          ),
        ],
      ),
      child: GetBuilder<LiveOfferController>(
        builder: (liveOfferInstance) {
          final offersCount = liveOfferInstance.searchCabsList?.length ?? 0;

          return Center(
            child: Text.rich(
              TextSpan(
                text: offersCount > 0 ? '$offersCount' : 'Oops! No',
                style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xffFF8D41),
                    fontFamily: "MontserratR"),
                children: [
                  const TextSpan(
                    text: ' cabs ',
                    style: TextStyle(
                        color: Color(0xffFF8D41), fontFamily: "MontserratR"),
                  ),
                  TextSpan(
                    text:
                        'available for ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                    style: const TextStyle(
                        color: Colors.black, fontFamily: "MontserratR"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreateButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          backgroundColor: AppTheme.light.primaryColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateLiveOffer(),
              ),
            );
          },
          elevation: 2,
          shape: const CircleBorder(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(36)),
                border: Border.all(
                    color: Colors.white, width: 2, style: BorderStyle.solid)),
            child: const Icon(
              Icons.local_taxi,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Create Now',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDateButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(0),
        backgroundColor: const Color(0xffFFD2B4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontFamily: "MontserratSB",
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.only(right: 8, left: 8, top: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: const ImageIcon(
                      AssetImage("assets/icons/calendar.png"),
                      color: Color(0xffFF8D41),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: "MontserratSB",
                    ),
                  ),
                  const Spacer(),
                  _buildDateButton('Today', _setToday),
                  const SizedBox(width: 6),
                  _buildDateButton('Tomorrow', _setTomorrow),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFromLocationField() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: TextField(
        controller: _fromController,
        onTap: () async {
          final result = await showSearch(
            context: context,
            delegate: LocationSearchDelegate(places: _places),
          );

          if (result != null && result.placeId != null) {
            await _selectPlace(result);
          }
        },
        readOnly: true,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'Search for location...',
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontFamily: 'MontserratR',
            fontSize: 16,
          ),
          border: InputBorder.none,
          filled: false,
          prefixIcon: const Icon(Icons.location_on, color: Colors.orange),
          suffixIcon: IconButton(
            icon: const Icon(Icons.my_location, color: Colors.orange),
            onPressed: () async {
              await _initializeLocationAndSearch();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMapAndOffersList(double screenWidth, double screenHeight) {
    return Stack(
      children: [
        // Map view
        SizedBox(
          height: screenHeight * 0.4,
          child: GoogleMap(
            style: customMapStyle,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              if (selectedLocationLatLng != null) {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: selectedLocationLatLng!,
                      zoom: 14.0,
                    ),
                  ),
                );
              }
            },
            initialCameraPosition: CameraPosition(
              target: selectedLocationLatLng ?? _defaultCenter,
              zoom: 14.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
        ),

        // Bottom container with available rides
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildAvailableRidesContainer(screenHeight),
        ),

        // "X cabs available" floating info
        Positioned(
          bottom: screenHeight * 0.32,
          left: screenWidth * 0.1,
          right: screenWidth * 0.1,
          child: _buildCabsInfoContainer(),
        ),
      ],
    );
  }

  Future<void> _fetchLocation() async {
    if (_locationController.state.value.location == null) {
      await _locationController.getLocation();
    }
    final location = _locationController.state.value.location;
    if (location == null) {
      Get.snackbar(
        'Error',
        'Failed to get current location.',
        snackStyle: SnackStyle.GROUNDED,
      );
      return;
    }

    setState(() {
      selectedLocationLatLng = LatLng(location.latitude, location.longitude);
      selectedFromLocation = selectedLocationLatLng;

      if (mapController != null && !_isMapInitialized) {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: selectedLocationLatLng!,
              zoom: 16.0,
            ),
          ),
        );
        _isMapInitialized = true;
      }
    });
  }

  void _fitMarkersToMap() {
    if (_markers.isEmpty) return;

    // Calculate bounds
    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (var marker in _markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      minLat = min(minLat, lat);
      maxLat = max(maxLat, lat);
      minLng = min(minLng, lng);
      maxLng = max(maxLng, lng);
    }

    // Create bounds and apply padding
    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    // Animate camera to show all markers with padding
    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50.0),
    );
  }

  // Date formatting utility
  String _formatDateForDisplay(DateTime date) =>
      DateFormat('E, d MMM').format(date);

  Future<void> _getAddressFromLatLng(LatLng coordinates) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final address =
            "${place.street}, ${place.subLocality}, ${place.locality}";

        setState(() {
          _currentAddress = address;
          _fromController.text = address;
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
  }

  Future<void> _initializeLocationAndSearch() async {
    await _fetchLocation();
    if (selectedLocationLatLng != null) {
      await _getAddressFromLatLng(selectedLocationLatLng!);
      await _searchOffers();
    }
  }

  Future<void> _searchOffers() async {
    if (selectedFromLocation == null) return;

    // Format the selected date with time to ISO string
    final startTimeISO = DateTimeUtils.formatDateWithZone(
      DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        DateTime.now().hour,
        DateTime.now().minute,
      ),
    );

    final SearchCabsPayload payload = SearchCabsPayload(
      from: From(
        lat: selectedFromLocation!.latitude,
        lng: selectedFromLocation!.longitude,
      ),
      radius: defaultRadius,
      startTime: startTimeISO,
    );

    await liveOfferController.searchLiveOffer(payload);
    _updateMarkersFromSearch();
  }

  // Function to open a date picker and allow the user to select a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
        formattedDate = _formatDateForDisplay(_selectedDate);
      });
      await _searchOffers();
    }
  }

  // Function to select place and fill text field
  Future<void> _selectPlace(Prediction prediction) async {
    final placeId = prediction.placeId;
    if (placeId == null) return;

    final details = await _places.getDetailsByPlaceId(placeId);
    final location = details.result.geometry?.location;
    if (location == null) return;

    setState(() {
      _fromController.text = prediction.description ?? '';
      selectedFromLocation = LatLng(location.lat, location.lng);
    });

    await _searchOffers();
  }

  void _setToday() {
    setState(() {
      _selectedDate = DateTime.now();
      formattedDate = _formatDateForDisplay(_selectedDate);
    });
    _searchOffers();
  }

  void _setTomorrow() {
    setState(() {
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      formattedDate = _formatDateForDisplay(_selectedDate);
    });
    _searchOffers();
  }

  void _updateMarkersFromSearch() async {
    // Clear existing markers and add current location marker
    _markers.clear();

    // Add current location marker if available
    if (selectedLocationLatLng != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: selectedLocationLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'Your Location',
            snippet: _currentAddress ?? "Current Location",
          ),
        ),
      );
    }

    // // Add markers for search results
    // final searchResults = liveOfferController.searchCabsList;
    // if (searchResults != null) {
    //   for (var i = 0; i < searchResults.length; i++) {
    //     final offer = searchResults[i];
    //     if (offer.fromAddress == null || offer.fromAddress!.isEmpty) {
    //       debugPrint("Skipping marker: Empty address for offer ${offer.id}");
    //       continue;
    //     }
    //     try {
    //       debugPrint("Geocoding address: ${offer.fromAddress}");
    //       var locations = await locationFromAddress(offer.fromAddress!);

    //       if (locations.isNotEmpty) {
    //         final location = locations.first;
    //         debugPrint(
    //             "Location found: ${location.latitude}, ${location.longitude}");

    //         final marker = Marker(
    //           markerId: MarkerId('offer_${offer.id}'),
    //           position: LatLng(location.latitude, location.latitude),
    //           icon: BitmapDescriptor.defaultMarkerWithHue(
    //               BitmapDescriptor.hueOrange),
    //           infoWindow: InfoWindow(
    //             title: 'Ride ${i + 1}',
    //             snippet: '${offer.seats ?? 0} seats available',
    //           ),
    //         );

    //         setState(() {
    //           _markers.add(marker);
    //           debugPrint(
    //               "Marker added for offer ${offer.id} - Total markers: ${_markers.length}");
    //         });

    //         if (mapController != null) {
    //           mapController!
    //               .showMarkerInfoWindow(MarkerId('offer_${offer.id}'));
    //         }
    //       } else {
    //         debugPrint("No location found for address: ${offer.fromAddress}");
    //       }
    //     } catch (e) {
    //       debugPrint("Error geocoding address: ${offer.fromAddress} - $e");
    //     }
    //   }
    // }
    // if (_markers.length > 1 && mapController != null) {
    //   _fitMarkersToMap();
    // }
  }
}
