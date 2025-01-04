import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picapool/controllers/live_offer_controller.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/location/location_provider.dart';
import 'package:picapool/functions/vicinity/vicinity_controller.dart';
import 'package:picapool/models/live_offer/create_live_offer_payload.dart';
import 'package:picapool/screens/Public%20Chat/chatPage_m.dart';
import 'package:picapool/screens/cabs/location_pick_fields.dart';

import '../../models/live_offer/live_offer_entity.dart';

class CreateLiveOffer extends StatefulWidget {
  CreateLiveOffer({super.key});

  @override
  State<CreateLiveOffer> createState() => _CreateLiveOfferState();
}

class _CreateLiveOfferState extends State<CreateLiveOffer> {
  final LocationController locationController = Get.find<LocationController>();
  final LiveOfferController liveOfferController = Get.find();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: 'AIzaSyBoAHaJWyiCrTL4UnoE0I7jEpYja872Psk');
  List<Prediction> _predictions = [];
  
  DateTime? _selectedDateTime;
  DateTime? _defaultExpiryDate;
  DateTime updateDefaultExpiryDate() {
  if (_selectedDateTime != null) {
    setState(() {
    _defaultExpiryDate = _selectedDateTime!.add(Duration(days: 3));
    });
  } else {
    _defaultExpiryDate = null; // Handle case where _selectedDate is null
  }
  return _defaultExpiryDate ?? DateTime.now();
}

  bool isLoading = false;
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  
  // Location data
  LatLng? _fromLatLng;
  LatLng? _toLatLng;
  String? _fromAddress;
  String? _toAddress;
  bool _isSearchingFrom = false; // Track which field is being searched

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _predictions.clear();
      });
      return;
    }

    try {
      var response = await _places.autocomplete(
        query,
        components: [Component(Component.country, "IN")],
      );

      if (response.isOkay) {
        setState(() {
          _predictions = response.predictions;
        });
      } else {
        debugPrint(response.errorMessage);
      }
    } catch (e) {
      debugPrint('Error searching places: $e');
    }
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
        _fromController.text = locationController.state.value.locationName?.name ?? '';
        _fromAddress = _fromController.text;
      });
    }
  }

  bool _validateInputs() {
    if (_fromLatLng == null || _toLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both pickup and drop-off locations')),
      );
      return false;
    }
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time')),
      );
      return false;
    }
    if (_selectedDateTime!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a future date and time')),
      );
      return false;
    }
    return true;
  }

  void _handleCreateLiveOffer() {
    if (!_validateInputs()) return;

    final payload = CreateLiveOfferPayload(
      createdAt: _selectedDateTime ?? DateTime.now(),
      expiryAt: updateDefaultExpiryDate(),
      fromAddress: _fromAddress ?? "empty",
      seats: 3,
      toAddress: _toAddress ?? "empty",
    );

    liveOfferController.createLiveOffer(payload).then((_) {
      if (liveOfferController.createLiveOfferState == CreateLiveOfferState.created) {
        // Get the first chat ID from the response
        final chatId = liveOfferController.createLiveOfferResponse?.data?.chats?.first.id;
        // if (chatId != null) {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => ChatPage(chatId: chatId.toString()),
            ),
          );
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
                    _buildLocationField(
                      controller: _toController,
                      label: 'drop-off',
                      isFromField: false,
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
                  target: _currentPosition ?? const LatLng(92, 92),
                    zoom: 15,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
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
                ),
              ),
              // DateTime Picker
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
