import 'package:flutter/material.dart';
import 'package:picapool/utils/center_custom_text.dart';
import 'package:picapool/utils/large_button.dart';
import 'package:picapool/widgets/cab/auto_text_field.dart';
import 'package:picapool/widgets/cab/radius_time_widget.dart';

class LocationEntryWidget extends StatefulWidget {
  const LocationEntryWidget({Key? key}) : super(key: key);

  @override
  State<LocationEntryWidget> createState() => _LocationEntryWidgetState();
}

class _LocationEntryWidgetState extends State<LocationEntryWidget> {
  bool canPop = true;

  double bottomSheetHeightFactor = 0.5;
  bool isNextButtonClicked = false;

  TextEditingController pickup = TextEditingController();
  TextEditingController drop = TextEditingController();

  // Future<String> getPicUp() async {
  //   if (pickup.text.trim().isEmpty) {
  //     String locationString = await getLocationName(
  //         widget.locationModel.latitude, widget.locationModel.longitude);
  //     debugPrint("DEFAULT LOCATION : $locationString");
  //     setState(() {
  //       sourceLabel = locationString;
  //     });
  //     return locationString;
  //   } else {
  //     return sourceController.text.trim();
  //   }
  // }

  // Future<String> getLocationName(double latitude, double longitude) async {
  //   try {
  //     List<Placemark> placemarks =
  //         await placemarkFromCoordinates(latitude, longitude);
  //     if (placemarks.isNotEmpty) {
  //       Placemark firstPlacemark = placemarks[0];
  //       String locationName =
  //           '${firstPlacemark.name}, ${firstPlacemark.locality}, ${firstPlacemark.thoroughfare}, ${firstPlacemark.administrativeArea}';
  //       return locationName;
  //     }
  //   } catch (e) {
  //     debugPrint('Error getting location name: $e');
  //   }
  //   return 'Unknown Location';
  // }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (isNextButtonClicked) {
          setState(() {
            bottomSheetHeightFactor = 0.5;
            isNextButtonClicked = false;
            canPop = true;
          });
        } else {
          setState(() {
            canPop = true;
          });
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: MediaQuery.of(context).size.height * bottomSheetHeightFactor,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(34),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const CenterAlignText(
                    text: "Create your Share!",
                    size: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff333333),
                  ),
                  CenterAlignText(
                    text: isNextButtonClicked
                        ? "Enter Radius & Wait Time"
                        : "Enter your Pick Up & Drop Location",
                    size: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff333333),
                  ),
                  const SizedBox(height: 24),
                  isNextButtonClicked
                      ? radiusTimeFields()
                      : dropPickUpLoacationFields(),
                  const SizedBox(height: 24),
                  isNextButtonClicked
                      ? LargeButton(text: "Start Pooling", onPressed: () {})
                      : LargeButton(
                          text: "Next",
                          onPressed: () {
                            setState(() {
                              isNextButtonClicked = true;
                              bottomSheetHeightFactor = 0.3;
                              canPop = false;
                            });
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget dropPickUpLoacationFields() {
    return Column(
      children: [
        AutoTextFieldWidget(controller: pickup, hint: "Pick Up Location"),
        const SizedBox(height: 24),
        AutoTextFieldWidget(controller: drop, hint: "Drop Location"),
      ],
    );
  }

  Widget radiusTimeFields() {
    return const Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RadiusTimeFieldWidget(
              currentIndex: 0, values: ["100 m", "200 m", "300 m", "1000 m"]),
          RadiusTimeFieldWidget(
              currentIndex: 0,
              values: ["15 min", "20 min", "30 min", "60 min"]),
        ],
      ),
    );
  }
}
