import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/features/location/location_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/features/user/values/user_data_model_enum.dart';
import 'package:picapool/features/vicinity/vicinity_controller.dart';
import 'package:picapool/models/near_user_model.dart';
import 'package:picapool/models/vicinity_offer_model.dart';
import 'package:picapool/screens/products/products_detailed_page.dart';
import 'package:picapool/screens/public_chat/chat_page.dart';
import 'package:picapool/screens/vicinity/values/map_style.dart';
import 'package:picapool/screens/vicinity/widget/expanded_top_widget.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/home/divider.dart';

class RequestVicinity extends StatefulWidget {
  const RequestVicinity({super.key});

  @override
  State<RequestVicinity> createState() => _RequestVicinityState();
}

class _RequestVicinityState extends State<RequestVicinity> {
  final LocationController _locationController = Get.find<LocationController>();
  final VicinityController _vicinityController = Get.find<VicinityController>();
  final UserController _userController = Get.find<UserController>();

  double _radius = 500;
  double _waitTime = 30;
  List<XFile>? _imageFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool _is3DView = true;
  GoogleMapController? _controller;
  LatLng? _currentPosition;
  Circle? _currentLocationCircle;
  bool _isMapInitialized = false; // New flag to check if the map is initialized
  List<NearUserModel> _nearestUsers = [];
  int _userFoundCount = 0;
  final int _maxUsersToShow = 100;
  bool _isLoadingNearbyUser = false;

  bool fromBrands = false;
  BitmapDescriptor? _locationMarker;
  final int _maxCacheEntries = 10;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  int poolingUsers = 0;

  Marker? _userMarker;
  final Set<Marker> _userMarkers = {};

  // Debounce timer to avoid too many calls when scrolling the radius
  Timer? _radiusDebounceTimer;

  double _lastFetchedRadius = 0;

  final Map<int, List<NearUserModel>> _radiusCache = {};

  bool get activeButton =>
      (_userController.user?.id != null && _currentPosition != null);
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: uiOverlayStyle(context),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              VicinityExpandedWidget(
                titleController: _titleController,
                descriptionController: _descController,
                onImagePicker: _pickImages,
                imagesList: _imageFiles,
              ),

