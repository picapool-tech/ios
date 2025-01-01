import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart'; // To format the date
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:picapool/screens/cabs/showallcabs.dart';
import 'package:picapool/widgets/cab/create_live_offer.dart'; // For location search and suggestions

class ShareCabScreen extends StatefulWidget {
  const ShareCabScreen({super.key});

  @override
  _ShareCabScreenState createState() => _ShareCabScreenState();
}

class _ShareCabScreenState extends State<ShareCabScreen> {
  static const LatLng _center = LatLng(25.276987, 55.296249);
  String? _selectedCab; // To track the selected cab marker
  DateTime _selectedDate = DateTime.now(); // Current selected date
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey:'AIzaSyBoAHaJWyiCrTL4UnoE0I7jEpYja872Psk'); // Add your API key here

  TextEditingController _fromController = TextEditingController();
  TextEditingController _toController = TextEditingController();
  List<Prediction> _fromPredictions = [];
  List<Prediction> _toPredictions = [];
  String formattedDate = '';

  // Function to open a date picker and allow the user to select a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        formattedDate = DateFormat('E, d MMM').format(_selectedDate);
      });
  }

  // Function to set the date to today
  void _setToday() {
    setState(() {
      _selectedDate = DateTime.now();
      formattedDate = DateFormat('E, d MMM').format(_selectedDate);
    });
  }

  // Function to set the date to tomorrow
  void _setTomorrow() {
    setState(() {
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      formattedDate = DateFormat('E, d MMM').format(_selectedDate);
    });
  }

  // Function to search location and show suggestions
  Future<void> _searchPlaces(String query, bool isFrom) async {
    if (query.isEmpty) {
      setState(() {
        isFrom ? _fromPredictions.clear() : _toPredictions.clear();
      });
      return;
    }

    var sessionToken = 'xyzabc_1234'; // You may generate this token dynamically
    var response =
        await _places.autocomplete(query, sessionToken: sessionToken);

    if (response.isOkay) {
      setState(() {
        if (isFrom) {
          _fromPredictions = response.predictions;
        } else {
          _toPredictions = response.predictions;
        }
      });
    }
  }

  // Function to select place and fill text field
  Future<void> _selectPlace(Prediction prediction, bool isFrom) async {
    final placeId = prediction.placeId;
    if (placeId == null) return;

    var details = await _places.getDetailsByPlaceId(placeId);
    final location = details.result.geometry?.location;
    if (location == null) return;

    setState(() {
      if (isFrom) {
        _fromController.text = prediction.description ?? '';
        _fromPredictions.clear();
      } else {
        _toController.text = prediction.description ?? '';
        _toPredictions.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    formattedDate = DateFormat('E, d MMM').format(_selectedDate); // Format date

  return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Share a Cab', textAlign: TextAlign.left, style: TextStyle(fontFamily: "MontserratSB"),),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Top section (search, location inputs, etc.)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 35,
                    bottom: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 8,
                          backgroundColor: Color(0xffFFB889),
                        ),
                        Container(
                          height: 33,
                          width: 2,
                          color: Colors.orange.shade200,
                        ),
                        const CircleAvatar(
                          radius: 8,
                          backgroundColor: Color(0xffFF7519),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 20.0, left: 5.0, top: 10.0),
                    child: Container(
                      height: 150,
                      margin: const EdgeInsets.only(left: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: _fromController,
                                  decoration: const InputDecoration(
                                    hintText: 'From',
                                    hintStyle: TextStyle(
                                      color: Color(0xff6d6d6d),
                                      fontFamily: "MontserratR",
                                      fontSize: 14,
                                    ),
                                    contentPadding: EdgeInsets.only(left: 10.0),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    _searchPlaces(
                                        value, true); // Search from location
                                  },
                                ),
                              ),
                              const Divider(),
                              SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: _toController,
                                  decoration: const InputDecoration(
                                    hintText: 'To',
                                    hintStyle: TextStyle(
                                      color: Color(0xff6d6d6d),
                                      fontFamily: "MontserratR",
                                      fontSize: 14,
                                    ),
                                    contentPadding: EdgeInsets.only(left: 10.0),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    _searchPlaces(
                                        value, false); // Search to location
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Wrap(
                              children:[ Row(
                                children: [
                                  InkWell(
                                      onTap: () => _selectDate(context),
                                      child: const ImageIcon(AssetImage("assets/icons/calendar.png"),color: Color(0xffFF8D41),)),
                                  const SizedBox(width: 8),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: "MontserratSB",
                                    ),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: _setToday,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(0),
                                      backgroundColor: const Color(0xffFFD2B4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Today',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "MontserratSB",
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  ElevatedButton(
                                    onPressed: _setTomorrow,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xffFFD2B4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Tomorrow',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "MontserratSB",
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        ]
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Suggestion boxes as seen in the image
            if (_fromPredictions.isNotEmpty)
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListView.builder(
                  itemCount: _fromPredictions.length,
                  itemBuilder: (context, index) {
                    var prediction = _fromPredictions[index];
                    return ListTile(
                      title: Text(
                        prediction.description ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: "MontserratR",
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      onTap: () => _selectPlace(prediction, true),
                    );
                  },
                ),
              ),
            if (_toPredictions.isNotEmpty)
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListView.builder(
                  itemCount: _toPredictions.length,
                  itemBuilder: (context, index) {
                    var prediction = _toPredictions[index];
                    return ListTile(
                      title: Text(
                        prediction.description ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: "MontserratR",
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      onTap: () => _selectPlace(prediction, false),
                    );
                  },
                ),
              ),
            // Map section and bottom container
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: (controller) {},
                    initialCameraPosition: const CameraPosition(
                      target: _center,
                      zoom: 14.0,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('cab1'),
                        position: const LatLng(25.276987, 55.286249),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue),
                        onTap: () {
                          setState(() {
                            _selectedCab = 'cab1';
                          });
                        },
                      ),
                      Marker(
                        markerId: const MarkerId('cab2'),
                        position: const LatLng(25.276987, 55.306249),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue),
                        onTap: () {
                          setState(() {
                            _selectedCab = 'cab2';
                          });
                        },
                      ),
                      Marker(
                        markerId: const MarkerId('cab3'),
                        position: const LatLng(25.266987, 55.296249),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue),
                        onTap: () {
                          setState(() {
                            _selectedCab = 'cab3';
                          });
                        },
                      ),
                    },
                  ),
                  // Bottom fixed container
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 190, // Fixed height for the bottom container
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Click on the cab to see details',
                            style: TextStyle(fontSize: 14, color: Colors.grey,fontFamily: "MontserratR"),
                          ),
                          SizedBox(height: 15),
                          // GestureDetector(
                          //   onTap: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => const ShowAllCabDetails()),
                          //     );
                          //   },
                          //   child: const Text(
                          //     'Show all >',
                          //     style: TextStyle(
                          //         color: Color(0xffFF8D41),
                          //         fontSize: 14,
                          //         fontFamily: "MontserratSB"),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedCab != null)
                    Positioned(
                      bottom: 40, // Positioned above the bottom container
                      left: 16,
                      right: 16,
                      child: Container(
                        height: 110,
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.04),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "5:45 pm",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "MontserratM"
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.person,
                                        color: Colors.orange,
                                        size: screenWidth * 0.05),
                                    SizedBox(width: screenWidth * 0.01),
                                    Text(
                                      "2 In room",
                                      style: TextStyle(
                                        fontFamily: "MontserratR",
                                          fontSize: screenWidth * 0.04),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.arrow_drop_down,
                                        color: Colors.orange,
                                        size: screenWidth * 0.05),
                                    SizedBox(width: screenWidth * 0.01),
                                    Text(
                                      "105m away",
                                      style: TextStyle(
                                        fontFamily: "MontserratR",
                                          fontSize: screenWidth * 0.04),
                                    ),
                                    SizedBox(width: screenWidth * 0.01),
                                    Icon(Icons.directions_walk,
                                        color: Colors.green,
                                        size: screenWidth * 0.05),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.03),
                                    height: screenHeight * 0.05,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(
                                          screenWidth * 0.07),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on,
                                            color: Colors.grey,
                                            size: screenWidth * 0.05),
                                        SizedBox(width: screenWidth * 0.02),
                                        const Expanded(
                                          child: Text(
                                            "6th street, s...",
                                            style:
                                                TextStyle(color: Colors.black, fontFamily: "MontserratR"),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          "See Route",
                                          style: TextStyle(
                                            fontFamily: "MontserratR",
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth * 0.03,
                                          ),
                                        ),
                                        Icon(Icons.arrow_drop_down,
                                            color: Colors.orange,
                                            size: screenWidth * 0.05),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Container(
                                  height: screenHeight * 0.05,
                                  width: screenWidth * 0.28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffFF8D41),
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.03),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ImageIcon(const AssetImage("assets/icons/bus.png"), color: Colors.white,
                                            size: screenWidth * 0.05),
                                        // Icon(Icons.car_rental,
                                        //     color: Colors.white,
                                        //     size: screenWidth * 0.05),
                                        SizedBox(width: screenWidth * 0.02),
                                        Text(
                                          "Join Chat",
                                          style: TextStyle(
                                            fontFamily: "MontserratSB",
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth * 0.03,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  // The "3 cabs available nearby for this date" container
                  Positioned(
                    bottom: 180, // Positioned above the bottom container
                    left: 40,
                    right: 40,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 3,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text.rich(
                          TextSpan(
                            text: 'Oops! No',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xffFF8D41),fontFamily: "MontserratR"),
                            children: [
                              TextSpan(
                                text: ' cabs ',
                                style: TextStyle(
                                    color: Color(0xffFF8D41),
                                    fontFamily: "MontserratR"),
                              ),
                              TextSpan(
                                text: 'available nearby for this date.',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "MontserratR"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomAppBar(color: Color.fromARGB(255, 228, 228, 228),height: 65 , elevation: 7,),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=> CreateLiveOffer()   ));
      },
      shape: const CircleBorder(),
      backgroundColor: Colors.orange,
      elevation: 7,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(36)),
          border: Border.all(color: Colors.white, width: 2, style: BorderStyle.solid) 
        ),
        child: const Icon(Icons.local_taxi, color: Colors.white,size: 24,)),
      ),
    );
  }
}
