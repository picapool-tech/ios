import 'package:flutter/material.dart';
import 'package:picapool/screens/Medical/medical_second_page.dart';

class MedicalAttentionPage extends StatefulWidget {
  const MedicalAttentionPage({super.key});

  @override
  State<MedicalAttentionPage> createState() => _MedicalAttentionPageState();
}

class _MedicalAttentionPageState extends State<MedicalAttentionPage> {
  Set<String> selectedParts = {};
  final TextEditingController _otherController = TextEditingController();

  final List<Map<String, dynamic>> bodyParts = [
    {'name': 'Head', 'icon': Icons.face},
    {'name': 'Eye', 'icon': Icons.remove_red_eye},
    {'name': 'Ear', 'icon': Icons.hearing},
    {'name': 'Nose', 'icon': Icons.energy_savings_leaf},
    {'name': 'Teeth', 'icon': Icons.emoji_emotions},
    {'name': 'Throat', 'icon': Icons.masks},
    {'name': 'Arms', 'icon': Icons.back_hand},
    {'name': 'Skin', 'icon': Icons.waves},
    {'name': 'Stomach', 'icon': Icons.personal_injury},
    {'name': 'Knee', 'icon': Icons.accessibility_new},
    {'name': 'Legs', 'icon': Icons.directions_walk},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(child: Divider(color: Color(0xffFF8D41))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Medical',
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
                'Which part of your body\nrequires medical\nattention?',
                style: TextStyle(
                    fontSize: 24,
                    fontFamily: "MontserratM",
                    fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 20),
              // First row of chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: bodyParts
                    .sublist(0, 4)
                    .map((part) => _buildOptionChip(part))
                    .toList(),
              ),
              // Second row of chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: bodyParts
                    .sublist(4, 8)
                    .map((part) => _buildOptionChip(part))
                    .toList(),
              ),
              // Third row of chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: bodyParts
                    .sublist(8, 11)
                    .map((part) => _buildOptionChip(part))
                    .toList(),
              ),
              const SizedBox(height: 10),
              Center(child: _buildOtherOption()),
              // Spacer(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MedicalPage2()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFF8D41),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text('Next',
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
    );
  }

  Widget _buildOptionChip(Map<String, dynamic> part) {
    final isSelected = selectedParts.contains(part['name']);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(part['icon'],
                size: 15,
                color: isSelected
                    ? const Color(0xFFFF8D41)
                    : const Color(0xff8C8C8C)),
            const SizedBox(width: 3),
            Text(
              part['name'],
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
              selectedParts.add(part['name']);
            } else {
              selectedParts.remove(part['name']);
            }
          });
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.orange
            .withOpacity(0.1), // Change the selected background color to yellow
        labelStyle: TextStyle(
            color: isSelected
                ? const Color(0xFFFF8D41)
                : Colors.black), // FF8D41 when selected
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: isSelected
                  ? const Color(0xFFFF8D41)
                  : const Color(0xff8C8C8C)), // FF8D41 when selected
        ),
        showCheckmark: false, // Ensure no checkmark is shown
      ),
    );
  }

  Widget _buildOtherOption() {
    return Container(
      width: 250,
      height: 53,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextField(
        controller: _otherController,
        decoration: const InputDecoration(
          hintText: 'Other',
          hintStyle: TextStyle(
              fontSize: 16,
              fontFamily: "MontserratM",
              color: Color(0xff8C8C8C)),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
