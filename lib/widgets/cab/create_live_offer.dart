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
import 'package:picapool/screens/Public%20Chat/chatPage.dart';
import 'package:picapool/screens/cabs/location_pick_fields.dart';

class CreateLiveOffer extends StatefulWidget {
  CreateLiveOffer({super.key});

  @override
  State<CreateLiveOffer> createState() => _CreateLiveOfferState();
}

class _CreateLiveOfferState extends State<CreateLiveOffer> {
  var locationController = Get.find<LocationController>();
  List<Prediction> _predictions = [];

  double _radius = 500;
  double _waitTime = 30;
  bool _isCollapsed = false;
  bool _is3DView = false;
  GoogleMapController? _controller;
  LatLng? _currentPosition;
  Marker? _pinMarker;
  Circle? _currentLocationCircle;
  bool _isMapInitialized = false; // New flag to check if the map is initialized
  int poolingUsers = 0;

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  bool isLoading = false;

  LatLng? _selectedPosition;
  String _locationMessage = "Fetching location...";
  bool _locationEnabled = true;
  Circle? _centerDotCircle;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isPinDragged = false;

  final AuthController authController = Get.find<AuthController>();
  final VicinityController vicinityController = Get.find<VicinityController>();

  GoogleMapController? _mapController;

  final GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: 'AIzaSyA5-1f-M5kxCKGgISp6Q0GT00SECxJRoXss');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  LatLng? _fromLatLng;
  LatLng? _toLatLng;

  Future<void> _selectPlaceForField(String field, Prediction prediction) async {
    final placeId = prediction.placeId;
    if (placeId == null) return;

    // Fetch the place details
    var details = await _places.getDetailsByPlaceId(placeId);
    final location = details.result.geometry?.location;
    if (location == null) return;

    LatLng newPosition = LatLng(location.lat, location.lng);

    setState(() {
      if (field == "from") {
        _fromLatLng = newPosition;
      } else if (field == "to") {
        _toLatLng = newPosition;
      }
    });

    // Update the selected field text and clear predictions
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 16));
    _getAddressFromLatLng(newPosition); // Optional, to fetch the address
    setState(() {
      if (field == "from") {
        _fromController.text = prediction.description ?? "";
      } else if (field == "to") {
        _toController.text = prediction.description ?? "";
      }
      _predictions.clear();
    });
  }

  Future<BitmapDescriptor> _getCustomMarker() async {
    String imagePath = Platform.isIOS
        ? 'assets/icons/ios_location_pin.png'
        : 'assets/icons/locationPin.png';

    return BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      imagePath,
    ).catchError((error) {
      print("Error loading custom marker: $error");
      return BitmapDescriptor.defaultMarker;
    });
  }

  void _updateMarkersAndCircles() async {
    BitmapDescriptor customMarker = await _getCustomMarker();

    setState(() {
      _currentLocationCircle = Circle(
        circleId: const CircleId("currentLocationCircle"),
        center: _currentPosition!,
        radius: _animation.value,
        strokeColor: const Color(0xff333399).withOpacity(0.20),
        strokeWidth: 2,
        fillColor: const Color(0xff5000FF).withOpacity(0.16),
      );

      _centerDotCircle = Circle(
        circleId: const CircleId("centerDotCircle"),
        center: _currentPosition!,
        radius: 8, // Fixed radius for the center dot
        strokeColor: const Color(0xff2D0090),
        strokeWidth: 2,
        fillColor: const Color(0xff2D0090),
      );

      _pinMarker = Marker(
        markerId: const MarkerId("selectedLocation"),
        position: _selectedPosition!,
        draggable: true,
        icon: customMarker,
        onDragEnd: (newPosition) {
          setState(() {
            _isPinDragged = true;
          });
          _getAddressFromLatLng(newPosition);
        },
        infoWindow: const InfoWindow(
          title: "Place the pin accurately on the map",
        ),
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

  void _toggle3DView() {
    if (_controller != null && _currentPosition != null) {
      _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition!,
            zoom: 16.0,
            tilt: _is3DView ? 0.0 : 45.0, // Toggle tilt for 3D view
            bearing: _is3DView ? 0.0 : 45.0, // Toggle bearing for 3D effect
          ),
        ),
      );
      setState(() {
        _is3DView = !_is3DView;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime? _selectedDateTime;

    LiveOfferController liveOfferController = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "  Create your pool  ",
              style: TextStyle(fontSize: 16, fontFamily: "MontserratM"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                CurrentLocationField(fromController: _fromController),
                // googleApiKey: "AIzaSyBoAHaJWyiCrTL4UnoE0I7jEpYja872Psk",
              ],
            ),
          ),
          // Map section
          Expanded(
            child: Stack(
              children: [
                _currentPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition!,
                          zoom: 14.0,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _controller = controller;
                          _controller!.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: _currentPosition!,
                                zoom: 14.0,
                              ),
                            ),
                          );
                        },
                        markers: _pinMarker != null ? {_pinMarker!} : {},
                        circles: _currentLocationCircle != null
                            ? {_currentLocationCircle!}
                            : {},
                      ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: _toggle3DView,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: const Color(0xffFF8D41),
                        ),
                        child: Text(
                          _is3DView
                              ? "2D View"
                              : "3D View", // Change text based on the current view
                          style: const TextStyle(
                            fontFamily: "MontserratM",
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            const BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              "$poolingUsers",
                              style: const TextStyle(
                                  fontFamily: "MontserratSB",
                                  fontSize: 16,
                                  color: Color(0xffFF8D41)),
                            ),
                            Text(
                              (poolingUsers > 1)
                                  ? "users near you"
                                  : "user near you",
                              style: const TextStyle(
                                  fontFamily: "MontserratM", fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // New Radius and Wait Time Pickers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                DestinationLocationField(toController: _toController),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              indent: 25,
                              thickness: 1,
                              color: Color(0xffFF8D41),
                            ),
                          ),
                          Text(
                            "  Select your cab time ",
                            style: TextStyle(
                              fontFamily: "MontserratM",
                              fontSize: 16,
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              endIndent: 25,
                              thickness: 1,
                              color: Color(0xffFF8D41),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            height: 200,
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: CupertinoDatePicker(
                              itemExtent: 36,
                              mode: CupertinoDatePickerMode.dateAndTime,
                              initialDateTime: DateTime.now(),
                              onDateTimeChanged: (DateTime newTime) {
                                setState(() {
                                  _selectedDateTime = newTime;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Start Pooling button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GetBuilder<LiveOfferController>(
              builder: (LiveOfferController liveOfferInstance) {
                return liveOfferInstance.createLiveOfferState ==
                        CreateLiveOfferState.creating
                    ? Container(
                        child: LinearProgressIndicator(
                        color: Colors.orange,
                      ))
                    : ElevatedButton(
                        onPressed: () {
                          CreateLiveOfferPayload payload =
                              CreateLiveOfferPayload(
                            liveOffer: LiveOffer(
                                seats: 2,
                                livePartnerId: 7,
                                expiryAt: _selectedDateTime),
                            locationData: LocationData(
                              // HARD CODING NOW SINCE API KEY IS NOT WORKINGs
                              from: From(latitude: 42, longitude: 90),
                              to: From(latitude: 36, longitude: 72),
                            ),
                          );
                          liveOfferInstance.createLiveOffer(payload);
                          setState(() {});
                          debugPrint("Live offer created here");
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatPage(chat: ,) ),);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: const Color(0xffFF8D41),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: (isLoading)
                            ? const CircularProgressIndicator()
                            : const Text(
                                "Confirm",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: "MontserratSB",
                                    color: Colors.white),
                              ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
