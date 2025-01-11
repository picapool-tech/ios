import 'package:flutter/material.dart';
import 'package:picapool/screens/location_fetch_screen.dart';

class LocationBar extends StatefulWidget {
  const LocationBar({super.key});

  @override
  State<LocationBar> createState() => _LocationBarState();
}

class _LocationBarState extends State<LocationBar> {
  String currentLocation = "6th st, Connaught place, New Delhi, India";
    void _updateLocation(String location) {
    setState(() {
      currentLocation = location;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: 
                  InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LocationScreen(),
                        ),
                      );
                      if (result != null) {
                        _updateLocation(result);
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 35,
                          color: Colors.black,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Location',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                            Text(
                              currentLocation.length > 30
                                  ? '${currentLocation.substring(0, 30)}...'
                                  : currentLocation,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
               
                
              
            ),);
  }
}