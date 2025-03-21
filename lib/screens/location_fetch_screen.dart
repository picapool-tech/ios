import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picapool/features/location/location_provider.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/features/user/values/user_data_model_enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with SingleTickerProviderStateMixin {
  // Constants
  static const String _prefsKey = 'saved_locations';
  static const Duration _animationDuration = Duration(seconds: 2);
  static const double _defaultZoom = 16.0;
  static const double _defaultTilt3D = 45.0;

  // Controllers
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Location state
  LatLng? _currentPosition;
  LatLng? _selectedPosition;
  String _locationMessage = "Fetching location...";
  bool _locationEnabled = false;
  bool _is3DView = false;
  bool _isPinDragged = false;
  bool _isKeyboardVisible = false;
  bool _isLoading = true;

  // Map elements
  Marker? _pinMarker;
  Circle? _currentLocationCircle;
  Circle? _centerDotCircle;

  // Search state
  List<String> savedLocations = [];
  List<Prediction> _predictions = [];
  Timer? _debounceTimer;

  // Dependencies
  final LocationController _locationController = Get.find<LocationController>();
  final UserController _userController = Get.find<UserController>();
  late final GoogleMapsPlaces _places;

  // Cached marker icon
  BitmapDescriptor? _cachedMarkerIcon;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkKeyboardVisibility();
    });

    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          _buildTopBarWithSearch(),
          if (!_locationEnabled) _buildLocationEnableBar(),
          _buildView3DToggleButton(),
          if (!_isPinDragged) _buildDragPinHint(),
          _buildPredictionsList(),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.removeListener(_onAnimationUpdate);
    _animationController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializePlaces();
    _initializeAnimation();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeScreen();
    });
  }

  Widget _buildBackButton() {
    return Container(
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
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.orange),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildBottomPanel() {
    if (_isKeyboardVisible) return const SizedBox.shrink();

    if (savedLocations.isEmpty) {
      return _buildSimpleBottomPanel();
    } else {
      return _buildFullBottomPanel();
    }
  }

  Widget _buildConfirmLocationButton() {
    return ElevatedButton(
      onPressed: _onConfirmLocation,
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
          return const CircularProgressIndicator(color: Colors.white);
        }
        return const Text(
          "Confirm Location",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "MontserratSB",
            fontSize: 14,
          ),
        );
      }),
    );
  }

  Widget _buildDragPinHint() {
    return Positioned(
      bottom: 150,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, color: Colors.orange),
              const SizedBox(width: 4),
              Text(
                "Drag Pin to confirm your location",
                style: GoogleFonts.montserrat(
                  color: Colors.orange,
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullBottomPanel() {
    return Positioned(
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
            _buildGoToCurrentLocationButton(),
            const SizedBox(height: 16),
            _buildSavedLocationsHeader(),
            const SizedBox(height: 8),
            _buildSavedLocationsList(),
            const SizedBox(height: 16),
            _buildConfirmLocationButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildGoToCurrentLocationButton() {
    return SizedBox(
      width: 250,
      child: ElevatedButton.icon(
        onPressed: () => _fetchLocation(fetchActualLocation: true),
        icon: Image.asset(
          'assets/icons/locationgoto.png',
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
    );
  }

  Widget _buildLocationEnableBar() {
    return Positioned(
      top: 150,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              color: Colors.orange,
            ),
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
              onPressed: () => _fetchLocation(fetchActualLocation: true),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: const Color(0xffFF8D41).withOpacity(0.50),
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
    );
  }

  Widget _buildMap() {
    if (_isLoading || _currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _currentPosition!,
        zoom: _defaultZoom,
      ),
      onMapCreated: _onMapCreated,
      markers: _pinMarker != null ? {_pinMarker!} : {},
      circles: {
        if (_currentLocationCircle != null) _currentLocationCircle!,
        if (_centerDotCircle != null) _centerDotCircle!,
      },
      onCameraMove: _onCameraMove,
      onCameraIdle: _onCameraIdle,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      compassEnabled: true,
      zoomControlsEnabled: false,
    );
  }

  Widget _buildPredictionsList() {
    if (_predictions.isEmpty) return const SizedBox.shrink();

    return Positioned(
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
        constraints:
            BoxConstraints(maxHeight: savedLocations.isNotEmpty ? 150 : 300),
        child: ListView.builder(
          itemCount: _predictions.length,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            var prediction = _predictions[index];
            return ListTile(
              dense: true,
              title: Text(
                prediction.description ?? '',
                style: const TextStyle(
                    color: Color(0xff363636),
                    fontFamily: "MontserratR",
                    fontSize: 12),
              ),
              onTap: () => _selectPlace(prediction),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSavedLocationsHeader() {
    return Row(
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
    );
  }

  Widget _buildSavedLocationsList() {
    return Expanded(
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
              onTap: () => _navigateToSavedLocation(savedLocations[index]),
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
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 4),
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
          filled: false,
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(
              'assets/icons/Minimalistic Magnifer.png',
              width: 16,
              height: 16,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: _debouncedSearchPlaces,
        onTap: () {
          setState(() {
            _isKeyboardVisible = true;
          });
        },
      ),
    );
  }

  Widget _buildSimpleBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGoToCurrentLocationButton(),
            const SizedBox(height: 16),
            _buildConfirmLocationButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBarWithSearch() {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBackButton(),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSearchBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildView3DToggleButton() {
    return Positioned(
      top: 110,
      right: 16,
      child: ElevatedButton(
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
    );
  }

  Future<void> _cacheMarkerIcon() async {
    _cachedMarkerIcon = await _getCustomMarker();
  }

  void _checkKeyboardVisibility() {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    if (isKeyboardOpen != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = isKeyboardOpen;
      });
    }
  }

  void _debouncedSearchPlaces(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchPlaces(query);
    });
  }

  Future<void> _fetchLocation({bool fetchActualLocation = false}) async {
    setState(() => _isLoading = true);

    try {
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
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _currentPosition = LatLng(location.latitude, location.longitude);
        _selectedPosition = _currentPosition;
        _isLoading = false;
      });
      await _updateMarkersAndCircles();
      _mapController?.animateCamera(CameraUpdate.newLatLng(_selectedPosition!));
      _getAddressFromLatLng(_selectedPosition!);
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar("Error", "Failed to fetch location: $e",
          snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = [
          place.street,
          place.locality,
          place.postalCode,
          place.country
        ].where((element) => element != null && element.isNotEmpty).join(", ");

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
    } catch (e) {
      debugPrint("Error getting address: $e");
    }
  }

  Future<BitmapDescriptor> _getCustomMarker() async {
    if (_cachedMarkerIcon != null) return _cachedMarkerIcon!;

    String imagePath = Platform.isIOS
        ? 'assets/icons/ios_location_pin.png'
        : 'assets/icons/locationPin.png';

    return BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      imagePath,
    ).catchError((error) {
      debugPrint("Error loading custom marker: $error");
      return BitmapDescriptor.defaultMarker;
    });
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    )..repeat(reverse: false);

    _animation = Tween<double>(begin: 0, end: 100).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.addListener(_onAnimationUpdate);
  }

  void _initializePlaces() {
    // TODO: Move API key to secure environment variables
    _places = GoogleMapsPlaces(
      apiKey: 'AIzaSyBoAHaJWyiCrTL4UnoE0I7jEpYja872Psk',
    );
  }

  Future<void> _initializeScreen() async {
    _loadSavedLocations();
    await _fetchLocation();
    _locationEnabled = await _locationController.isLocationEnabled();
    _isLoading = false;
    _checkKeyboardVisibility();
    await _cacheMarkerIcon();
    if (mounted) setState(() {});
  }

  Future<void> _loadSavedLocations() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        savedLocations = prefs.getStringList(_prefsKey) ?? [];
      });
    } catch (e) {
      debugPrint("Error loading saved locations: $e");
    }
  }

  void _navigateToSavedLocation(String location) async {
    _searchController.text = location;
    await _searchPlaces(location);
    if (_predictions.isNotEmpty) {
      _selectPlace(_predictions.first);
    }
  }

  void _onAnimationUpdate() {
    if (mounted) {
      setState(() {
        _updateMarkersAndCircles();
      });
    }
  }

  void _onCameraIdle() {
    if (_selectedPosition != null) {
      _getAddressFromLatLng(_selectedPosition!);
    }
  }

  void _onCameraMove(CameraPosition position) {
    _selectedPosition = position.target;
    _updateMarkersAndCircles();
  }

  Future<void> _onConfirmLocation() async {
    if (_selectedPosition == null) {
      await _fetchLocation();
      return;
    }

    var storageController = Get.find<StorageController>();
    var backupUser = storageController.user.value;

    try {
      var isUpdated = await _userController.updateUser([UserField.location],
          previousUser: backupUser, customExecution: (userField) {
        return MapEntry("loc", {
          "lat": _selectedPosition!.latitude,
          "lng": _selectedPosition!.longitude
        });
      });

      if (!isUpdated) {
        Get.snackbar("Error", "Failed to update location",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      await _locationController.updateLocation(
        geocoding.Location(
          latitude: _selectedPosition!.latitude,
          longitude: _selectedPosition!.longitude,
          timestamp: DateTime.timestamp(),
        ),
        isUserSelected: _selectedPosition != _currentPosition,
      );

      if (mounted) {
        Navigator.pop(context, _locationMessage);
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _saveLocation(String location) async {
    if (savedLocations.contains(location)) return; // Don't add duplicates

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      savedLocations.add(location);
      await prefs.setStringList(_prefsKey, savedLocations);
      setState(() {});
    } catch (e) {
      debugPrint("Error saving location: $e");
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _predictions.clear();
      });
      return;
    }

    try {
      var sessionToken = 'session_${DateTime.now().millisecondsSinceEpoch}';
      var response =
          await _places.autocomplete(query, sessionToken: sessionToken);

      if (response.isOkay) {
        setState(() {
          _predictions = response.predictions;
        });
      } else {
        debugPrint("Place search error: ${response.errorMessage}");
      }
    } catch (e) {
      debugPrint("Error searching places: $e");
    }
  }

  Future<void> _selectPlace(Prediction prediction) async {
    final placeId = prediction.placeId;
    if (placeId == null) return;

    try {
      var details = await _places.getDetailsByPlaceId(placeId);
      final location = details.result.geometry?.location;
      if (location == null) return;

      LatLng newPosition = LatLng(location.lat, location.lng);

      // Add to saved locations if not already there
      final locationDescription = prediction.description;
      if (locationDescription != null && locationDescription.isNotEmpty) {
        _saveLocation(locationDescription);
      }

      _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newPosition, _defaultZoom));
      _selectedPosition = newPosition;
      _getAddressFromLatLng(newPosition);

      setState(() {
        _searchController.text = prediction.description ?? "";
        _predictions.clear();
        _isKeyboardVisible = false;
      });

      // Hide keyboard
      FocusScope.of(context).unfocus();
    } catch (e) {
      debugPrint("Error selecting place: $e");
    }
  }

  void _toggle3DView() {
    if (_mapController != null && _selectedPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _selectedPosition!,
            zoom: _defaultZoom,
            tilt: _is3DView ? 0.0 : _defaultTilt3D,
            bearing: _is3DView ? 0.0 : _defaultTilt3D,
          ),
        ),
      );
      setState(() {
        _is3DView = !_is3DView;
      });
    }
  }

  Future<void> _updateMarkersAndCircles() async {
    if (_currentPosition == null || _selectedPosition == null) return;

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
        radius: 8,
        strokeColor: const Color.fromARGB(255, 192, 237, 11),
        strokeWidth: 2,
        fillColor: const Color.fromARGB(255, 158, 227, 146),
      );

      _pinMarker = Marker(
        markerId: const MarkerId("selectedLocation"),
        position: _selectedPosition!,
        draggable: true,
        icon: _cachedMarkerIcon ?? BitmapDescriptor.defaultMarker,
        onDragEnd: (newPosition) {
          setState(() {
            _isPinDragged = true;
            _selectedPosition = newPosition;
          });
          _getAddressFromLatLng(newPosition);
        },
        infoWindow: const InfoWindow(
          title: "Place the pin accurately on the map",
        ),
      );
    });
  }
}
