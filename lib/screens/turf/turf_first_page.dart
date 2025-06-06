import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:picapool/screens/turf/turf_second_page.dart';

class TurfPage1 extends StatefulWidget {
  const TurfPage1({super.key});

  @override
  State<TurfPage1> createState() => _TurfPage1State();
}

class _TurfPage1State extends State<TurfPage1> {
  Set<String> selectedSports = {};
  final TextEditingController _destinationController = TextEditingController();
  int _selectedPeople = 7; // Default value as shown in the image
  var hour = 5;
  var minute = 45;
  var timeFormat = "AM";
  DateTime selectedDate = DateTime.now();

  final List<String> amPmOptions = ["AM", "PM"];

  final List<Map<String, dynamic>> sports = [
    {'name': 'Cricket', 'icon': Icons.sports_cricket},
    {'name': 'Table Tennis', 'icon': Icons.sports_tennis},
    {'name': 'Tennis', 'icon': Icons.sports_tennis},
    {'name': 'Swimming', 'icon': Icons.pool},
    {'name': 'Football', 'icon': Icons.sports_soccer},
    {'name': 'Bowling', 'icon': Icons.sports},
    {'name': 'Basketball', 'icon': Icons.sports_basketball},
    {'name': 'Volleyball', 'icon': Icons.sports_volleyball},
    {'name': 'Squash', 'icon': Icons.sports_handball},
    {'name': 'Chess', 'icon': Icons.sports_esports},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xffFF8D41))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('Turf',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: "MontserratM",
                              fontWeight: FontWeight.w500)),
                    ),
                    Expanded(child: Divider(color: Color(0xffFF8D41))),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Which sport do you want\nto play?',
                  style: TextStyle(
                      fontSize: 24,
                      fontFamily: "MontserratM",
                      fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 20),
                // First row of chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: sports
                      .sublist(0, 3)
                      .map((sport) => _buildOptionChip(sport))
                      .toList(),
                ),
                // Second row of chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: sports
                      .sublist(3, 5)
                      .map((sport) => _buildOptionChip(sport))
                      .toList(),
                ),
                // Third row of chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: sports
                      .sublist(5, 7)
                      .map((sport) => _buildOptionChip(sport))
                      .toList(),
                ),
                // Fourth row of chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: sports
                      .sublist(7, 10)
                      .map((sport) => _buildOptionChip(sport))
                      .toList(),
                ),
                const SizedBox(height: 20),
                _buildDestinationAndPeople(),
                const SizedBox(height: 40),
                const Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xffFF8D41))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('Select Turf Timing',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: "MontserratM",
                              fontWeight: FontWeight.w500)),
                    ),
                    Expanded(child: Divider(color: Color(0xffFF8D41))),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDateTimePicker(),
                const SizedBox(
                    height: 40), // Add some spacing before the button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TurfRoomsScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFF8D41),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text('Confirm',
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: "MontserratM",
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
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

  Widget _buildDateTimePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Date Picker
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xffFF8D41)),
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
                right: 10, // Adjust these values to position the icon correctly
                top: -5, // Adjust these values to position the icon correctly
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xffFF8D41),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 12, // Adjust the size as needed
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
    );
  }

  Widget _buildDestinationAndPeople() {
    return Column(
      children: [
        const Text(
          'Add destination and how many people do you want to invite?',
          style: TextStyle(
              fontSize: 16,
              fontFamily: "MontserratM",
              color: Color(0xff000000)),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Search Destination Input
            Container(
              width: 230,
              height: 53,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xffFF8D41)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _destinationController,
                      decoration: const InputDecoration(
                        hintText: 'Search Destination',
                        hintStyle: TextStyle(
                            fontSize: 16,
                            fontFamily: "MontserratM",
                            color: Color(0xff8C8C8C)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Number Dropdown
            Container(
              width: 73,
              height: 53,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(50),
              ),
              child: DropdownButton<int>(
                value: _selectedPeople,
                items: List.generate(
                    10,
                    (index) => DropdownMenuItem<int>(
                          value: index,
                          child: Center(
                            child: Text('$index',
                                style: const TextStyle(
                                    fontFamily: "MontserratM", fontSize: 16)),
                          ),
                        )),
                onChanged: (value) {
                  setState(() {
                    _selectedPeople = value!;
                  });
                },
                underline: const SizedBox(),
                isExpanded: true,
                icon:
                    const Icon(Icons.arrow_drop_down, color: Color(0xff8C8C8C)),
                iconSize: 24,
                style: const TextStyle(color: Color(0xff8C8C8C)),
              ),
            ),
          ],
        ),
      ],
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
      itemWidth: 65,
      itemHeight: 60,
      onChanged: onChanged,
      textStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      selectedTextStyle: const TextStyle(color: Colors.black, fontSize: 14),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
          ),
          bottom: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildOptionChip(Map<String, dynamic> sport) {
    final isSelected = selectedSports.contains(sport['name']);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(sport['icon'],
                size: 15,
                color: isSelected
                    ? const Color(0xFFFF8D41)
                    : const Color(0xff8C8C8C)),
            const SizedBox(width: 3),
            Text(
              sport['name'],
              style: TextStyle(
                  fontFamily: "MontserratM",
                  fontSize: 12,
                  color: isSelected
                      ? const Color(0xFFFF8D41)
                      : const Color(0xff8C8C8C)),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              selectedSports.add(sport['name']);
            } else {
              selectedSports.remove(sport['name']);
            }
          });
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.orange.withOpacity(0.1),
        labelStyle: TextStyle(
            color: isSelected ? const Color(0xFFFF8D41) : Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: isSelected
                  ? const Color(0xFFFF8D41)
                  : const Color(0xff8C8C8C)),
        ),
        showCheckmark: false,
      ),
    );
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
}
