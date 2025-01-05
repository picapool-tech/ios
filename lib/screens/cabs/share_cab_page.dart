import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart'; // To format the date
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:picapool/models/live_offer/live_offer_entity.dart';
import 'package:picapool/screens/cabs/showallcabs.dart';
import 'package:picapool/widgets/cab/create_live_offer.dart'; // For location search and suggestions
import 'package:get/get.dart';
import 'package:picapool/controllers/live_offer_controller.dart';
import 'package:geolocator/geolocator.dart';

class ShareCabScreen extends StatefulWidget {
  const ShareCabScreen({super.key});

  @override
  _ShareCabScreenState createState() => _ShareCabScreenState();
}

class _ShareCabScreenState extends State<ShareCabScreen> {
  static const LatLng _center = LatLng(25.276987, 55.296249);
  String? _selectedCab; // To track the selected cab marker
  DateTime _selectedDate = DateTime.now(); // Current selected date
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey:'AIzaSyBoAHaJWyiCrTL4UnoE0I7jEpYja872Psk'); // Add your API key here
  GoogleMapController? mapController;
  Position? currentPosition;
  Set<Marker> _markers = {};

  TextEditingController _fromController = TextEditingController();
  TextEditingController _toController = TextEditingController();
  List<Prediction> _fromPredictions = [];
  List<Prediction> _toPredictions = [];
  String formattedDate = '';

  final LiveOfferController liveOfferController = Get.find();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    liveOfferController.getAllLiveOffers().then((_) {
      _initializeMarkers(); // Initialize markers after offers are loaded
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      setState(() {
        currentPosition = position;
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(position.latitude, position.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        );
      });
      
      // Move camera to current location
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 14.0,
          ),
        ),
      );
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _addOfferMarkers(List<LiveOffer> offers) async {
    // Clear existing offer markers (keep user's location marker if exists)
    _markers.removeWhere((marker) => !marker.markerId.value.startsWith('current'));
    
    for (var offer in offers) {
      if (offer.fromAddress != null && offer.fromAddress!.isNotEmpty) {
        try {
          final places = GoogleMapsPlaces(apiKey: 'AIzaSyBoAHaJWyiCrTL4UnoE0I7jEpYja872Psk');
          final PlacesSearchResponse response = await places.searchByText(
            offer.fromAddress!,
            region: "IN",
            // components: [Component(Component.country, "IN")], // Restrict to India
          );

          if (response.status == 'OK' && response.results.isNotEmpty) {
            final location = response.results.first.geometry!.location;
            
            setState(() {
              _markers.add(
                Marker(
                  markerId: MarkerId('offer_${offer.id}'),
                  position: LatLng(location.lat, location.lng),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                  // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                  infoWindow: InfoWindow(
                    title: DateFormat('hh:mm a').format(offer.updatedAt!),
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

            print("Added marker for offer ${offer.id} at ${location.lat}, ${location.lng}");
          }
        } catch (e) {
          print("Error adding marker for offer ${offer.id}: $e");
        }
      }
    }
  }

  // Add this method to initialize markers when offers are loaded
  void _initializeMarkers() {
    final offers = liveOfferController.liveOffersList;
    if (offers.isNotEmpty) {
      _addOfferMarkers(offers);
    }
  }

  // Function to open a date picker and allow the user to select a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        formattedDate = DateFormat('E, d MMM').format(_selectedDate);
      });
  }

  // Function to set the date to today
  void _setToday() {
    setState(() {
      _selectedDate = DateTime.now();
      formattedDate = DateFormat('E, d MMM').format(_selectedDate);
    });
  }

  // Function to set the date to tomorrow
  void _setTomorrow() {
    setState(() {
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      formattedDate = DateFormat('E, d MMM').format(_selectedDate);
    });
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
      } else {
        _toController.text = prediction.description ?? '';
        _toPredictions.clear();
      }
    });
  }

      List<LiveOffer> _filterOffersByDate(List<LiveOffer> offers) {
    if (_selectedDate == null) {
      return offers; // Return all offers if no date is selected
    }

    final selectedDateStart = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
    final selectedDateEnd = selectedDateStart.add(const Duration(days: 1));

    return offers.where((offer) {
      final updatedAt = offer.updatedAt;
      return updatedAt!.isAfter(selectedDateStart) && updatedAt.isBefore(selectedDateEnd);
    }).toList();
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    formattedDate = DateFormat('E, d MMM').format(_selectedDate); // Format date

  return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Share a Cab', textAlign: TextAlign.left, style: TextStyle(fontFamily: "MontserratSB"),),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.only(
                      right: 8, left: 8, top: 10.0),
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
                          child: Wrap(
                            children:[ Row(
                              children: [
                                InkWell(
                                    onTap: () => _selectDate(context),
                                    child: const ImageIcon(AssetImage("assets/icons/calendar.png"),color: Color(0xffFF8D41),)),
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
                                    backgroundColor: const Color(0xffFFD2B4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
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
                                    backgroundColor: const Color(0xffFFD2B4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
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
                      ]
                          ),
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
              if (_toPredictions.isNotEmpty)
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: ListView.builder(
                    itemCount: _toPredictions.length,
                    itemBuilder: (context, index) {
                      var prediction = _toPredictions[index];
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
                        onTap: () => _selectPlace(prediction, false),
                      );
                    },
                  ),
                ),
              // Map section and bottom container
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                        if (currentPosition != null) {
                          controller.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  currentPosition!.latitude,
                                  currentPosition!.longitude,
                                ),
                                zoom: 14.0,
                              ),
                            ),
                          );
                        }
                      },
                      initialCameraPosition: CameraPosition(
                        target: currentPosition != null 
                          ? LatLng(currentPosition!.latitude, currentPosition!.longitude)
                          : const LatLng(0, 0), // Default position until we get location
                        zoom: 14.0,
                      ),
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                    ),
                    // Bottom fixed container
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 250,
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
                                fontFamily: "MontserratSB"
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 180,
                              child: GetBuilder<LiveOfferController>(
                                builder: (liveOfferInstance) {
                                  if (liveOfferInstance.allLiveofferState == GetAllLiveOfferState.allLiveOffersLoaded) {
                                    final filteredOffers = _filterOffersByDate(liveOfferInstance.liveOffersList);
                                    
                                    if (filteredOffers.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.no_transfer, size: 48, color: Colors.grey[400]),
                                            const SizedBox(height: 16),
                                            Text(
                                              _selectedDate == null 
                                                ? "No rides available"
                                                : "No rides available for ${DateFormat('yyyy-MM-dd').format(_selectedDate)}",
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
          
                                    return ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: filteredOffers.length,
                                      itemBuilder: (context, index) {
                                        final offer = filteredOffers[index];
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
                                                padding: const EdgeInsets.symmetric(horizontal:  16.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          DateFormat('hh:mm a').format(offer.updatedAt!),
                                                          style: const TextStyle(
                                                            fontFamily: "MontserratM",
                                                            fontSize: 20
                                                          ),
                                                        ),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.grey[300]!),
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          child: Row(
                                                            children: List.generate(
                                                              offer.seats ?? 0,
                                                              (index) => const Padding(
                                                                padding: EdgeInsets.only(right: 2),
                                                                child: Icon(Icons.person, size: 16, color: Color(0xffFF8D41)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 16),
                                                    buildAddressRow("From", offer.fromAddress ?? "EMPTY"),
                                                    const SizedBox(height: 8),
                                                    buildAddressRow("To", offer.toAddress ?? "EMPTY"),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: () {},
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: const Color(0xffFF8D41),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10),
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
                                      },
                                    );
                                  }
                                  return const Center(
                                    child: LinearProgressIndicator(color: Colors.orange)
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // The "3 cabs available nearby for this date" container
                    Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.3, // Positioned above the bottom container
                      left: 40,
                      right: 40,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                            final offersCount = liveOfferInstance.liveOffersList.length;
                            return Center(
                              child: Text.rich(
                                TextSpan(
                                  text: offersCount > 0 ? '$offersCount' : 'Oops! No',
                                  style: const TextStyle(
                                    fontSize: 16, 
                                    color: Color(0xffFF8D41),
                                    fontFamily: "MontserratR"
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: ' cabs ',
                                      style: TextStyle(
                                        color: Color(0xffFF8D41),
                                        fontFamily: "MontserratR"
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'available nearby for this date.',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "MontserratR"
                                      ),
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
      ),
      bottomNavigationBar: const BottomAppBar(color: Color.fromARGB(255, 228, 228, 228),height: 65 , elevation: 7,),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=> CreateLiveOffer()   ));
      },
      shape: const CircleBorder(),
      backgroundColor: Colors.orange,
      elevation: 7,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(36)),
          border: Border.all(color: Colors.white, width: 2, style: BorderStyle.solid) 
        ),
        child: const Icon(Icons.local_taxi, color: Colors.white,size: 24,)),
      ),
    );
  }

  // Update the didUpdateWidget method
  @override
  void didUpdateWidget(covariant ShareCabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initializeMarkers(); // Refresh markers when widget updates
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
