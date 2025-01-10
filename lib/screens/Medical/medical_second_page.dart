import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MedicalPage2 extends StatefulWidget {
  const MedicalPage2({super.key});

  @override
  State<MedicalPage2> createState() => _MedicalPage2State();
}

class _MedicalPage2State extends State<MedicalPage2> {
  double _radius = 100;
  final LatLng _center = const LatLng(30.3165, 78.0322); // Example location for Dehradun
  bool _isListButtonActive = false;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  String? selectedDoctor;
  LatLng? selectedLocation;

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  void _addMarkers() {
    const MarkerId markerId1 = MarkerId("doctor1");
const MarkerId markerId2 = MarkerId("doctor2");
const MarkerId markerId3 = MarkerId("doctor3");

final Marker marker1 = Marker(
  markerId: markerId1,
  position: const LatLng(30.3165, 78.0300), // Adjusted latitude and longitude
  onTap: () {
    _onMarkerTapped("Dr. Judith Joseph", const LatLng(30.3165, 78.0300));
  },
);

final Marker marker2 = Marker(
  markerId: markerId2,
  position: const LatLng(30.3200, 78.0350), // Adjusted latitude and longitude
  onTap: () {
    _onMarkerTapped("Dr. Robert Smith", const LatLng(30.3200, 78.0350));
  },
);

final Marker marker3 = Marker(
  markerId: markerId3,
  position: const LatLng(30.3250, 78.0400), // Adjusted latitude and longitude
  onTap: () {
    _onMarkerTapped("Dr. Emily Clark", const LatLng(30.3250, 78.0400));
  },
);


    setState(() {
      markers[markerId1] = marker1;
      markers[markerId2] = marker2;
      markers[markerId3] = marker3;
    });
  }

  void _onMarkerTapped(String doctorName, LatLng location) {
    setState(() {
      selectedDoctor = doctorName;
      selectedLocation = location;
    });
  }

