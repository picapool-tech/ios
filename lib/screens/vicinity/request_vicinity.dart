import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:http/http.dart' as http;
import 'package:picapool/functions/location/location_provider.dart';
import 'package:picapool/functions/user/user_controller.dart';
import 'package:picapool/functions/vicinity/vicinity_controller.dart';
import 'package:picapool/models/response_model.dart';
import 'package:picapool/models/vicinity_offer_model.dart';
import 'package:picapool/screens/Products/products_detailed_page.dart';
import 'package:picapool/screens/Public%20Chat/chatPage.dart';
import 'package:picapool/utils/image_utils.dart';

class NearUserModel {
  final int id;
  final String name;
  final String? gender;
  final int age;
  final String? username;
  final String? pic;
  final String? bio;
  final Location location;

  NearUserModel({
    required this.id,
    required this.name,
    required this.age,
    this.gender,
    this.username,
    this.pic,
    this.bio,
    required this.location,
  });

  factory NearUserModel.fromJson(Map<String, dynamic> json) {
    return NearUserModel(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      username: json['username'],
      pic: json['pic'],
      bio: json['bio'],
      location: Location(
        latitude: json['lat'],
        longitude: json['lng'],
        timestamp: DateTime.timestamp(),
      ),
    );
  }
}

class RequestVicinity extends StatefulWidget {
  const RequestVicinity({super.key});

  @override
  State<RequestVicinity> createState() => _RequestVicinityState();
}

class _RequestVicinityState extends State<RequestVicinity> {
  final LocationController _locationController = Get.find<LocationController>();
  final AuthController _authController = Get.find<AuthController>();
  final VicinityController _vicinityController = Get.find<VicinityController>();
  final UserController _userController = Get.find<UserController>();

  double _radius = 500;
  double _waitTime = 30;
  bool _isCollapsed = false;
  List<XFile>? _imageFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool _is3DView = false;
  GoogleMapController? _controller;
  LatLng? _currentPosition;
  Marker? _pinMarker;
  Circle? _currentLocationCircle;
  bool _isMapInitialized = false; // New flag to check if the map is initialized
  List<NearUserModel> _nearestUsers = [];
  bool fromBrands = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  int poolingUsers = 0;

  Marker? _userMarker;
  final Set<Marker> _userMarkers = {};

