import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picapool/features/location/location_controller.dart';
import 'package:picapool/screens/location_fetch_screen.dart';
import 'package:picapool/widgets/loading/location_loading.dart';

class LocationWidget extends StatefulWidget {
  final Color? color;
  const LocationWidget({
    super.key,
    this.color = Colors.white,
  });

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  final LocationController locationController = Get.find<LocationController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final locationState = locationController.state.value;

      if (locationState.isLoading) {
        return const LocationLoading();
      }

      final hasLocationData = locationState.locationName != null;

      // Extract all location components
      final locality = locationState.locationName?.locality ?? "";
      final subLocality = locationState.locationName?.subLocality ?? "";
      final thoroughfare = locationState.locationName?.thoroughfare ?? "";
      final administrativeArea =
          locationState.locationName?.administrativeArea ?? "";
      final country = locationState.locationName?.country ?? "";
      final name = locationState.locationName?.name ?? "";

      // Get main location text (primary location identifier)
      final mainText = _isPlusCode(name)
          ? _getMainLocationText(
              locality: locality,
              subLocality: subLocality,
              administrativeArea: administrativeArea,
              country: country,
            )
          : name;

      // Get secondary location text (additional location details)
      final secondaryText = hasLocationData
          ? _getSecondaryLocationText(
              locality: locality,
              thoroughfare: thoroughfare,
              subLocality: subLocality,
              administrativeArea: administrativeArea,
              country: country,
              mainText: mainText,
            )
          : "Location unknown";

      return Row(
        children: [
          InkWell(
            onTap: () {
              debugPrint("Location tapped");
              Get.to(() => const LocationScreen());
            },
            child: Container(
              alignment: Alignment.topLeft,
              width: MediaQuery.of(context).size.width * 0.75,
              child: Row(
                children: [
                  Icon(Icons.location_on, color: widget.color),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                mainText.isEmpty
                                    ? "Current Location"
                                    : mainText,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  color: widget.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              color: widget.color,
                            ),
                          ],
                        ),
                        Text(
                          secondaryText,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: widget.color,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocation();
    });
  }

  void _fetchLocation() async {
    if (locationController.state.value.location == null) {
      await locationController.getLocation();
    }
  }

  /// Get main location text (primary location identifier)
  String _getMainLocationText({
    required String locality,
    required String subLocality,
    required String administrativeArea,
    required String country,
  }) {
    // First priority: City/Town name
    if (locality.isNotEmpty) {
      return locality;
    }

    // Second priority: District/Neighborhood
    if (subLocality.isNotEmpty) {
      return subLocality;
    }

    // Third priority: State/Province
    if (administrativeArea.isNotEmpty) {
      return administrativeArea;
    }

    // Fourth priority: Country
    if (country.isNotEmpty) {
      return country;
    }

    // Final fallback if nothing else is available
    return "Current Location";
  }

  String _getSecondaryLocationText({
    required String locality,
    required String thoroughfare,
    required String subLocality,
    required String administrativeArea,
    required String country,
    required String mainText,
  }) {
    // Build list of components for secondary text, avoiding duplication with main text
    final components = <String>[];

    if (thoroughfare.isNotEmpty && thoroughfare != mainText) {
      components.add(thoroughfare);
    }

    if (locality.isNotEmpty && locality != mainText) {
      components.add(locality);
    } else if (subLocality.isNotEmpty && subLocality != mainText) {
      components.add(subLocality);
    }

    if (administrativeArea.isNotEmpty &&
        administrativeArea != mainText &&
        !components.contains(administrativeArea)) {
      components.add(administrativeArea);
    }

    if (country.isNotEmpty &&
        country != mainText &&
        !components.contains(country) &&
        components.isEmpty) {
      components.add(country);
    }

    // If we have components, join the first two with comma
    if (components.isNotEmpty) {
      return components.length > 1
          ? "${components[0]}, ${components[1]}"
          : components[0];
    }

    // Fallback if no complementary details are available
    return "Near you";
  }

  /// Check if a location name is in plus code format
  bool _isPlusCode(String name) {
    // Match typical plus code patterns like "6MXX+CRC" or "ABC123+XYZ"
    final plusCodePattern = RegExp(r'^[A-Z0-9]+\+[A-Z0-9]+$');
    return plusCodePattern.hasMatch(name) || name == "Nu";
  }
}
