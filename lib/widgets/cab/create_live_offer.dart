import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:picapool/common/widgets/blurry_container.dart';
import 'package:picapool/controllers/live_offer_controller.dart';
import 'package:picapool/features/location/location_controller.dart';
import 'package:picapool/models/live_offer/create_live_offer_payload.dart';
import 'package:picapool/models/live_offer_model.dart';
import 'package:picapool/models/vicinity_offer_model.dart';
import 'package:picapool/screens/public_chat/chat_page.dart';

// Move the polyline decoding function outside of the class so it can be used in the isolate
List<Map<String, double>> _decodePolylinePoints(String encoded) {
  List<Map<String, double>> poly = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    poly.add({
      'lat': (lat / 1E5).toDouble(),
      'lng': (lng / 1E5).toDouble(),
    });
  }
  return poly;
}

// Static function for compute - needs to be outside the class
Future<Map<String, dynamic>> _fetchDirectionsIsolate(
    Map<String, dynamic> params) async {
  final fromLat = params['fromLat'];
  final fromLng = params['fromLng'];
  final toLat = params['toLat'];
  final toLng = params['toLng'];
  final apiKey = params['apiKey'];

  final response = await http
      .get(Uri.parse('https://maps.googleapis.com/maps/api/directions/json?'
          'origin=$fromLat,$fromLng'
          '&destination=$toLat,$toLng'
          '&key=$apiKey'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
      // Decode polyline points in the background thread
      final points = data['routes'][0]['overview_polyline']['points'];
      final decodedPoints = _decodePolylinePoints(points);

      // Simplify the route to reduce the number of points
      final simplifiedPoints = _simplifyRoute(decodedPoints);

      return {
        'success': true,
        'data': data,
        'decodedPoints': simplifiedPoints, // Use simplified points
        'routeDetails': {
          'distance': data['routes'][0]['legs'][0]['distance'],
          'duration': data['routes'][0]['legs'][0]['duration'],
          'startAddress': data['routes'][0]['legs'][0]['start_address'],
          'endAddress': data['routes'][0]['legs'][0]['end_address'],
        }
      };
    } else {
      return {
        'success': false,
        'error': 'Failed to get directions: ${data['status']}',
      };
    }
  } else {
    return {
      'success': false,
      'error': 'Failed to connect to directions service',
    };
  }
}

// Add a route simplification algorithm to reduce the number of points
List<Map<String, double>> _simplifyRoute(List<Map<String, double>> points) {
  if (points.length <= 2) return points;

  // Always include start and end points
  List<Map<String, double>> simplified = [points.first];

  // The tolerance determines how much simplification to apply
  // Smaller values = less simplification, larger values = more simplification
  double toleranceSquared = 0.00001; // Adjust based on your needs

  // If the route is very long, increase the tolerance
  if (points.length > 100) {
    toleranceSquared = 0.0001;
  }

  Map<String, double> lastPoint = points.first;

  for (int i = 1; i < points.length - 1; i++) {
    final point = points[i];

    // Calculate squared distance between current point and last added point
    final dx = point['lat']! - lastPoint['lat']!;
    final dy = point['lng']! - lastPoint['lng']!;
    final distSquared = dx * dx + dy * dy;

    // Check if the point is far enough from the last added point
    if (distSquared > toleranceSquared) {
      simplified.add(point);
      lastPoint = point;
    }
  }

  // Make sure to add the last point
  if (points.last != simplified.last) {
    simplified.add(points.last);
  }

  // Ensure we don't simplify too aggressively for short routes
  if (simplified.length < 5 && points.length > 10) {
    // Add some intermediate points for very simplified routes
    int step = points.length ~/ 5;
    for (int i = step; i < points.length - step; i += step) {
      if (!simplified.contains(points[i])) {
        simplified.add(points[i]);
      }
    }
    // Re-sort points by original order
    simplified.sort((a, b) {
      int indexA = points.indexOf(a);
      int indexB = points.indexOf(b);
      return indexA.compareTo(indexB);
    });
  }

  return simplified;
}