  void _onListButtonPressed() {
    setState(() {
      _isListButtonActive = !_isListButtonActive;
    });
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nearby Hospitals',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "MontserratM",
                          ),
                        ),
                        Text(
                          '17 medically help nearby',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: "MontserratM",
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: 5, // Example number of hospitals
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ListTile(
                              onTap: () {}, // Implement navigation to detailed hospital info
                              leading: const CircleAvatar(
                                backgroundColor: Colors.teal,
                                child: Icon(Icons.local_hospital, color: Colors.white),
                              ),
                              title: const Text(
                                'Sen Hospital',
                                style: TextStyle(fontFamily: "MontserratM", fontSize: 16),
                              ),
                              subtitle: const Text(
                                'Oncologist, Psychiatrist',
                                style: TextStyle(color: Colors.orange, fontFamily: "MontserratM", fontSize: 12),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.phone, color: Colors.orange),
                                onPressed: () {
                                  // Implement call functionality
                                },
                              ),
                            ),
                            Divider(
                              color: Colors.grey.withOpacity(0.6),
                              thickness: 1,
                              indent: 16,
                              endIndent: 16,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: SafeArea(
        child: Stack(
          children: [
            // Google Map Section
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 14.0,
                ),
                circles: {
                  Circle(
                    circleId: const CircleId("radius"),
                    center: _center,
                    radius: _radius,
                    fillColor: Colors.blue.withOpacity(0.1),
                    strokeColor: Colors.blue,
                    strokeWidth: 2,
                  ),
                },
                markers: Set<Marker>.of(markers.values),
              ),
            ),
            // Floating Back Button
            Positioned(
                top: 80,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xffa3a3a3)),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.orange),
                  ),
                )),
            // Floating Dropdown
            Positioned(
              top: 80,
              right: 100,
              child: Container(
                height: 40,
                width: 92,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xffa3a3a3)),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: DropdownButton<double>(
                  value: _radius,
                  underline: Container(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                  items: [100.0, 200.0, 500.0, 1000.0]
                      .map<DropdownMenuItem<double>>((double value) {
                    return DropdownMenuItem<double>(
                      value: value,
                      child: Text(
                        '${value.toInt()}m',
                        style:
                            const TextStyle(fontFamily: "MontserratR", fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (double? newValue) {
                    setState(() {
                      _radius = newValue!;
                    });
                  },
                ),
              ),
            ),
            // Floating List Button
            Positioned(
              top: 80,
              right: 16,
              child: GestureDetector(
                onTap: _onListButtonPressed,
                child: Container(
                  height: 40,
                  width: 70,
                  decoration: BoxDecoration(
                    color: _isListButtonActive ? Colors.orange : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xffa3a3a3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: _isListButtonActive ? Colors.white : Colors.black,
                        size: 18,
                      ),
                      Text("List",
                          style: TextStyle(
                              fontFamily: "MontserratR",
                              fontSize: 14,
                              color: _isListButtonActive
                                  ? Colors.white
                                  : Colors.black)),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 130,
              right: 16,
              child: GestureDetector(
                // onTap: _onListButtonPressed,
                child: Container(
                  height: 40,
                  width: 100,
                  decoration: BoxDecoration(
                    color: _isListButtonActive ? const Color(0xffFF8D41) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xffFF8D41)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_alert_sharp,
                        color: _isListButtonActive ? Colors.white : const Color(0xffFF8D41),
                        size: 18,
                      ),
                      Text("Urgent",
                          style: TextStyle(
                              fontFamily: "MontserratR",
                              fontSize: 14,
                              color: _isListButtonActive
                                  ? Colors.white
                                  : Colors.black)),
                    ],
                  ),
                ),
              ),
            ),
            // Top Container with Dividers and Text (White Background)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.orange.withOpacity(0.6),
                        thickness: 1,
                        endIndent: 8,
                      ),
                    ),
                    const Text(
                      'Medical',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "MontserratM",
                        color: Colors.black,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.orange.withOpacity(0.6),
                        thickness: 1,
                        indent: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Container with Hospital Details
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 330,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_hospital, color: Colors.orange, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Hospitals Near you',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "MontserratM",
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/hospital.png', // Replace with your hospital image
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sen Hospital',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "MontserratM",
                                    
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.star,
                                        color: Colors.orange, size: 16),
                                    SizedBox(width: 4),
                                    Text('4.7 (1.8k)', style: TextStyle(fontFamily: "MontserratR",),),
                                    
                                  ],
                                ),
                                Text(
                                  'Oncologist, Psychiatrist',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "MontserratR",
                                    
                                  ),
                                ),
                                SizedBox(height: 4),
                               Text(
                                      'Open 24 hours',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        fontFamily: "MontserratR",
                                        color: Colors.orange,
                                      ),
                                    ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.phone, color: Colors.orange),
                            onPressed: () {
                              // Handle phone button press
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat, color: Colors.orange),
                            onPressed: () {
                              // Handle info button press
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/hospital.png', // Replace with your hospital image
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sen Hospital',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "MontserratM",
                                    
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.star,
                                        color: Colors.orange, size: 16),
                                    SizedBox(width: 4),
                                    Text('4.7 (1.8k)', style: TextStyle(fontFamily: "MontserratR",),),
                                    
                                  ],
                                ),
                                Text(
                                  'Oncologist, Psychiatrist',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "MontserratR",
                                    
                                  ),
                                ),
                                SizedBox(height: 4),
                               Text(
                                      'Open 24 hours',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        fontFamily: "MontserratR",
                                        color: Colors.orange,
                                      ),
                                    ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.phone, color: Colors.orange),
                            onPressed: () {
                              // Handle phone button press
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat, color: Colors.orange),
                            onPressed: () {
                              // Handle info button press
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Divider(
                        color: Colors.grey.withOpacity(0.6),
                        thickness: 1,
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/hospital.png', // Replace with your hospital image
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sen Hospital',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "MontserratM",
                                    
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.star,
                                        color: Colors.orange, size: 16),
                                    SizedBox(width: 4),
                                    Text('4.7 (1.8k)', style: TextStyle(fontFamily: "MontserratR",),),
                                    
                                  ],
                                ),
                                Text(
                                  'Oncologist, Psychiatrist',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "MontserratR",
                                    
                                  ),
                                ),
                                SizedBox(height: 4),
                               Text(
                                      'Open 24 hours',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        fontFamily: "MontserratR",
                                        color: Colors.orange,
                                      ),
                                    ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.phone, color: Colors.orange),
                            onPressed: () {
                              // Handle phone button press
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat, color: Colors.orange),
                            onPressed: () {
                              // Handle info button press
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Floating container with medically help nearby text
            Positioned(
              bottom: 340,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2), // changes position of shadow
                    ),
                  ],
                ),
                child: const Text(
                  "17 medically help nearby",
                  style: TextStyle(
                    color: Colors.orange,
                    fontFamily: "MontserratM",
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            if (selectedDoctor != null && selectedLocation != null)
              Positioned(
                bottom: 180,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedDoctor!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: "MontserratM",
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Otolaryngologist",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "MontserratR",
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_pin, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            "Location: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: "MontserratR",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Handle call button press
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.phone, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  "Call",
                                  style: TextStyle(
                                    fontFamily: "MontserratM",
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Handle add note button press
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.note_add, color: Colors.orange),
                                SizedBox(width: 8),
                                Text(
                                  "Add Note",
                                  style: TextStyle(
                                    fontFamily: "MontserratM",
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
