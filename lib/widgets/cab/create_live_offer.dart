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
  
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  LatLng? _fromLatLng;
  LatLng? _toLatLng;
  String? _fromAddress;
  String? _toAddress;
  Circle? _currentLocationCircle;
  double _radius = 500; // Default radius
  bool _isMapInitialized = false;
  DateTime _selectedDateTime = DateTime.now();
  DateTime _defaultExpiryDate  = DateTime.now();
  final places = GoogleMapsPlaces(apiKey: 'YOUR_API_KEY'); // Replace with your API key

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String label,
    required bool isFromField,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(
            isFromField ? Icons.location_on : Icons.location_searching,
            color: const Color(0xffFF8D41),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: true,
              onTap: () async {
                final Prediction? result = await showSearch(
                  context: context,
                  delegate: LocationSearchDelegate(places: places),
                );

                if (result != null && result.description != null) {
                  final PlacesDetailsResponse detail = 
                      await places.getDetailsByPlaceId(result.placeId!);
                  
                  final lat = detail.result.geometry?.location.lat;
                  final lng = detail.result.geometry?.location.lng;

                  if (lat != null && lng != null) {
                    final newLatLng = LatLng(lat, lng);
                    setState(() {
                      if (isFromField) {
                        _fromLatLng = newLatLng;
                        _fromAddress = result.description;
                        controller.text = result.description!;
                      } else {
                        _toLatLng = newLatLng;
                        _toAddress = result.description;
                        controller.text = result.description!;
                      }
                    });

                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(newLatLng, 15),
                    );
                  }
                }
              },
              decoration: InputDecoration(
                hintText: 'Choose $label location',
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  fontFamily: "MontserratR",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateLiveOffer() async {
    if (_fromLatLng == null || _toLatLng == null) {
      Get.snackbar(
        'Error',
        'Please select both pickup and drop-off locations',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final CreateLiveOfferPayload payload = CreateLiveOfferPayload(
      createdAt: DateTime.now(),
      expiryAt: DateTime.now().add(Duration(days: 3)),
      seats: 3,
      // fromLat: _fromLatLng!.latitude,
      // fromLng: _fromLatLng!.longitude,
      // toLat: _toLatLng!.latitude,
      // toLng: _toLatLng!.longitude,
      fromAddress: _fromAddress ?? '',
      toAddress: _toAddress ?? '',
      // time: _selectedDateTime,
    );

    try {
      await liveOfferController.createLiveOffer(payload);
      
      // Check the state after creation
      if (liveOfferController.createLiveOfferState == CreateLiveOfferState.created) {
        Get.toNamed('/success'); // Replace with your success route
      } else {
        Get.snackbar(
          'Error',
          'Failed to create live offer',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
              const SizedBox(height: 16),
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
                        infoWindow: InfoWindow(
                          title: 'Pickup Location',
                          snippet: _fromAddress,
                        ),
                      ),
                    if (_toLatLng != null)
                      Marker(
                        markerId: const MarkerId('to'),
                        position: _toLatLng!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                        infoWindow: InfoWindow(
                          title: 'Drop-off Location',
                          snippet: _toAddress,
                        ),
                      ),
                  },
                  circles: _currentLocationCircle != null ? {_currentLocationCircle!} : {},
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