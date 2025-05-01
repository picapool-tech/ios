import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picapool/common/widgets/blurry_container.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/common/widgets/text_field_widgets.dart';
import 'package:picapool/features/location/location_controller.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/models/user_location_model.dart';
import 'package:picapool/utils/theme.dart';

class LocationScreen extends StatefulWidget {
  final void Function(String) onLocationSelected;
  const LocationScreen({
    super.key,
    required this.onLocationSelected,
  });

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final StorageController _storageController = Get.find<StorageController>();
  final LocationController _locationController = LocationController();
  final TextEditingController buildingController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String selectedType = "Home";

  LatLng? selectedLocation;
  List<UserLocationModel> savedLocations = [];

  bool get isValid => (addressController.text.isEmpty ||
      buildingController.text.isEmpty ||
      selectedLocation == null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Address"),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedLocation != null)
                  Expanded(
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: selectedLocation!,
                        zoom: 16,
                      ),
                      onTap: (LatLng location) {
                        setState(() {
                          selectedLocation = location;
                        });
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId("selectedLocation"),
                          position: selectedLocation!,
                        ),
                      },
                    ),
                  )
                else
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PicaOutlinedTextField(
                        labelText: "Building / House / Flat / Floor No*",
                        controller: buildingController,
                      ),
                      const SizedBox(height: 16),
                      PicaOutlinedTextField(
                        controller: addressController,
                        labelText: "Address*",
                        hintText: "Street, Area, City",
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text("Home"),
                            selected: selectedType == "Home",
                            onSelected: (bool selected) {
                              setState(() {
                                selectedType = "Home";
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text("Office"),
                            selected: selectedType == "Office",
                            onSelected: (bool selected) {
                              setState(() {
                                selectedType = "Office";
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text("Other"),
                            selected: selectedType == "Other",
                            onSelected: (bool selected) {
                              setState(() {
                                selectedType = "Other";
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Saved Locations",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: List.generate(
                            savedLocations.length,
                            (index) => GestureDetector(
                              onTap: () {
                                // Get.back();
                                // widget.onLocationSelected(
                                //   savedLocations[index].fullAddress,
                                // );
                                setState(() {
                                  selectedLocation =
                                      savedLocations[index].latLng;

                                  addressController.text =
                                      savedLocations[index].fullAddress;
                                  buildingController.text =
                                      savedLocations[index].buildingName;
                                  selectedType = savedLocations[index].type;
                                });
                              },
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 200,
                                ),
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.all(8),
                                decoration: roundedContainer().copyWith(
                                  color: Colors.white,
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      savedLocations[index].buildingName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      savedLocations[index].fullAddress,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: PicaPrimaryButton(
                          onPressed: saveLocation,
                          isLoading: false.obs,
                          text: "Save and continue",
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Align(
              alignment: Alignment.topCenter,
              child: BlurryContainer(
                alignment: Alignment.center,
                padding: EdgeInsets.all(8),
                child: Text(
                  "Click on map to set the location",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void getSavedLocations() async {
    var locations = await _storageController.loadUserLocations();
    setState(() {
      savedLocations = locations;
    });
    log("Location found: ${locations.length}");
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var location = _locationController.state.value.location;
      var locationName = _locationController.state.value.locationName;
      if (location == null) {
        await _locationController.getLocation();
        location = _locationController.state.value.location;
        locationName = _locationController.state.value.locationName;
      }

      if (location != null && locationName != null) {
        setState(() {
          selectedLocation = LatLng(location!.latitude, location.longitude);
          addressController.text =
              "${locationName!.name}, ${locationName.locality}, ${locationName.administrativeArea}";
        });
      }

      getSavedLocations();
    });
  }

  void saveLocation() async {
    if (addressController.text.isEmpty ||
        buildingController.text.isEmpty ||
        selectedLocation == null) {
      Get.snackbar("Oops!", "Please fill all fields");
      return;
    }
    UserLocationModel locationModel = UserLocationModel(
      address: addressController.text,
      buildingName: buildingController.text,
      type: selectedType,
      userId: '${_storageController.user.value!.id}',
      latLng: selectedLocation,
    );

    List<UserLocationModel> savedLocations =
        await _storageController.loadUserLocations();
    savedLocations.add(locationModel);
    await _storageController.saveUserLocations(savedLocations);
    Get.back();
    widget.onLocationSelected(locationModel.fullAddress);
  }
}
