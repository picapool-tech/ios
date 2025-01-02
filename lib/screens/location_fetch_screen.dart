import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/location/location_provider.dart';
import 'package:picapool/functions/user/user_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_google_maps_webservices/places.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  LatLng? _selectedPosition;
  String _locationMessage = "Fetching location...";
  bool _locationEnabled = true;
  Marker? _pinMarker;
  Circle? _currentLocationCircle;
  Circle? _centerDotCircle;
  late LatLng _currentCameraPosition;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _is3DView = false;
  bool _isPinDragged = false;

  final TextEditingController _searchController = TextEditingController();
  List<String> savedLocations = [];
  List<Prediction> _predictions = [];
  bool _isKeyboardVisible = false;

  final LocationController _locationController = Get.find<LocationController>();
  final AuthController _authController = Get.find<AuthController>();
  final UserController _userController = Get.find<UserController>();

  final GoogleMapsPlaces _places = GoogleMapsPlaces(
    apiKey: 'AIzaSyBoAHaJWyiCrTL4UnoE0I7jEpYja872Psk',
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocation();
      //
      _loadSavedLocations();
      _animationController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      )..repeat(reverse: false);

      _animation = Tween<double>(begin: 0, end: 100).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));

      _checkKeyboardVisibility();
    });
  }

  void _checkKeyboardVisibility() {
    if (MediaQuery.of(context).viewInsets.bottom != 0) {
      setState(() {
        _isKeyboardVisible = true;
      });
    } else {
      setState(() {
        _isKeyboardVisible = false;
      });
    }
  }

  Future<void> _loadSavedLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedLocations = prefs.getStringList('saved_locations') ?? [];
    });
  }

  Future<void> _saveLocation(String location) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedLocations.add(location);
    await prefs.setStringList('saved_locations', savedLocations);
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation({
    bool fetchActualLocation = false,
  }) async {
    // bool serviceEnabled;
    // LocationPermission permission;

    // serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   setState(() {
    //     _locationEnabled = false;
    //     _locationMessage = "Device location is not enabled.";
    //   });
    //   return;
    // }

    // permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.denied) {
    //   permission = await Geolocator.requestPermission();
    //   if (permission == LocationPermission.denied) {
    //     setState(() {
    //       _locationEnabled = false;
    //       _locationMessage = "Location permissions are denied.";
    //     });
    //     return;
    //   }
    // }

    // if (permission == LocationPermission.deniedForever) {
    //   setState(() {
    //     _locationEnabled = false;
    //     _locationMessage = "Location permissions are permanently denied.";
    //   });
    //   return;
    // }

    // setState(() {
    //   _locationEnabled = true;
    // });

    // final LocationController locationController =
    //     Get.find<LocationController>();
    // await locationController.getLocation();

    // Position position = await Geolocator.getCurrentPosition(
    //     locationSettings: const LocationSettings(
    //   accuracy: LocationAccuracy.high,
    //   distanceFilter: 10,
    // ));
    if (fetchActualLocation ||
        _locationController.state.value.location == null) {
      await _locationController.getLocation();
    }

    var location = _locationController.state.value.location;
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

      _selectedPosition = _currentPosition;
      _updateMarkersAndCircles();
    });
  }

  Future<BitmapDescriptor> _getCustomMarker() async {
    String imagePath = Platform.isIOS
        ? 'assets/icons/ios_location_pin.png'
        : 'assets/icons/locationPin.png';

    return BitmapDescriptor.fromAssetImage(
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

  Future<void> _selectPlace(Prediction prediction) async {
    final placeId = prediction.placeId;
    if (placeId == null) return;

    var details = await _places.getDetailsByPlaceId(placeId);
    final location = details.result.geometry?.location;
    if (location == null) return;

    LatLng newPosition = LatLng(location.lat, location.lng);
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 16));
    _selectedPosition = newPosition;
    _getAddressFromLatLng(newPosition);

    setState(() {
      _searchController.text = prediction.description ?? "";
      _predictions.clear();
    });
  }

  void _navigateToSavedLocation(String location) async {
    _searchController.text = location;
    await _searchPlaces(location);
    if (_predictions.isNotEmpty) {
      _selectPlace(_predictions.first);
    }
  }

  void _toggle3DView() {
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition!,
            zoom: 16.0,
            tilt: _is3DView ? 0.0 : 45.0,
            bearing: _is3DView ? 0.0 : 45.0,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkKeyboardVisibility();
    });

    return Scaffold(
      body: Stack(
        children: [
          if (_currentPosition != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 16,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _animationController.addListener(() {
                  setState(() {
                    _updateMarkersAndCircles();
                  });
                });
              },
              markers: {
                if (_pinMarker != null) _pinMarker!,
              },
              circles: {
                if (_currentLocationCircle != null) _currentLocationCircle!,
                if (_centerDotCircle != null)
                  _centerDotCircle!, // Add the center dot circle
              },
              onCameraMove: (CameraPosition position) {
                _selectedPosition = position.target;
                _updateMarkersAndCircles();
              },
              onCameraIdle: () {
                if (_selectedPosition != null) {
                  _getAddressFromLatLng(_selectedPosition!);
                }
              },
            ),
          if (_currentPosition == null)
            const Center(child: CircularProgressIndicator()),

          // Floating container for "Device Location Not enable"
          if (!_locationEnabled)
            Positioned(
              top: 150,
              left: 20,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.location_off, color: Colors.orange),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            child: Text(
                              "Device Location Not enable",
                              style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          FittedBox(
                            child: Text(
                              "Enable for better Experience",
                              style: GoogleFonts.montserrat(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: () =>
                          _fetchLocation(fetchActualLocation: true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor:
                            const Color(0xffFF8D41).withOpacity(0.50),
                      ),
                      child: Text(
                        "Enable",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  // child: ImageIcon(AssetImage("assets/icons/back_arrow.png"), color: Color(0xffFF8D41), size: 24,),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.orange),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
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
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for areas, street...',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontFamily: 'MontserratR',
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(
                                10.0), // Adjust the padding if needed
                            child: Image.asset(
                              'assets/icons/Minimalistic Magnifer.png', // Replace with your asset path
                              width: 16,
                              height: 16,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Padding(
                              padding: const EdgeInsets.all(
                                  1.0), // Adjust the padding if needed
                              child: Image.asset(
                                'assets/icons/heart.png', // Replace with your asset path
                                width: 24,
                                height: 24,
                              ),
                            ),
                            onPressed: () {
                              if (_searchController.text.isNotEmpty) {
                                _saveLocation(_searchController.text);
                              }
                            },
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (value) {
                          _searchPlaces(value);
                        },
                        onTap: () {
                          setState(() {
                            _isKeyboardVisible = true;
                          });
                        },
                      )),
                ),
              ],
            ),
          ),

          // Floating 3D View Button
          Positioned(
            top: 110,
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
                    backgroundColor: Colors.orange,
                  ),
                  child: Text(
                    _is3DView ? "2D View" : "3D View",
                    style: const TextStyle(
                      fontFamily: "MontserratM",
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_predictions.isNotEmpty)
            Positioned(
              top: 120,
              left: 20,
              right: 20,
              child: Container(
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
                constraints: BoxConstraints(
                    maxHeight: savedLocations.isNotEmpty ? 150 : 300),
                child: ListView.builder(
                  itemCount: _predictions.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var prediction = _predictions[index];
                    return ListTile(
                      title: Text(
                        prediction.description ?? '',
                        style: const TextStyle(
                            color: Color(0xff363636),
                            fontFamily: "MontserratR",
                            fontSize: 12),
                      ),
                      onTap: () {
                        _selectPlace(prediction);
                      },
                    );
                  },
                ),
              ),
            ),

          // "Drag Pin to confirm your location" Text
          if (!_isPinDragged)
            Positioned(
              bottom: 150,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    "Drag Pin to confirm your location",
                    style: GoogleFonts.montserrat(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

          if (!_isKeyboardVisible && savedLocations.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 350,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 250,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _fetchLocation(fetchActualLocation: true),
                        icon: Image.asset(
                          'assets/icons/locationgoto.png', // Replace with your asset path
                          width: 24,
                          height: 24,
                        ),
                        label: const Text(
                          "Go to current location",
                          style: TextStyle(fontFamily: "MontserratM"),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color(0xffFF8D41),
                          backgroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: const BorderSide(color: Color(0xffF0F0F0)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Color(0xffFF8D41),
                          ),
                        ),
                        Text(
                          "  Saved locations  ",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Color(0xffFF8D41),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: savedLocations.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                savedLocations[index],
                                style: GoogleFonts.montserrat(),
                              ),
                              onTap: () {
                                _navigateToSavedLocation(savedLocations[index]);
                              },
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(
                            color: Color(0xffFF8D41),
                            thickness: 1,
                            indent: 50,
                            endIndent: 50,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: () async {
                          await _userController.updateUser({
                            "loc": {
                              "lat": _selectedPosition!.latitude,
                              "lng": _selectedPosition!.longitude
                            }
                          });

                          debugPrint("Location user of : $_locationMessage");
                          await _locationController.updateLocation(
                            geocoding.Location(
                              latitude: _selectedPosition!.latitude,
                              longitude: _selectedPosition!.longitude,
                              timestamp: DateTime.timestamp(),
                            ),
                          );
                          if (context.mounted) {
                            Navigator.pop(context, _locationMessage);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffFF8D41),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Obx(() {
                          if (_locationController.state.value.isLoading ||
                              _userController.isLoading.value) {
                            return const CircularProgressIndicator();
                          }

                          return const Text(
                            "Confirm Location",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "MontserratSB",
                              fontSize: 14,
                            ),
                          );
                        })),
                  ],
                ),
              ),
            ),
          if (!_isKeyboardVisible && savedLocations.isEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 250,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _fetchLocation(fetchActualLocation: true),
                        icon: const Icon(Icons.my_location),
                        label: const Text("Go to current location"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          backgroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: const BorderSide(color: Color(0xffF0F0F0)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await _userController.updateUser({
                          "loc": {
                            "lat": _selectedPosition!.latitude,
                            "lng": _selectedPosition!.longitude
                          }
                        });

                        debugPrint("Location user of : $_locationMessage");
                        await _locationController.updateLocation(
                          geocoding.Location(
                            latitude: _selectedPosition!.latitude,
                            longitude: _selectedPosition!.longitude,
                            timestamp: DateTime.timestamp(),
                          ),
                        );
                        if (context.mounted) {
                          Navigator.pop(context, _locationMessage);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFF8D41),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Obx(
                        () {
                          if (_locationController.state.value.isLoading ||
                              _userController.isLoading.value) {
                            return const CircularProgressIndicator();
                          }

                          return const Text(
                            "Confirm Location",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "MontserratSB",
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
