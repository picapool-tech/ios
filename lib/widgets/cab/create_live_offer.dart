
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picapool/controllers/live_offer_controller.dart';
import 'package:picapool/functions/location/location_provider.dart';
import 'package:picapool/models/live_offer/create_live_offer_payload.dart';
import 'package:picapool/screens/Public%20Chat/chatPage.dart';


class CreateLiveOffer extends StatefulWidget {
  const CreateLiveOffer({super.key});

  @override
  State<CreateLiveOffer> createState() => _CreateLiveOfferState();
}

class _CreateLiveOfferState extends State<CreateLiveOffer> {
  final LocationController locationController = Get.find<LocationController>();
  final LiveOfferController liveOfferController = Get.find();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  final GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: 'AIzaSyBoAHaJWyiCrTL4UnoE0I7jEpYja872Psk');
  List<Prediction> _predictions = [];

  // DateTime? _selectedDateTime;
  // DateTime? _defaultExpiryDate;
  DateTime _selectedDateTime = DateTime.now();
  DateTime _defaultExpiryDate = DateTime.now();
  DateTime updateDefaultExpiryDate() {
    setState(() {
      _defaultExpiryDate = _selectedDateTime.add(const Duration(days: 3));
    });
      return _defaultExpiryDate ?? DateTime.now();
  }

  bool isLoading = false;
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  LatLng? _selectedPosition;

  // Location data
  LatLng? _fromLatLng;
  LatLng? _toLatLng;
  String? _fromAddress;
  String? _toAddress;
  Circle? _currentLocationCircle;
  String _locationMessage = "Loading...";
  final double _radius = 500; // Default radius
  final bool _isMapInitialized = false;
  final places =
      GoogleMapsPlaces(apiKey: 'AIzaSyBoAHaJWyiCrTL4UnoE0I7jEpYja872Psk');

  bool _isSearchingFrom = false; // Track which field is being searched

  @override
  void initState() {
    _fetchLocation();
    super.initState();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _selectPlace(Prediction prediction) async {
    final placeId = prediction.placeId;
    if (placeId == null) return;

    setState(() => isLoading = true);
    try {
      var details = await _places.getDetailsByPlaceId(placeId);
      final location = details.result.geometry?.location;
      if (location != null) {
        final newPosition = LatLng(location.lat, location.lng);

        setState(() {
          if (_isSearchingFrom) {
            _fromLatLng = newPosition;
            _fromAddress = prediction.description;
            _fromController.text = prediction.description ?? "";
          } else {
            _toLatLng = newPosition;
            _toAddress = prediction.description;
            _toController.text = prediction.description ?? "";
          }
          _predictions.clear();
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newPosition, 15),
        );
      }
    } catch (e) {
      debugPrint('Error selecting place: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get location details')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildLocationField({
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: true, // Make it read-only since we're using SearchDelegate
        decoration: InputDecoration(
          hintText: 'Search for $label location...',
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontFamily: 'MontserratR',
            fontSize: 16,
          ),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.location_on, color: Colors.orange),
        ),
        onTap: () async {
          _isSearchingFrom = isFromField;
          final Prediction? result = await showSearch<Prediction>(
            context: context,
            delegate: LocationSearchDelegate(places: _places),
          );
          if (result != null) {
            _selectPlace(result);
          }
        },
      ),
    );
  }

  Future<void> _initializeLocation() async {
    await locationController.getLocation();
    if (locationController.state.value.location != null) {
      setState(() {
        _currentPosition = LatLng(
          locationController.state.value.location!.latitude,
          locationController.state.value.location!.longitude,
        );
        _fromLatLng = _currentPosition; // Set initial pickup location
        _fromController.text =
            locationController.state.value.locationName?.locality ?? '';
        _fromAddress = _fromController.text;
      });
    }
  }

  Future<void> _fetchLocation({
    bool fetchActualLocation = false,
  }) async {
    if (fetchActualLocation ||
        locationController.state.value.location == null) {
      await locationController.getLocation();
    }

    var location = locationController.state.value.location;
    if (location == null) {
      Get.snackbar(
        "Location not found",
        "Location of this device not found",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() {
      _currentPosition = LatLng(location.latitude, location.longitude);
      Placemark firstPlacemark =
          locationController.state.value.locationName ?? const Placemark();

      _fromController.text =
          '${firstPlacemark.name}, ${firstPlacemark.locality}, ${firstPlacemark.thoroughfare}, ${firstPlacemark.administrativeArea}' ??
              "Cant Fetch current location";
      _selectedPosition = _currentPosition;
      _updateMarkersAndCircles();
    });
  }

  void _updateMarkersAndCircles() async {
    setState(() {
      _currentLocationCircle = Circle(
        circleId: const CircleId("currentLocationCircle"),
        center: _currentPosition!,
        radius: 200,
        strokeColor: const Color(0xff333399).withOpacity(0.20),
        strokeWidth: 2,
        fillColor: const Color(0xff5000FF).withOpacity(0.16),
      );
    });
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      String address =
          "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
      setState(() {
        _locationMessage = address;
        _selectedPosition = position;
        _updateMarkersAndCircles();
      });
    } else {
      setState(() {
        _locationMessage = "No address available for this location.";
      });
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _predictions.clear();
      });
      return;
    }

    var sessionToken = 'xyzabc_1234';
    var response =
        await _places.autocomplete(query, sessionToken: sessionToken);

    if (response.isOkay) {
      setState(() {
        _predictions = response.predictions;
      });
    } else {
      print(response.errorMessage);
    }
  }

  bool _validateInputs() {
    if (_fromLatLng == null || _toLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select both pickup and drop-off locations')),
      );
      return false;
    }
    if (_selectedDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a future date and time')),
      );
      return false;
    }
    return true;
  }

  void _handleCreateLiveOffer() {
    // if (!_validateInputs()) return;

    final payload = CreateLiveOfferPayload(
      createdAt: _selectedDateTime,
      expiryAt: updateDefaultExpiryDate(),
      fromAddress: _fromController.text,
      seats: 3,
      toAddress: _toAddress ?? "empty",
    );

    liveOfferController.createLiveOffer(payload).then((_) {
      if (liveOfferController.createLiveOfferState ==
          CreateLiveOfferState.created) {
        // Get the first chat ID from the response

        final chatId =
            liveOfferController.createLiveOfferResponse?.data?.chats?.first;

        if (chatId != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                chat: chatId,
                chatTitle: "Chat" ,
              ),
            ),
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to not able to have chat right now'),
              ),
            );
          }
        }
        // }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Create your pool",
                  style: TextStyle(fontSize: 16, fontFamily: "MontserratM"),
                ),
              ),
              // Location Fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildLocationField(
                      controller: _fromController,
                      label: 'pickup',
                      isFromField: true,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      child: _buildLocationField(
                        controller: _toController,
                        label: 'drop-off',
                        isFromField: false,
                      ),
                    ),
                  ],
                ),
              ),

              // Predictions List
              if (_predictions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _predictions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          _predictions[index].description ?? '',
                          style: const TextStyle(
                            fontFamily: "MontserratR",
                            fontSize: 14,
                          ),
                        ),
                        onTap: () => _selectPlace(_predictions[index]),
                      );
                    },
                  ),
                ),

              // Map
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition ?? const LatLng(28.6139, 77.2090),
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    if (_currentPosition != null) {
                      controller.animateCamera(
                        CameraUpdate.newLatLngZoom(_currentPosition!, 15),
                      );
                    }
                  },
                  markers: {
                    if (_fromLatLng != null)
                      Marker(
                        markerId: const MarkerId('from'),
                        position: _fromLatLng!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen,
                        ),
                      ),
                    if (_toLatLng != null)
                      Marker(
                        markerId: const MarkerId('to'),
                        position: _toLatLng!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                      ),
                  },
                  circles: _currentLocationCircle != null
                      ? {_currentLocationCircle!}
                      : {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Select your cab time",
                      style: TextStyle(
                        fontFamily: "MontserratM",
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: CupertinoDatePicker(
                        minimumDate: DateTime.now(),
                        initialDateTime: DateTime.now(),
                        onDateTimeChanged: (dateTime) {
                          setState(() => _selectedDateTime = dateTime);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Confirm Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GetBuilder<LiveOfferController>(
                  builder: (liveOfferInstance) {
                    return liveOfferInstance.createLiveOfferState ==
                            CreateLiveOfferState.creating
                        ? const LinearProgressIndicator(color: Colors.orange)
                        : ElevatedButton(
                            onPressed: _handleCreateLiveOffer,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: const Color(0xffFF8D41),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              "Confirm",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: "MontserratSB",
                                color: Colors.white,
                              ),
                            ),
                          );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LocationSearchDelegate extends SearchDelegate<Prediction> {
  final GoogleMapsPlaces places;

  LocationSearchDelegate({required this.places});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, Prediction());
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<PlacesAutocompleteResponse>(
      future: places.autocomplete(
        query,
        components: [Component(Component.country, "IN")],
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final predictions = snapshot.data!.predictions;

        return ListView.builder(
          itemCount: predictions.length,
          itemBuilder: (context, index) {
            final prediction = predictions[index];
            return ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(prediction.description ?? ''),
              onTap: () {
                close(context, prediction);
              },
            );
          },
        );
      },
    );
  }
}
