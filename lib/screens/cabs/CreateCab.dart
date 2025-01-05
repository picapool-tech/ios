import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';

class CreateCabPoolScreen extends StatefulWidget {
  const CreateCabPoolScreen({super.key});

  @override
  _CreateCabPoolScreenState createState() => _CreateCabPoolScreenState();
}

class _CreateCabPoolScreenState extends State<CreateCabPoolScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  var hour = 5;
  var minute = 45;
  var timeFormat = "AM";

  final List<String> amPmOptions = ["AM", "PM"];
  static const LatLng _initialPosition = LatLng(25.276987, 55.296249);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F0F0),
      appBar: AppBar(
        title: const Text('Create your pool',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'MontserratSB',
            )),
        backgroundColor: const Color(0xffF0F0F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Google Map Section
          Positioned.fill(
            top: 70,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _initialPosition,
                zoom: 14.0,
              ),
              onMapCreated: (GoogleMapController controller) {},
              markers: {
                Marker(
                  markerId: const MarkerId('pool_marker'),
                  position: _initialPosition,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueOrange),
                ),
              },
            ),
          ),

          // Search Bar at the top
          Positioned(
            top: 10,
            left: 20,
            right: 20,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xffFF8D41)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: '6th st, Connaught place, New Delhi...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'MontserratR',
                        ),
                      ),
                    ),
                  ),
                  const Icon(Icons.favorite_border, color: Color(0xffFF8D41)),
                ],
              ),
            ),
          ),

          // Bottom Container with Date and Time Pickers
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(
                            0xfff5f5f5), // Light grey color as background
                        borderRadius:
                            BorderRadius.circular(25), // Rounded corners
                      ),
                      child: const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(Icons.location_on,
                                color:
                                    Color(0xffFF8D41)), // Orange location icon
                          ),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search Destination',
                                hintStyle: TextStyle(
                                  fontFamily: "MontserratM",
                                  color: Colors.grey, // Grey hint text color
                                  fontSize: 16,
                                ),
                                border: InputBorder.none, // No border
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xffFF8D41))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Select Your Cab Timing',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "MontserratM",
                                  fontWeight: FontWeight.w500)),
                        ),
                        Expanded(
                          child: Divider(
                            color: Color(0xffFF8D41),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Date Picker
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xffFF8D41)),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                _formatDate(selectedDate),
                                style: const TextStyle(
                                  fontFamily: "MontserratM",
                                  fontSize: 14,
                                  color: Color(0xffFF8D41),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 10,
                              top: -5,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Color(0xffFF8D41),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Time Picker
                      Row(
                        children: [
                          _buildNumberPicker(hour, 1, 12, (value) {
                            setState(() {
                              hour = value;
                            });
                          }),
                          const SizedBox(width: 10),
                          const Text(
                            ":",
                            style: TextStyle(
                              fontFamily: "MontserratM",
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildNumberPicker(minute, 0, 59, (value) {
                            setState(() {
                              minute = value;
                            });
                          }),
                          const SizedBox(width: 10),
                          _buildAmPmPicker(),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle Confirm action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffFF8D41),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'MontserratSB',
                            color: Colors.white,
                          ),
                        ),
                      ),
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

  Widget _buildNumberPicker(
      int value, int min, int max, ValueChanged<int> onChanged) {
    return NumberPicker(
      minValue: min,
      maxValue: max,
      value: value,
      zeroPad: true,
      infiniteLoop: true,
      itemWidth: 50,
      itemHeight: 60,
      onChanged: onChanged,
      textStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      selectedTextStyle: const TextStyle(color: Colors.black, fontSize: 14),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey),
          bottom: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildAmPmPicker() {
    return Container(
      height: 60,
      width: 65,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey),
          bottom: BorderSide(color: Colors.grey),
        ),
      ),
      child: ListWheelScrollView.useDelegate(
        physics: const FixedExtentScrollPhysics(),
        itemExtent: 60,
        diameterRatio: 1.5,
        onSelectedItemChanged: (index) {
          setState(() {
            timeFormat = amPmOptions[index];
          });
        },
        childDelegate: ListWheelChildLoopingListDelegate(
          children: amPmOptions.map((option) {
            final isSelected = option == timeFormat;
            return Center(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.black : Colors.grey,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${_getDayOfWeek(date.weekday)} ${date.day} ${_getMonthName(date.month)}";
  }

  String _getDayOfWeek(int day) {
    switch (day) {
      case DateTime.monday:
        return "Mon";
      case DateTime.tuesday:
        return "Tue";
      case DateTime.wednesday:
        return "Wed";
      case DateTime.thursday:
        return "Thu";
      case DateTime.friday:
        return "Fri";
      case DateTime.saturday:
        return "Sat";
      case DateTime.sunday:
        return "Sun";
      default:
        return "";
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case DateTime.january:
        return "Jan";
      case DateTime.february:
        return "Feb";
      case DateTime.march:
        return "Mar";
      case DateTime.april:
        return "Apr";
      case DateTime.may:
        return "May";
      case DateTime.june:
        return "Jun";
      case DateTime.july:
        return "Jul";
      case DateTime.august:
        return "Aug";
      case DateTime.september:
        return "Sep";
      case DateTime.october:
        return "Oct";
      case DateTime.november:
        return "Nov";
      case DateTime.december:
        return "Dec";
      default:
        return "";
    }
  }
}
