import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrekkingPage extends StatefulWidget {
  const TrekkingPage({super.key});

  @override
  State<TrekkingPage> createState() => _TrekkingPageState();
}

class _TrekkingPageState extends State<TrekkingPage> {
  double _radius = 100;
  final LatLng _center = const LatLng(30.3165, 78.0322); // Example location for Dehradun
  bool _isListButtonActive = false;

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
                        'Active trekkers',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "MontserratM",
                        ),
                      ),
                      Text(
                        '48 users available',
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
                    itemCount: 5, // Example number of trekkers
                    itemBuilder: (context, index) {
                      final List<String> names = ['Yash', 'Rohan', 'Diya', 'Rohan', 'Yash'];
                      final List<Color> avatarColors = [
                        Colors.teal,
                        Colors.blue,
                        Colors.orange,
                        Colors.purple,
                        Colors.teal,
                      ];
                      
                      return Column(
                        children: [
                          ListTile(
                            onTap: () => _showTrekkerDetails(context, names[index]),
                            leading: CircleAvatar(
                              backgroundColor: avatarColors[index],
                              child: Text(
                                names[index][0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(names[index], style: const TextStyle(fontFamily: "MontserratM", fontSize: 16),),
                            subtitle: const Text(
                              'View profile',
                              style: TextStyle(color: Colors.orange, fontFamily: "MontserratM", fontSize: 12),
                            ),
                            trailing: SizedBox(
                              height: 30,
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.orange),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  'Message 10 ₹',
                                  style: TextStyle(fontFamily: "MontserratM", fontSize: 12, color: Colors.black),
                                ),
                              ),
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
                markers: {
                  Marker(
                    markerId: const MarkerId("center"),
                    position: _center,
                  ),
                },
              ),
            ),
            // Floating Back Button
            Positioned(
                top: 80,
                left: 16,
                child: GestureDetector(
                  onTap: () =>  Navigator.pop(context),
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
                      'Trekking',
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
            // Bottom Container with Hotel and Car Agency Details
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hotel, color: Colors.orange, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Hotels',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "MontserratM",
                            color: Colors.orange,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/images/hotel_image.png', // Replace with your hotel image
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
                                'Sheraton Grande Hotel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "MontserratM",
                                  
                                ),
                              ),
                              Text(
                                'Dehradun',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "MontserratM",
                                  
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.orange, size: 16),
                                  SizedBox(width: 4),
                                  Text('4.7 (1.8k)', style: TextStyle(fontFamily: "MontserratM",),),
                                  Spacer(),
                                  Text(
                                    '₹ 2,399',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      fontFamily: "MontserratM",
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.car_crash_outlined,
                                      size: 15, color: Colors.orange),
                                  Text(
                                    'Free Parking',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "MontserratR",
                                        fontSize: 12),
                                  ),
                                ],
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
                    const SizedBox(height: 16),
                    Divider(
                      color: Colors.grey.withOpacity(0.6),
                      thickness: 1,
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hotel, color: Colors.orange, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Cars',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "MontserratM",
                            color: Colors.orange,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/images/car_image.png', // Replace with your car image
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
                                'Royal Agency',
                                style: TextStyle(
                                  fontFamily: "MontserratM",
                                  fontSize: 16,
                                  
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.orange, size: 16),
                                  SizedBox(width: 4),
                                  Text('4.7 (1.8k)', style: TextStyle(fontFamily: "MontserratM",),),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.check_box,
                                      size: 15, color: Colors.orange),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "MontserratR",
                                        fontSize: 12),
                                  ),
                                ],
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
                    const SizedBox(height: 36),
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

void _showTrekkerDetails(BuildContext context, String name) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button, Name, and Distance Row
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  "Rohan Kumar",  // This can be dynamic based on the selected user
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'MontserratM',
                  ),
                ),
                const Spacer(),
                const Text(
                  "12 KM away from you",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                    fontFamily: 'MontserratR',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Profile Picture and Bio
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundImage: AssetImage('assets/images/profile_image.png'),  // Replace with your image path
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bio",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'MontserratM',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Passionate adventurer and outdoor enthusiast. Whether it's hiking up rugged mountains or trekking through serene forests. Let's explore the world, one trail at a time.",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'MontserratR',
                          height: 1.5,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Message Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Message",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'MontserratM',
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "10 ₹",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'MontserratM',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