  @override
  void initState() {
    super.initState();
    var model = Get.arguments;
    debugPrint("$model");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _fetchLocation();
      if (model != null) {
        var brand = BrandOfferModel.fromJson(model['brands']);
        _titleController.text = brand.title;
        _descController.text = brand.description;
        var imageUrl = await ImageUtils.imageToFile(
          assetName: brand.imageUrl,
        );
        _imageFiles?.add(XFile(imageUrl.path));
        setState(() {
          _imageFiles;
          fromBrands = true;
        });
      }
    });
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

    setState(() {
      _currentPosition = LatLng(location.latitude, location.longitude);

      _updateMarkersAndCircles();
      getNearestUsers(_userController.user.value?.id, _radius);

      if (_controller != null && !_isMapInitialized) {
        _controller!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentPosition!,
              zoom: 14.0,
            ),
          ),
        );
        _isMapInitialized = true;
      }
    });
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

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage(
      imageQuality: 10,
    );
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _imageFiles = pickedFiles.take(3).toList();
      });
    }
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
      userId: _userController.user.value!.id,
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
      uname: _userController.user.value!.name!,
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

  void reset() {
    _titleController.clear();
    _descController.clear();
    _imageFiles = [];
    _radius = 500;
    _waitTime = 30;
    _imageFiles?.clear();
  }

  ExpansionPanel expansionPanel() {
    return ExpansionPanel(
      backgroundColor: Colors.white,
      canTapOnHeader: true,
      headerBuilder: (context, isExpanded) {
        return const Row(
          children: [
            Expanded(
              child: Divider(
                indent: 25,
                thickness: 1,
                color: Color(0xffFF8D41),
              ),
            ),
            Text(
              "  Request Vicinity  ",
              style: TextStyle(fontSize: 16, fontFamily: "MontserratM"),
            ),
            Expanded(
              child: Divider(
                endIndent: 25,
                thickness: 1,
                color: Color(0xffFF8D41),
              ),
            ),
          ],
        );
      },
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: "Add Title",
                          labelStyle: const TextStyle(
                              fontFamily: "MontserratM", color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xffFF8D41),
                            ),
                          ),
                        ),
                        showCursor: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _descController,
                        decoration: InputDecoration(
                          labelText: "Add Description",
                          labelStyle: const TextStyle(
                              fontFamily: "MontserratM", color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xffFF8D41),
                            ),
                          ),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _imageFiles == null || _imageFiles!.isEmpty
                        ? const Center(
                            child: Icon(
                              Icons.add_photo_alternate,
                              size: 40,
                              color: Colors.grey,
                            ),
                          )
                        : PageView.builder(
                            itemCount: _imageFiles!.length,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_imageFiles![index].path),
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isExpanded: !_isCollapsed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _isCollapsed = !isExpanded;
                });
              },
              expandedHeaderPadding: const EdgeInsets.all(0),
              expandIconColor: Theme.of(context).primaryColor,
              children: [
                expansionPanel(),
              ],
            ),
            // App bar and top section
            // AnimatedContainer(
            //   duration: const Duration(milliseconds: 300),
            //   height: _isCollapsed ? 60 : 230,
            //   decoration: const BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.only(
            //       bottomLeft: Radius.circular(20),
            //       bottomRight: Radius.circular(20),
            //     ),
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.black26,
            //         blurRadius: 10,
            //         offset: Offset(0, 5),
            //       ),
            //     ],
            //   ),
            //   child: Stack(
            //     children: [
            //       // Column(
            //       //   children: [
            //       //     const Padding(
            //       //       padding: EdgeInsets.all(16.0),
            //       //       child: Row(
            //       //         children: [
            //       //           Expanded(
            //       //             child: Divider(
            //       //               indent: 25,
            //       //               thickness: 1,
            //       //               color: Color(0xffFF8D41),
            //       //             ),
            //       //           ),
            //       //           Text(
            //       //             "  Request Vicinity  ",
            //       //             style: TextStyle(
            //       //                 fontSize: 16, fontFamily: "MontserratM"),
            //       //           ),
            //       //           Expanded(
            //       //             child: Divider(
            //       //               endIndent: 25,
            //       //               thickness: 1,
            //       //               color: Color(0xffFF8D41),
            //       //             ),
            //       //           ),
            //       //         ],
            //       //       ),
            //       //     ),
            //       //     if (!_isCollapsed)
            //       //       Padding(
            //       //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //       //         child: Column(
            //       //           children: [
            //       //             Row(
            //       //               crossAxisAlignment: CrossAxisAlignment.start,
            //       //               children: [
            //       //                 Expanded(
            //       //                   child: Column(
            //       //                     children: [
            //       //                       TextField(
            //       //                         controller: _titleController,
            //       //                         decoration: InputDecoration(
            //       //                           labelText: "Add Title",
            //       //                           labelStyle: const TextStyle(
            //       //                               fontFamily: "MontserratM",
            //       //                               color: Colors.grey),
            //       //                           enabledBorder: OutlineInputBorder(
            //       //                             borderRadius:
            //       //                                 BorderRadius.circular(8),
            //       //                             borderSide: const BorderSide(
            //       //                               color: Colors.grey,
            //       //                             ),
            //       //                           ),
            //       //                           focusedBorder: OutlineInputBorder(
            //       //                             borderRadius:
            //       //                                 BorderRadius.circular(8),
            //       //                             borderSide: const BorderSide(
            //       //                               color: Color(0xffFF8D41),
            //       //                             ),
            //       //                           ),
            //       //                         ),
            //       //                       ),
            //       //                       const SizedBox(height: 16),
            //       //                       TextField(
            //       //                         controller: _descController,
            //       //                         decoration: InputDecoration(
            //       //                           labelText: "Add Description",
            //       //                           labelStyle: const TextStyle(
            //       //                               fontFamily: "MontserratM",
            //       //                               color: Colors.grey),
            //       //                           enabledBorder: OutlineInputBorder(
            //       //                             borderRadius:
            //       //                                 BorderRadius.circular(8),
            //       //                             borderSide: const BorderSide(
            //       //                               color: Colors.grey,
            //       //                             ),
            //       //                           ),
            //       //                           focusedBorder: OutlineInputBorder(
            //       //                             borderRadius:
            //       //                                 BorderRadius.circular(8),
            //       //                             borderSide: const BorderSide(
            //       //                               color: Color(0xffFF8D41),
            //       //                             ),
            //       //                           ),
            //       //                         ),
            //       //                         maxLines: 2,
            //       //                       ),
            //       //                     ],
            //       //                   ),
            //       //                 ),
            //       //                 const SizedBox(width: 16),
            //       //                 GestureDetector(
            //       //                   onTap: _pickImages,
            //       //                   child: Container(
            //       //                     width: 104,
            //       //                     height: 104,
            //       //                     decoration: BoxDecoration(
            //       //                       color: Colors.grey[200],
            //       //                       border: Border.all(
            //       //                           color: Colors.grey, width: 1),
            //       //                       borderRadius: BorderRadius.circular(8),
            //       //                     ),
            //       //                     child: _imageFiles == null ||
            //       //                             _imageFiles!.isEmpty
            //       //                         ? const Center(
            //       //                             child: Icon(
            //       //                               Icons.add_photo_alternate,
            //       //                               size: 40,
            //       //                               color: Colors.grey,
            //       //                             ),
            //       //                           )
            //       //                         : PageView.builder(
            //       //                             itemCount: _imageFiles!.length,
            //       //                             itemBuilder: (context, index) {
            //       //                               return ClipRRect(
            //       //                                 borderRadius:
            //       //                                     BorderRadius.circular(8),
            //       //                                 child: Image.file(
            //       //                                   File(_imageFiles![index]
            //       //                                       .path),
            //       //                                   fit: BoxFit.cover,
            //       //                                 ),
            //       //                               );
            //       //                             },
            //       //                           ),
            //       //                   ),
            //       //                 ),
            //       //               ],
            //       //             ),
            //       //             const SizedBox(height: 16),
            //       //           ],
            //       //         ),
            //       //       ),
            //       //   ],
            //       // ),
            //       Positioned(
            //         bottom: 8,
            //         right: 30,
            //         child: GestureDetector(
            //           onTap: () {
            //             setState(() {
            //               _isCollapsed = !_isCollapsed;
            //             });
            //           },
            //           child: Container(
            //             width: 40,
            //             height: 40,
            //             decoration: BoxDecoration(
            //               color: const Color(0xffFFEEE2),
            //               shape: BoxShape.circle,
            //               border: Border.all(
            //                 color: const Color(0xffFF8D41),
            //                 width: 2,
            //               ),
            //               boxShadow: [
            //                 BoxShadow(
            //                   color: Colors.black.withOpacity(0.2),
            //                   blurRadius: 8,
            //                 ),
            //               ],
            //             ),
            //             child: Icon(
            //               _isCollapsed
            //                   ? Icons.arrow_drop_down_outlined
            //                   : Icons.arrow_drop_up_outlined,
            //               color: const Color(0xffFF8D41),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // // Map section
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
                                style: TextStyle(
                                    fontFamily: "MontserratM", fontSize: 10),
                              ),
                              Text(
                                "$poolingUsers",
                                style: const TextStyle(
                                    fontFamily: "MontserratSB",
                                    fontSize: 16,
                                    color: Color(0xffFF8D41)),
                              ),
                              Text(
                                (poolingUsers > 1) ? "users" : "user",
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
                        "  Radius and wait time  ",
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
                      Row(
                        children: [
                          const Text("Radius (m)",
                              style: TextStyle(
                                  fontSize: 14, fontFamily: "MontserratM")),
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
                                _userController.user.value?.id,
                                value.toDouble(),
                              );
                            },
                            itemWidth: 50, // Smaller width
                            textStyle: const TextStyle(
                                fontFamily: "MontserratM",
                                fontSize: 12,
                                color: Colors.grey),
                            selectedTextStyle: const TextStyle(
                                fontFamily: "MontserratM",
                                fontSize: 16,
                                color: Colors.black),
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
                          const Text("Wait Time (min)",
                              style: TextStyle(
                                  fontSize: 14, fontFamily: "MontserratM")),
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
                                fontFamily: "MontserratM",
                                fontSize: 12,
                                color: Colors.grey),
                            selectedTextStyle: const TextStyle(
                                fontFamily: "MontserratM",
                                fontSize: 16,
                                color: Colors.black),
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
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: (_userController.user.value?.id != null)
                    ? () {
                        createVicinity();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xffFF8D41),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Obx(
                  () {
                    if (_vicinityController.isLoading.value) {
                      return const CircularProgressIndicator();
                    }

                    return Text(
                      (_userController.user.value?.id != null)
                          ? "Start Pooling"
                          : "Sign in required",
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: "MontserratSB",
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addNearestUserMarkers() {
    _userMarkers.clear();
    for (var user in _nearestUsers) {
      final Marker userMarker = Marker(
        markerId: MarkerId(user.id.toString()),
        position: LatLng(user.location.latitude, user.location.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          (user.id == _userController.user.value?.id)
              ? BitmapDescriptor.hueRed
              : BitmapDescriptor.hueGreen,
        ),
        infoWindow: InfoWindow(
          title: user.username,
          snippet: 'Nearby User',
        ),
      );

      setState(() {
        _userMarkers.add(userMarker);
        _updateMarkersAndCircles();
      });

      debugPrint("TOTAL MARKERS IN LOCATION : ${_userMarkers.length}");
    }
  }

  void _showUserDetailsDialog(NearUserModel user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(user.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user.pic != null && user.pic!.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: user.pic!,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
              else
                const Icon(
                  Icons.account_circle,
                  size: 100,
                ),
              const SizedBox(height: 10),
              Text(
                  'Location: (${user.location.latitude}, ${user.location.longitude})'),
              // Add more user details as needed
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // You can add more actions like "Message" or "View Profile"
          ],
        );
      },
    );
  }

  Future<void> getNearestUsers(int? id, double radius) async {
    String endpoint = "https://api.picapool.com/v2/user/nearest";
    String? at = await _authController.getAccessToken();

    if (at == null || id == null) {
      return;
    }

    debugPrint(
        'Fetching nearest users with coordinates : ${_currentPosition?.latitude}, ${_currentPosition?.longitude} with id: $id');
    try {
      final response = await http.post(Uri.parse(endpoint),
          body: jsonEncode({
            'dist': radius,
            'id': id,
          }),
          headers: {
            'content-type': 'application/json',
            'Authorization': 'Bearer $at'
          });

      debugPrint("NEAREST USERS: ${response.body}");
      if (response.statusCode < 300) {
        var responseModel = ResponseModel.fromJson(jsonDecode(response.body));

        if (!responseModel.success) {
          Get.snackbar(
            "No nearest user",
            "Not able to find any user near to your vicinity.",
          );
          return;
        }

        var users = responseModel.data as List<dynamic>? ?? [];
        List<NearUserModel> usersLocation = [];

        for (var user in users) {
          debugPrint("$user");
          var nearUser = NearUserModel.fromJson(user);
          usersLocation.add(nearUser);
        }

        _nearestUsers = usersLocation;

        setState(() {
          poolingUsers = users.length;
        });

        _addNearestUserMarkers();
      } else if (response.statusCode == 401) {
        debugPrint('Failed to load getNearestUsers - status code 401');
      } else {
        debugPrint('Failed to load getNearestUsers - status code not 200');
        return;
      }
    } catch (err) {
      debugPrint('Failed to fetch getNearestUsers - $err');
      return;
    }
  }
}