class CreateLiveOffer extends StatefulWidget {
  const CreateLiveOffer({super.key});

  @override
  State<CreateLiveOffer> createState() => _CreateLiveOfferState();
}

class LocationSearchDelegate extends SearchDelegate<Prediction> {
  final GoogleMapsPlaces places;
  final bool isFromField;

  LocationSearchDelegate({
    required this.places,
    this.isFromField = true,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
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
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text(
          'Search for ${isFromField ? 'pickup' : 'drop-off'} location',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

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
          return const Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xffFF8D41)),
          ));
        }

        final predictions = snapshot.data!.predictions;

        if (predictions.isEmpty) {
          return const Center(
            child: Text('No locations found. Try a different search.'),
          );
        }

        return ListView.builder(
          itemCount: predictions.length,
          itemBuilder: (context, index) {
            final prediction = predictions[index];
            return ListTile(
              leading: const Icon(Icons.location_on, color: Color(0xffFF8D41)),
              title: Text(prediction.description ?? ''),
              subtitle: Text(
                prediction.structuredFormatting?.secondaryText ?? '',
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () => close(context, prediction),
            );
          },
        );
      },
    );
  }
}

class _CreateLiveOfferState extends State<CreateLiveOffer> {
  // Constants
  static const double _mapPadding = 50.0;
  static const double _defaultZoom = 15.0;
  static const LatLng _defaultPosition = LatLng(28.6139, 77.2090); // New Delhi
  // Controllers
  final LocationController _locationController = Get.find<LocationController>();
  final LiveOfferController _liveOfferController = Get.find();

  final TextEditingController _fromController = TextEditingController();