              // // Map section
              Expanded(
                child: Stack(
                  children: [
                    _currentPosition == null
                        ? const Center(child: CircularProgressIndicator())
                        : GoogleMap(
                            style: (Theme.of(context).brightness ==
                                    Brightness.dark)
                                ? MapStyle().getDarkModeJson
                                : null,
                            initialCameraPosition: CameraPosition(
                              target: _currentPosition!,
                              zoom: 14.0,
                            ),
                            myLocationEnabled: true,
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
                            markers: {
                              if (_userMarker != null) _userMarker!,
                              for (var marker in _userMarkers) marker,
                            },
                            circles: _currentLocationCircle != null
                                ? {_currentLocationCircle!}
                                : {},
                          ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Column(
                        children: [
                          PicaPrimaryButton(
                            onPressed: _toggle3DView,
                            isSmall: true,
                            isLoading: false.obs,
                            text:
                                // Text(
                                _is3DView
                                    ? "2D View"
                                    : "3D View", // Change text based on the current view
                            // ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.currentTheme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Pooling with ",
                                  style: TextStyle(fontSize: 10),
                                ),
                                if (!_isLoadingNearbyUser)
                                  Text(
                                    "$poolingUsers",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xffFF8D41),
                                    ),
                                  )
                                else
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(),
                                  ),
                                Text(
                                  (poolingUsers > 1) ? "users" : "user",
                                  style: const TextStyle(
                                    fontSize: 10,
                                  ),
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
                    const CustomDivider(
                      text: "Radius and wait time",
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Radius (m)",
                            ),
                            const SizedBox(width: 8),
                            NumberPicker(
                              minValue: 200,
                              maxValue: 3000,
                              value: _radius.toInt(),
                              step: 100,

                              onChanged: (value) {
                                setState(() {
                                  _currentLocationCircle = Circle(
                                    circleId:
                                        const CircleId("currentLocationCircle"),
                                    center: _currentPosition!,
                                    radius: _radius,
                                    strokeColor: Colors.blue,
                                    strokeWidth: 2,
                                    fillColor: Colors.blue.withOpacity(0.3),
                                  );
                                  _radius = value.toDouble();
                                });

                                getNearestUsers(
                                  value.toDouble(),
                                );
                              },
                              itemWidth: 50, // Smaller width
                              textStyle: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                              selectedTextStyle: TextStyle(
                                fontSize: 16,
                                color: AppTheme.currentTheme.indicatorColor,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.grey),
                                  bottom: BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              "Wait Time (min)",
                            ),
                            const SizedBox(width: 8),
                            NumberPicker(
                              minValue: 10,
                              maxValue: 60,
                              value: _waitTime.toInt(),
                              step: 5,
                              onChanged: (value) {
                                setState(() {
                                  _waitTime = value.toDouble();
                                });
                              },
                              itemWidth: 50, // Smaller width
                              textStyle: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              selectedTextStyle: TextStyle(
                                fontSize: 16,
                                color: AppTheme.currentTheme.indicatorColor,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.grey),
                                  bottom: BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Start Pooling button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: PicaPrimaryButton(
                    text: "Start pooling",
                    onPressed: activeButton ? createVicinity : null,
                    isLoading: _vicinityController.isLoading,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createVicinity() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      debugPrint("Please fill all the fields");
      Get.snackbar(
        "Fields required",
        "Please fill all the fields",
      );
      return;
    }

    if (_currentPosition == null ||
        _currentPosition?.latitude == null ||
        _currentPosition?.longitude == null) {
      Get.snackbar(
        "Location required",
        "Please check location services is working",
      );
      await _fetchLocation();
      return;
    }

    var title = fromBrands
        ? "${_titleController.text} - FROM BRANDS"
        : _titleController.text;

    final offer = VicinityOffer(
      name: title,
      images: [],
      desc: _descController.text,
      expiryAt: DateTime.now().add(Duration(minutes: _waitTime.toInt())),
      userId: _userController.user!.id,
      partnerID: null,
      location: VicinityLocation(
        lat: _currentPosition!.latitude,
        long: _currentPosition!.longitude,
      ),
      distance: _radius,
    );

    var receivedOffer = await _vicinityController.createVicinity(
      offer: offer,
      pickedFile: _imageFiles?.firstOrNull,
      uname: _userController.user!.name!,
      offername: _titleController.text,
    );

    if (receivedOffer != null) {
      reset();
      if (receivedOffer.chats?.isNotEmpty ?? false) {
        Get.off(
          () => ChatPage(
            chat: receivedOffer.chats!.first,
            offer: receivedOffer,
            chatTitle: receivedOffer.name,
          ),
        );
      }
    }
  }

  void getNearestUsers(double radius) async {
    if (_currentPosition == null) {
      return;
    }

    // Update UI immediately with cached data if available
    int radiusKey =
        (radius / 100).floor() * 100; // Round to nearest 100m for caching

    if (_radiusCache.containsKey(radiusKey)) {
      _nearestUsers = _radiusCache[radiusKey]!;
      _userFoundCount = _nearestUsers.length;
      _addNearestUserMarkers(limit: _maxUsersToShow);
      setState(() {
        poolingUsers = _userFoundCount;
      });
    }

    if (_radiusCache.length > _maxCacheEntries) {
      _radiusCache.remove(_radiusCache.keys.first);
    }

    // Skip API call if radius is close to the last fetched value (within 100m)
    if (_lastFetchedRadius > 0 && (radius - _lastFetchedRadius).abs() < 100) {
      return;
    }

    // Cancel previous timer if it exists
    _radiusDebounceTimer?.cancel();

    // Set a new timer to make the API call after a short delay
    _radiusDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        _isLoadingNearbyUser = true;
      });

      var nearestUsers = await _userController.getNearestUsers(
        currentPosition: _currentPosition!,
        radius: radius,
      );

      if (nearestUsers != null) {
        _nearestUsers = nearestUsers;
        _radiusCache[radiusKey] = nearestUsers; // Cache the result
        _lastFetchedRadius = radius;
        _userFoundCount = _nearestUsers.length;

        _addNearestUserMarkers(limit: _maxUsersToShow);

        setState(() {
          poolingUsers = _userFoundCount;
          _isLoadingNearbyUser = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    var model = Get.arguments;
    debugPrint("$model");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadMarker();

      if (model != null) {
        var brand = BrandOfferModel.fromJson(model['brands']);
        _titleController.text = brand.title;
        _descController.text = brand.description;
        _handleImage(brand);
      }
      await _fetchLocation();
    });
  }

  void loadMarker() async {
    _locationMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(
          size: Size.square(40),
        ),
        "assets/icons/location_marker.png");
    setState(() {
      _locationMarker;
    });
  }

  void reset() {
    _titleController.clear();
    _descController.clear();
    _imageFiles = [];
    _radius = 500;
    _waitTime = 30;
    _imageFiles?.clear();
  }

  void _addNearestUserMarkers({int limit = 100}) async {
    if (_nearestUsers.isEmpty) return;

    final usersToDisplay = _nearestUsers.length > limit
        ? _nearestUsers.sublist(0, limit)
        : _nearestUsers;

    // Prepare user data for processing
    final userData = usersToDisplay
        .map((user) => {
              'username': user.username,
              'latitude': user.location.latitude,
              'longitude': user.location.longitude,
            })
        .toList();

    // Process data in a separate isolate
    final processedData =
        await compute<List<Map<String, dynamic>>, List<Map<String, dynamic>>>(
            (data) {
      // This runs in a separate isolate to avoid blocking UI
      return data
          .map((user) => {
                'id': user['username'],
                'latitude': user['latitude'],
                'longitude': user['longitude'],
                'title': user['username'],
              })
          .toList();
    }, userData);

    // Create markers in the main isolate
    final markers = processedData
        .map((data) => Marker(
              markerId: MarkerId(data['id']),
              position: LatLng(data['latitude'], data['longitude']),
              icon: _locationMarker ??
                  BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
              infoWindow: InfoWindow(
                title: data['title'],
                snippet: 'Nearby User',
              ),
            ))
        .toList();

    _userMarkers.clear();
    _userMarkers.addAll(markers);
    setState(() {
      _updateMarkersAndCircles();
    });
  }

  Future<void> _fetchLocation() async {
    if (_locationController.state.value.location == null) {
      if (!await _locationController.isLocationEnabled()) {
        return;
      }
      await _locationController.getLocation();
    }

    final location = _locationController.state.value.location;

    if (location == null) {
      debugPrint("NULL LOCATION : VICINITY");
      Get.snackbar(
        'Oops',
        'Failed to get current location.',
        snackStyle: SnackStyle.GROUNDED,
      );
      return;
    }

    await _userController.updateUser([UserField.location],
        customExecution: (field) {
      return MapEntry("loc", {
        "lat": location.latitude,
        "lng": location.longitude,
      });
    });

    setState(() {
      _currentPosition = LatLng(location.latitude, location.longitude);

      _updateMarkersAndCircles();
      getNearestUsers(_radius);

      if (_controller != null && !_isMapInitialized) {
        _controller!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentPosition!,
              zoom: 16.0,
              tilt: _is3DView ? 0 : 45.0,
              bearing: _is3DView ? 0 : 45.0,
            ),
          ),
        );
        _isMapInitialized = true;
      }
    });
  }

  Future<void> _handleImage(BrandOfferModel brand) async {
    try {
      var manager = CachedNetworkImageProvider.defaultCacheManager;
      var file = await manager.downloadFile(brand.imageUrl);
      _imageFiles?.add(XFile(file.file.path));
      setState(() {
        _imageFiles;
        fromBrands = true;
      });
    } catch (e) {
      setState(() {
        fromBrands = true;
      });
    }
  }

  Future<void> _pickImages() async {
    // var isPhotoPermissionGranted =
    //     await PermissionUtil().isPhotoPermissionGranted();
    // if (!isPhotoPermissionGranted) {
    //   isPhotoPermissionGranted =
    //       await PermissionUtil().requestPhotoPermission();
    //   if (!isPhotoPermissionGranted) {
    //     return;
    //   }
    // }
    final pickedFiles = await _picker.pickMultiImage(
      imageQuality: 10,
    );
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _imageFiles = pickedFiles.take(3).toList();
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
    } else {
      debugPrint("SOMETHING IS WRONG IN 3D VIEW");
    }
  }

  void _updateMarkersAndCircles() {
    if (_currentPosition != null) {
      // Add or update the current location marker
      _userMarker = Marker(
        markerId: const MarkerId("currentLocation"),
        position: _currentPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(
          title: "Your Location",
        ),
      );

      // Add or update the current location circle
      _currentLocationCircle = Circle(
        circleId: const CircleId("currentLocationCircle"),
        center: _currentPosition!,
        radius: _radius,
        strokeColor: Colors.blue,
        strokeWidth: 2,
        fillColor: Colors.blue.withOpacity(0.3),
      );
    }
  }
}
