import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart'; // To format the date
import 'package:picapool/controllers/live_offer_controller.dart';
import 'package:picapool/functions/chats/chat_controller.dart';
import 'package:picapool/functions/location/location_provider.dart';
import 'package:picapool/models/live_offer/search_cabs_payload.dart';
import 'package:picapool/models/live_offer/search_cabs_response.dart';
import 'package:picapool/screens/Public%20Chat/chatPage.dart';
import 'package:picapool/utils/date_time_utils.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/cab/create_live_offer.dart'; // For location search and suggestions

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

Widget _buildOfferCard(SearchCabsResponse offer, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(right: 16.0),
    child: GestureDetector(
      onTap: () {
        // setState(() {
        //   _selectedCab = 'cab${index + 1}';
        // });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('hh:mm a').format(offer.expiryAt!),
                    style: const TextStyle(
                      fontFamily: "MontserratM",
                      fontSize: 20,
                    ),
                  ),
                  // TODO: Uncomment after seats is fixed from the backend
                  // Container(
                  //   padding:
                  //       const EdgeInsets
                  //           .symmetric(
                  //     horizontal: 8,
                  //     vertical: 4,
                  //   ),
                  //   decoration:
                  //       BoxDecoration(
                  //     border: Border.all(
                  //       color: Colors
                  //           .grey[300]!,
                  //     ),
                  //     borderRadius:
                  //         BorderRadius
                  //             .circular(
                  //                 12),
                  //   ),
                  // child: Row(
                  //   children:
                  //       List.generate(
                  //     offer.seats ?? 0,
                  //     (index) =>
                  //         const Padding(
                  //       padding:
                  //           EdgeInsets
                  //               .only(
                  //         right: 2,
                  //       ),
                  //       child: Icon(
                  //         Icons.person,
                  //         size: 16,
                  //         color: Color(
                  //           0xffFF8D41,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // ),
                ],
              ),
              const SizedBox(height: 16),
              buildAddressRow("From", offer.fromAddress ?? "EMPTY"),
              const SizedBox(height: 8),
              buildAddressRow(
                "To",
                offer.toAddress ?? "EMPTY",
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // _getToChat(index);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xffFF8D41,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImageIcon(
                          AssetImage("assets/icons/bus.png"),
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Join Chat",
                          style: TextStyle(
                            fontFamily: "MontserratR",
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class ShareCabScreen extends StatefulWidget {
  const ShareCabScreen({super.key});

  @override
  _ShareCabScreenState createState() => _ShareCabScreenState();
}

class _ShareCabScreenState extends State<ShareCabScreen> {
  static const LatLng _center = LatLng(25.276987, 55.296249);
  String? _selectedCab; // To track the selected cab marker
  DateTime _selectedDate = DateTime.now(); // Current selected date
  final GoogleMapsPlaces _places = GoogleMapsPlaces(
      apiKey:
          'AIzaSyBoAHaJWyiCrTL4UnoE0I7jEpYja872Psk'); // Add your API key here
  GoogleMapController? mapController;
  Set<Marker> _markers = {};

  TextEditingController _fromController = TextEditingController();
  TextEditingController _toController = TextEditingController();
  LocationController _locationController = Get.find<LocationController>();
  List<Prediction> _fromPredictions = [];
  List<Prediction> _toPredictions = [];
  String formattedDate = '';
  LatLng? selectedLocationLatLng;
  GoogleMapController? _controller;

  final LiveOfferController liveOfferController = Get.find();

  // Add new variables
  final int defaultRadius = 5000;
  LatLng? selectedFromLocation;
  bool isInitialLoad = true;
  bool _isMapInitialized = false;
  String? _currentAddress;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    formattedDate = DateFormat('E, d MMM').format(_selectedDate); // Format date
    TextEditingController fromSearchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
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
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            );
          }

          return Container(
            color: Colors.white,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 4.0),
                    child: _buildFromLocationField(
                        controller: fromSearchController,
                        label: "From",
                        isFromField: true),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: 8, left: 8, top: 10.0),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Wrap(children: [
                                Row(
                                  children: [
                                    InkWell(
                                        onTap: () => _selectDate(context),
                                        child: const ImageIcon(
                                          AssetImage(
                                              "assets/icons/calendar.png"),
                                          color: Color(0xffFF8D41),
                                        )),
                                    const SizedBox(width: 8),
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: "MontserratSB",
                                      ),
                                    ),
                                    const Spacer(),
                                    ElevatedButton(
                                      onPressed: _setToday,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(0),
                                        backgroundColor:
                                            const Color(0xffFFD2B4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'Today',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: "MontserratSB",
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    ElevatedButton(
                                      onPressed: _setTomorrow,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xffFFD2B4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'Tomorrow',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: "MontserratSB",
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Suggestion boxes as seen in the image
                  if (_fromPredictions.isNotEmpty)
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: ListView.builder(
                        itemCount: _fromPredictions.length,
                        itemBuilder: (context, index) {
                          var prediction = _fromPredictions[index];
                          return ListTile(
                            title: Text(
                              prediction.description ?? '',
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: "MontserratR",
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () => _selectPlace(prediction, true),
                          );
                        },
                      ),
                    ),
                  // Map section and bottom container
                  Expanded(
                    child: Stack(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: GoogleMap(
                            onMapCreated: (GoogleMapController controller) {
                              mapController = controller;
                              if (selectedLocationLatLng != null) {
                                controller.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: LatLng(
                                        selectedLocationLatLng!.latitude,
                                        selectedLocationLatLng!.longitude,
                                      ),
                                      zoom: 14.0,
                                    ),
                                  ),
                                );
                              }
                            },
                            initialCameraPosition: CameraPosition(
                              target: selectedLocationLatLng != null
                                  ? LatLng(selectedLocationLatLng!.latitude,
                                      selectedLocationLatLng!.longitude)
                                  : const LatLng(0,
                                      0), // Default position until we get location
                              zoom: 14.0,
                            ),
                            markers: _markers,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                          ),
                        ),
                        // Bottom fixed container
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.33,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
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
                                  builder: (liveOffersInstance) {
                                    return Container(
                                        color: Colors.white,
                                        height: 180,
                                        child: liveOffersInstance
                                                        .searchLiveOfferState ==
                                                    SearchLiveOfferState
                                                        .created &&
                                                liveOffersInstance
                                                        .searchCabsList !=
                                                    null &&
                                                liveOffersInstance
                                                    .searchCabsList!.isNotEmpty
                                            ? ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: liveOfferController
                                                        .searchCabsList
                                                        ?.length ??
                                                    0,
                                                itemBuilder: (context, index) {
                                                  final offer =
                                                      liveOfferController
                                                              .searchCabsList![
                                                          index];
                                                  return _buildOfferCard(
                                                      offer, context);
                                                },
                                              )
                                            : _buildEmptyState());
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        // The "3 cabs available nearby for this date" container
                        Positioned(
                          bottom: MediaQuery.of(context).size.height *
                              0.32, // Positioned above the bottom container
                          left: screenWidth * 0.1,
                          right: screenWidth * 0.1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
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
                                // final filteredOffers = _selectedDate != null
                                //     ? liveOfferInstance.liveOffersList
                                //         .where((offer) {
                                //         final offerDate = offer.createdAt;
                                //         return offerDate != null &&
                                //             DateUtils.isSameDay(
                                //                 offerDate, _selectedDate);
                                //       }).toList()
                                //     : liveOfferInstance.liveOffersList;

                                final offersCount =
                                    liveOfferInstance.searchCabsList?.length ??
                                        0;

                                return Center(
                                  child: Text.rich(
                                    TextSpan(
                                      text: offersCount > 0
                                          ? '$offersCount'
                                          : 'Oops! No',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xffFF8D41),
                                          fontFamily: "MontserratR"),
                                      children: [
                                        const TextSpan(
                                          text: ' cabs ',
                                          style: TextStyle(
                                              color: Color(0xffFF8D41),
                                              fontFamily: "MontserratR"),
                                        ),
                                        TextSpan(
                                          text: _selectedDate != null
                                              ? 'available for ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}'
                                              : 'available nearby.',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontFamily: "MontserratR"),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
      floatingActionButton: Column(
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
      ),
      // FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const CreateLiveOffer(),
      //       ),
      //     );
      //   },
      //   shape: const CircleBorder(),
      //   backgroundColor: Colors.orange,
      //   elevation: 7,
      // child: Container(
      //     padding: const EdgeInsets.all(12),
      //     decoration: BoxDecoration(
      //         borderRadius: const BorderRadius.all(Radius.circular(36)),
      //         border: Border.all(
      //             color: Colors.white, width: 2, style: BorderStyle.solid)),
      //     child: const Icon(
      //       Icons.local_taxi,
      //       color: Colors.white,
      //       size: 24,
      //     )),
      // ),
    );
  }

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

  // Update the didUpdateWidget method
  @override
  void didUpdateWidget(covariant ShareCabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // _initializeMarkers(); // Refresh markers when widget updates
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeLocationAndSearch();
  }

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

  Widget _buildFromLocationField({
    required TextEditingController controller,
    required String label,
    required bool isFromField,
  }) {
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
          // Show search delegate
          final Prediction? result = await showSearch(
            context: context,
            delegate: LocationSearchDelegate(places: _places),
          );

          if (result != null) {
            await _selectPlace(result, true);
          }
        },
        readOnly: true,
        decoration: InputDecoration(
          hintText: 'Search for $label location...',
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontFamily: 'MontserratR',
            fontSize: 16,
          ),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.location_on, color: Colors.orange),
          suffixIcon: IconButton(
            icon: const Icon(Icons.my_location, color: Colors.orange),
            onPressed: () async {
              await _initializeLocationAndSearch();
              if (selectedLocationLatLng != null) {
                selectedFromLocation = selectedLocationLatLng;
                _searchOffers();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOffersListView() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: liveOfferController.searchCabsList?.length ?? 0,
      itemBuilder: (context, index) {
        final offer = liveOfferController.searchCabsList![index];
        return _buildOfferCard(offer, context);
      },
    );
  }

  Future<void> _fetchLocation() async {
    if (_locationController.state.value.location == null) {
      await _locationController.getLocation();
    }
    var location = _locationController.state.value.location;
    if (location == null) {
      debugPrint("NULL LOCATION : VICINITY");
      Get.snackbar(
        'Error',
        'Failed to get current location.',
        snackStyle: SnackStyle.GROUNDED,
      );
      return;
    }

    // Position position = await Geolocator.(
    //     desiredAccuracy: LocationAccuracy.high
    //   );

    setState(() {
      selectedLocationLatLng = LatLng(location.latitude, location.longitude);
      // currentPosition = position;

      if (_controller != null && !_isMapInitialized) {
        _controller!.animateCamera(
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

  // Helper method to format date for display
  String _formatDateForDisplay(DateTime date) {
    return DateFormat('E, d MMM').format(date);
  }

  Future<void> _getAddressFromLatLng(LatLng coordinates) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress =
              "${place.street}, ${place.subLocality}, ${place.locality}";
          _fromController.text = _currentAddress ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
  }

  void _getToChat(
    int index,
  ) async {
    ChatController chatController = Get.find<ChatController>();
    var chat = await chatController
        .getChatFromLiveOfferId(liveOfferController.liveOffersList[index].id!);
    if (chat != null) {
      Get.to(() => ChatPage(
            chat: chat,
            chatTitle: chat.offer?.name ?? "String",
            // liveOffer: liveOfferController.liveOffersList[index]?,
          ));
    } else {
      Get.snackbar(
        "Error",
        "Could not get chat",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _initializeLocationAndSearch() async {
    await _fetchLocation();
    if (selectedLocationLatLng != null) {
      await _getAddressFromLatLng(selectedLocationLatLng!);
      selectedFromLocation = selectedLocationLatLng!;
      _searchOffers();
      _updateMarkersFromSearch();
    }
    print("===== TRIGGERD =============");
  }

  Future<void> _searchOffers() async {
    if (selectedFromLocation == null) return;

    // Format the selected date with time to ISO string
    final startTimeISO = DateTimeUtils.formatDateWithZone(DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      DateTime.now().hour,
      DateTime.now().minute,
      DateTime.now().second,
    ));

    debugPrint('Searching offers with date: $startTimeISO'); // Debug log

    final SearchCabsPayload payload = SearchCabsPayload(
      from: From(
        lat: selectedFromLocation!.latitude,
        lng: selectedFromLocation!.longitude,
      ),
      radius: defaultRadius,
      startTime: startTimeISO, // Send the formatted date string
    );

    await liveOfferController.searchLiveOffer(payload);
    if (liveOfferController.searchLiveOfferState ==
        SearchLiveOfferState.created) {
      _updateMarkersFromSearch();
    }
  }

  // Function to search location and show suggestions
  Future<void> _searchPlaces(String query, bool isFrom) async {
    if (query.isEmpty) {
      setState(() {
        isFrom ? _fromPredictions.clear() : _toPredictions.clear();
      });
      return;
    }

    var sessionToken = 'xyzabc_1234'; // You may generate this token dynamically
    var response =
        await _places.autocomplete(query, sessionToken: sessionToken);

    if (response.isOkay) {
      setState(() {
        if (isFrom) {
          _fromPredictions = response.predictions;
        } else {
          _toPredictions = response.predictions;
        }
      });
    }
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
        // Preserve the time from the previous selection
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
          _selectedDate.second,
        );
        formattedDate = _formatDateForDisplay(_selectedDate);
      });
      _searchOffers(); // Search with new date
    }
  }

  // Function to select place and fill text field
  Future<void> _selectPlace(Prediction prediction, bool isFrom) async {
    final placeId = prediction.placeId;
    if (placeId == null) return;

    var details = await _places.getDetailsByPlaceId(placeId);
    final location = details.result.geometry?.location;
    if (location == null) return;

    setState(() {
      if (isFrom) {
        _fromController.text = prediction.description ?? '';
        _fromPredictions.clear();
        selectedFromLocation = LatLng(location.lat, location.lng);
        _searchOffers(); // Search with new location
      }
    });
  }

  // Function to set the date to today
  void _setToday() {
    setState(() {
      _selectedDate = DateTime.now();
      formattedDate = DateFormat('E, d MMM').format(_selectedDate);
    });
    debugPrint('Date set to today: $_selectedDate'); // Debug log
    _searchOffers(); // This will now use the updated _selectedDate
  }

  // Function to set the date to tomorrow
  void _setTomorrow() {
    setState(() {
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      formattedDate = DateFormat('E, d MMM').format(_selectedDate);
    });
    debugPrint('Date set to tomorrow: $_selectedDate'); // Debug log
    _searchOffers(); // This will now use the updated _selectedDate
  }

  void _updateMarkersFromSearch() async {
    // Clear non-current markers
    setState(() {
      _markers.removeWhere(
          (marker) => !marker.markerId.value.startsWith('current'));
    });

    // Ensure searchCabsList is not null or empty
    if (liveOfferController.searchCabsList != null &&
        liveOfferController.searchCabsList!.isNotEmpty) {
      for (var offer in liveOfferController.searchCabsList!) {
        try {
          if (offer.fromAddress != null && offer.fromAddress!.isNotEmpty) {
            // Fetch place details using placeId or address
            final placeDetails = await _places.getDetailsByPlaceId(
              offer.fromAddress!,
            );

            if (placeDetails.result.geometry?.location != null) {
              final location = placeDetails.result.geometry!.location;

              setState(() {
                _markers.add(
                  Marker(
                    markerId: MarkerId('offer_${offer.id}'),
                    position: LatLng(location.lat, location.lng),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueOrange),
                    infoWindow: InfoWindow(
                      title: offer.expiryAt != null
                          ? DateFormat('hh:mm a').format(offer.expiryAt!)
                          : 'No expiry time',
                      snippet: '${offer.seats} seats available',
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCab = 'offer_${offer.id}';
                      });
                    },
                  ),
                );
              });
            }
          }
        } catch (e) {
          debugPrint(
              'Error fetching place details for address ${offer.fromAddress}: $e');
        }
      }
    }
  }
}