  final TextEditingController _toController = TextEditingController();
  GoogleMapController? _mapController;
  // Places API
  final GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: 'AIzaSyBoAHaJWyiCrTL4UnoE0I7jEpYja872Psk');
  // UI State
  bool _isLoading = false;
  bool _isSearchingFrom = false;
  final List<Prediction> _predictions = [];
  bool _isLoadingRoute = false;

  // New state for collapsible time picker
  bool _isTimePickerExpanded = false;

  // Location State
  LatLng? _currentPosition;
  LatLng? _fromLatLng;
  LatLng? _toLatLng;

  String? _fromAddress;
  String? _toAddress;

  Circle? _currentLocationCircle;
  // Route State
  List<LatLng> _routePoints = [];

  Map<String, dynamic>? _routeDetails;
  // Time Selection
  DateTime _selectedDateTime = DateTime.now().add(const Duration(minutes: 30));
  DateTime _defaultExpiryDate = DateTime.now().add(const Duration(days: 3));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Create Your Pool",
          style: TextStyle(
            fontSize: 18,
            fontFamily: "MontserratM",
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Location Search Fields
        _buildLocationFields(),

        // Map and Route Display
        Expanded(
          child: Stack(
            children: [
              _buildMap(),
              if (_isLoadingRoute)
                const Center(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xffFF8D41)),
                      ),
                    ),
                  ),
                ),
              if (_routeDetails != null && _routePoints.isNotEmpty)
                _buildRouteInfoCard(),
            ],
          ),
        ),

        // Collapsible Time Selection
        _buildCollapsibleTimeSelection(),

        // Confirm Button
        _buildConfirmButton(),
      ],
    );
  }

  // Replace _buildTimeSelection with a collapsible version
  Widget _buildCollapsibleTimeSelection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isTimePickerExpanded = !_isTimePickerExpanded;
              });
            },
            child: Row(
              children: [
                const Text(
                  "Cab Time",
                  style: TextStyle(
                    fontFamily: "MontserratM",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xffFFF5ED),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: const Color(0xffFF8D41), width: 1),
                  ),
                  child: Text(
                    _formatDateTime(_selectedDateTime),
                    style: const TextStyle(
                      color: Color(0xffFF8D41),
                      fontFamily: "MontserratM",
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  _isTimePickerExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xffFF8D41),
                ),
              ],
            ),
          ),
          // Expandable time picker section
          if (_isTimePickerExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isTimePickerExpanded ? 120 : 0,
              child: CupertinoDatePicker(
                minimumDate: DateTime.now(),
                initialDateTime: _selectedDateTime,
                onDateTimeChanged: (dateTime) {
                  setState(() => _selectedDateTime = dateTime);
                },
                backgroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GetBuilder<LiveOfferController>(
        builder: (controller) {
          final isCreating =
              controller.createLiveOfferState == CreateLiveOfferState.creating;

          return isCreating
              ? const LinearProgressIndicator(
                  color: Color(0xffFF8D41),
                  backgroundColor: Colors.white,
                )
              : ElevatedButton(
                  onPressed: _fromLatLng != null && _toLatLng != null
                      ? _handleCreateLiveOffer
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xffFF8D41),
                    disabledBackgroundColor: Colors.grey.shade300,
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
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String label,
    required bool isFromField,
    required IconData icon,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'Search for $label location...',
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontFamily: 'MontserratR',
            fontSize: 14,
          ),
          border: InputBorder.none,
          filled: false,
          prefixIcon: Icon(icon, color: const Color(0xffFF8D41)),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () {
                    setState(() {
                      controller.clear();
                      if (isFromField) {
                        _fromLatLng = null;
                        _fromAddress = null;
                      } else {
                        _toLatLng = null;
                        _toAddress = null;
                      }
                      // Clear route if either point is removed
                      if (_fromLatLng == null || _toLatLng == null) {
                        _clearRoute();
                      }
                    });
                  },
                )
              : null,
        ),
        onTap: () => _handleLocationFieldTap(isFromField),
      ),
    );
  }

  Widget _buildLocationFields() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildLocationField(
            controller: _fromController,
            label: 'pickup',
            isFromField: true,
            icon: Icons.my_location,
          ),
          const SizedBox(height: 12),
          _buildLocationField(
            controller: _toController,
            label: 'drop-off',
            isFromField: false,
            icon: Icons.location_on,
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPosition ?? _defaultPosition,
            zoom: _defaultZoom,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false, // We'll add our own button
          compassEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onTap: (LatLng position) {
            // Show a dialog with location options
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Set Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'MontserratSB',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading:
                          const Icon(Icons.location_on, color: Colors.green),
                      title: const Text('Set as pickup point'),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _fromLatLng = position;
                        });
                        _handleMarkerDragEnd(true, position);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.red),
                      title: const Text('Set as drop-off point'),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _toLatLng = position;
                        });
                        _handleMarkerDragEnd(false, position);
                      },
                    ),
                    if (_locationController.state.value.location != null)
                      ListTile(
                        leading: const Icon(Icons.my_location,
                            color: Color(0xffFF8D41)),
                        title: const Text('Use my current location'),
                        onTap: () {
                          Navigator.pop(context);
                          _setCurrentLocationAsPickup();
                        },
                      ),
                  ],
                ),
              ),
            );
          },
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            if (_currentPosition != null) {
              controller.animateCamera(
                CameraUpdate.newLatLngZoom(_currentPosition!, _defaultZoom),
              );
            }
          },
          markers: _buildMarkers(),
          polylines: _buildPolylines(),
          circles:
              _currentLocationCircle != null ? {_currentLocationCircle!} : {},
        ),
        // Add a positioned my location button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            tooltip: 'Use current location as pickup',
            onPressed: () {
              _moveToCurrentLocation();
              _setCurrentLocationAsPickup();
            },
            child: const Icon(
              Icons.my_location,
              color: Color(0xffFF8D41),
            ),
          ),
        ),
        if (_fromLatLng != null || _toLatLng != null)
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: BlurryContainer(
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: const Text(
                  'Long press and drag markers to adjust location',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xffFF8D41),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (_fromLatLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('from'),
          position: _fromLatLng!,
          draggable: true,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow:
              InfoWindow(title: _fromAddress?.split(',').first ?? 'Pickup'),
          onDragStart: (_) {
            // Show visual feedback when drag starts
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Adjusting pickup location...'),
                duration: Duration(seconds: 1),
                backgroundColor: Colors.green,
              ),
            );
          },
          onDrag: (newPosition) {
            // Optional: Update position in real-time while dragging
            // This creates smoother visual feedback during drag
            setState(() {
              _fromLatLng = newPosition;
            });
          },
          onDragEnd: (newPosition) => _handleMarkerDragEnd(true, newPosition),
        ),
      );
    }

    if (_toLatLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('to'),
          position: _toLatLng!,
          draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow:
              InfoWindow(title: _toAddress?.split(',').first ?? 'Destination'),
          onDragStart: (_) {
            // Show visual feedback when drag starts
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Adjusting drop-off location...'),
                duration: Duration(seconds: 1),
                backgroundColor: Colors.red,
              ),
            );
          },
          onDrag: (newPosition) {
            // Optional: Update position in real-time while dragging
            setState(() {
              _toLatLng = newPosition;
            });
          },
          onDragEnd: (newPosition) => _handleMarkerDragEnd(false, newPosition),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    final polylines = <Polyline>{};

    if (_routePoints.isNotEmpty) {
      // Use a single polyline with simplified path
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: _routePoints,
          color: Colors.blue,
          width: 5,
          // Remove pattern for better performance on complex routes
          // patterns: [
          //   PatternItem.dash(20),
          //   PatternItem.gap(10),
          // ],
        ),
      );
    } else if (_fromLatLng != null && _toLatLng != null) {
      // Direct line is simpler and more efficient
      polylines.add(
        Polyline(
          polylineId: const PolylineId('direct'),
          points: [_fromLatLng!, _toLatLng!],
          color: Colors.grey,
          width: 3,
          patterns: [
            PatternItem.dash(10),
            PatternItem.gap(10),
          ],
        ),
      );
    }

    return polylines;
  }

  Widget _buildRouteInfoCard() {
    final distanceText =
        _routeDetails?['distance']?['text'] ?? 'Unknown distance';
    final durationText = _routeDetails?['duration']?['text'] ?? 'Unknown time';

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: BlurryContainer(
        backgroundColor: Colors.white.withOpacity(0.5),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.directions_car,
                color: Color(0xffFF8D41), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    distanceText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Approx. $durationText by car',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              // color: Colors.white,
              onPressed: _getDirections,
              tooltip: 'Refresh route',
            ),
          ],
        ),
      ),
    );
  }

  void _clearRoute() {
    setState(() {
      _routePoints = [];
      _routeDetails = null;
    });
  }

  void _fitRouteOnMap() {
    if (_routePoints.isEmpty || _mapController == null) return;

    try {
      // Sample the route points instead of using all points for calculating bounds
      List<LatLng> sampledPoints = _sampleRoutePoints(_routePoints);

      // Create bounds that include both endpoints and sampled route points
      double minLat = sampledPoints.first.latitude;
      double maxLat = sampledPoints.first.latitude;
      double minLng = sampledPoints.first.longitude;
      double maxLng = sampledPoints.first.longitude;

      for (var point in sampledPoints) {
        minLat = min(minLat, point.latitude);
        maxLat = max(maxLat, point.latitude);
        minLng = min(minLng, point.longitude);
        maxLng = max(maxLng, point.longitude);
      }

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      // Add padding
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, _mapPadding),
      );
    } catch (e) {
      debugPrint('Error fitting map to route: $e');
    }
  }

  // Helper method to format date time in a readable format
  String _formatDateTime(DateTime dateTime) {
    // Format: "May 15, 2023 • 3:30 PM"
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateLabel;
    if (selectedDate == today) {
      dateLabel = "Today";
    } else if (selectedDate == tomorrow) {
      dateLabel = "Tomorrow";
    } else {
      final month = _getMonthName(dateTime.month);
      dateLabel = "$month ${dateTime.day}, ${dateTime.year}";
    }

    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return "$dateLabel • $hour:$minute $period";
  }

  Future<void> _getDirections() async {
    if (_fromLatLng == null || _toLatLng == null) return;

    setState(() => _isLoadingRoute = true);

    try {
      // Clear existing route to prevent rendering two routes simultaneously
      _clearRoute();

      // Prepare parameters for the isolated function
      final params = {
        'fromLat': _fromLatLng!.latitude,
        'fromLng': _fromLatLng!.longitude,
        'toLat': _toLatLng!.latitude,
        'toLng': _toLatLng!.longitude,
        'apiKey': 'AIzaSyBoAHaJWyiCrTL4UnoE0I7jEpYja872Psk',
      };

      // Execute route calculation in background
      final result = await compute(_fetchDirectionsIsolate, params);

      if (result['success']) {
        // Convert decoded points from the isolate to LatLng objects
        List<Map<String, double>> decodedPoints = result['decodedPoints'];
        List<LatLng> routePoints = decodedPoints
            .map((point) => LatLng(point['lat']!, point['lng']!))
            .toList();

        // Batch state updates to reduce UI workload
        setState(() {
          _routePoints = routePoints;
          _routeDetails = result['routeDetails'];
        });

        // Fit map to show the entire route
        _fitRouteOnMap();
      } else {
        // Handle error
        _showError('Route Error', result['error']);
      }
    } catch (e) {
      _showError('Route Error', 'Error getting directions: $e');
      _clearRoute();
    } finally {
      setState(() => _isLoadingRoute = false);
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  void _handleCreateLiveOffer() {
    if (!_validateInputs()) return;

    final payload = CreateLiveOfferPayload(
      createdAt: _selectedDateTime.toUtc().toIso8601String(),
      expiryAt: _updateDefaultExpiryDate(),
      fromAddress: _fromAddress ?? _fromController.text,
      toAddress: _toAddress ?? _toController.text,
      seats: 3, // Consider making this configurable
      from: VicinityLocation(
        lat: _fromLatLng!.latitude,
        long: _fromLatLng!.longitude,
      ),
      to: VicinityLocation(
        lat: _toLatLng!.latitude,
        long: _toLatLng!.longitude,
      ),
    );

    _liveOfferController.createLiveOffer(payload).then((_) {
      if (_liveOfferController.createLiveOfferState ==
          CreateLiveOfferState.created) {
        _handleLiveOfferCreated();
      } else {
        _showError('Creation Failed',
            'Failed to create your cab pool. Please try again.');
      }
    });
  }

  void _handleLiveOfferCreated() {
    final chat =
        _liveOfferController.createLiveOfferResponse?.data?.chats?.firstOrNull;

    if (chat != null && mounted) {
      Get.off(
        () => ChatPage(
          chat: chat,
          chatTitle:
              _liveOfferController.createLiveOfferResponse?.data?.fromAddress ??
                  "Chat",
          liveOffer: LiveOffer.fromJson(
            _liveOfferController.createLiveOfferResponse!.data!.toJson(),
          ),
        ),
      );
    } else {
      if (mounted) {
        _showError(
          'Chat Unavailable',
          'Your cab pool was created successfully, but the chat is not available.',
        );
      }
    }
  }

  Future<void> _handleLocationFieldTap(bool isFromField) async {
    _isSearchingFrom = isFromField;

    if (isFromField && _currentPosition != null && _fromLatLng == null) {
      // For pickup location, offer to use current location
      final useCurrentLocation = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Use Current Location?'),
          content: const Text(
              'Would you like to use your current location as the pickup point?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('SEARCH'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFF8D41),
              ),
              child: const Text('USE CURRENT'),
            ),
          ],
        ),
      );

      if (useCurrentLocation == true) {
        _setCurrentLocationAsPickup();
        return;
      }
    }

    if (!mounted) return;
    final Prediction? result = await showSearch<Prediction>(
      context: context,
      delegate: LocationSearchDelegate(
        places: _places,
        isFromField: isFromField,
      ),
    );

    if (result != null && result.placeId != null) {
      await _selectPlace(result);
    }
  }

  Future<void> _handleMarkerDragEnd(
      bool isFromMarker, LatLng newPosition) async {
    setState(() {
      if (isFromMarker) {
        _fromLatLng = newPosition;
      } else {
        _toLatLng = newPosition;
      }
    });

    // Get address for the new position
    await _reverseGeocode(isFromMarker, newPosition);

    // Recalculate route if both points exist
    if (_fromLatLng != null && _toLatLng != null) {
      await _getDirections();
    }
  }

  // Location methods
  Future<void> _initializeLocation() async {
    setState(() => _isLoading = true);

    try {
      var location = _locationController.state.value.location;

      if (location == null) {
        await _locationController.getLocation();
        return;
      }

      setState(() {
        _currentPosition = LatLng(location.latitude, location.longitude);
        _updateLocationCircle();
      });
      _setCurrentLocationAsPickup();

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, _defaultZoom),
      );
    } catch (e) {
      _showError('Location Error', 'Failed to get your location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _moveToCurrentLocation() {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, _defaultZoom),
      );
    }
  }

  Future<void> _reverseGeocode(bool isFromMarker, LatLng position) async {
    try {
      final response = await http
          .get(Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?'
              'latlng=${position.latitude},${position.longitude}'
              '&key=AIzaSyBoAHaJWyiCrTL4UnoE0I7jEpYja872Psk'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final formattedAddress = data['results'][0]['formatted_address'];

          setState(() {
            if (isFromMarker) {
              _fromAddress = formattedAddress;
              _fromController.text = formattedAddress;
            } else {
              _toAddress = formattedAddress;
              _toController.text = formattedAddress;
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
      // Still update UI with coordinate-based text if geocoding fails
      final coordText =
          '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
      setState(() {
        if (isFromMarker) {
          _fromController.text = 'Custom location ($coordText)';
        } else {
          _toController.text = 'Custom location ($coordText)';
        }
      });
    }
  }

  // Helper method to sample route points for more efficient bounds calculation
  List<LatLng> _sampleRoutePoints(List<LatLng> points) {
    if (points.length <= 10) return points;

    // Always include start and end points
    List<LatLng> sampled = [points.first];

    // Sample middle points
    int step = (points.length / 8).floor();
    for (int i = step; i < points.length - step; i += step) {
      sampled.add(points[i]);
    }

    sampled.add(points.last);
    return sampled;
  }

  Future<void> _selectPlace(Prediction prediction) async {
    final placeId = prediction.placeId;
    if (placeId == null) return;

    setState(() => _isLoading = true);

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

        // If both points are set, get directions
        if (_fromLatLng != null && _toLatLng != null) {
          await _getDirections();
        } else {
          // Just zoom to the selected point
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(newPosition, _defaultZoom),
          );
        }
      }
    } catch (e) {
      _showError('Location Error', 'Failed to get location details: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _setCurrentLocationAsPickup() async {
    if (_currentPosition != null) {
      final location = _locationController.state.value.location;
      final placemark = _locationController.state.value.locationName;

      if (location != null && placemark != null) {
        setState(() {
          _fromLatLng = _currentPosition;
          _fromAddress =
              '${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}';
          _fromController.text = _fromAddress ?? 'Current Location';

          if (_toLatLng != null) {
            _getDirections();
          }
        });
      }
    }
  }

  void _showError(String title, String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(message),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Live Offer creation
  String _updateDefaultExpiryDate() {
    _defaultExpiryDate = _selectedDateTime.add(const Duration(days: 3));
    return _defaultExpiryDate.toUtc().toIso8601String();
  }

  void _updateLocationCircle() {
    if (_currentPosition == null) return;

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

  bool _validateInputs() {
    if (_fromController.text.isEmpty) {
      _showError('Missing Information', 'Please select a pickup location');
      return false;
    }

    if (_toController.text.isEmpty) {
      _showError('Missing Information', 'Please select a drop-off location');
      return false;
    }

    if (_selectedDateTime.isBefore(DateTime.now())) {
      _showError('Invalid Time', 'Please select a future date and time');
      return false;
    }

    return true;
  }
}
