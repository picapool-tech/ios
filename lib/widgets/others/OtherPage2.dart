// import 'package:flutter/material.dart';
// import 'package:picapool/screens/location_fetch_screen.dart';
// import 'package:picapool/widgets/Sell_Form_Page0.dart';
// import 'package:picapool/widgets/home/location_widget.dart';

// class OtherPage2 extends StatefulWidget {
//   @override
//   State<OtherPage2> createState() => _OtherPage2State();
// }

// class _OtherPage2State extends State<OtherPage2> {
//   String currentLocation = "6th st, Connaught place, New Delhi, India";
//   void _updateLocation(String location) {
//     setState(() {
//       currentLocation = location;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(height: 50),
//             const Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: LocationWidget(
//                   color: Colors.black,
//                 )),
//             Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const StepIndicator(currentStep: 3),
//                   const SizedBox(height: 20),
//                   Row(
//                     children: [
//                       Expanded(
//                           child: buildTextField(
//                               label: 'Time held (Years):', hintText: '')),
//                       const SizedBox(width: 10),
//                       Expanded(
//                           child:
//                               buildTextField(label: 'Months:', hintText: '')),
//                     ],
//                   ),
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: CheckboxListTile(
//                       title: const Text("Less than a month"),
//                       value: false,
//                       onChanged: (newValue) {},
//                       controlAffinity: ListTileControlAffinity.leading,
//                     ),
//                   ),
//                   buildUnderlineTextField(
//                       label: 'Reason for sell:', hintText: ''),
//                   const SizedBox(height: 20),
//                   buildUnderlineTextField(
//                       label: 'Selling price:', hintText: ''),
//                   const SizedBox(height: 20),
//                   buildTextField(label: 'Phone number:', hintText: ''),
//                   const SizedBox(height: 20),
//                   buildTextField(label: 'Email ID:', hintText: ''),
//                   const SizedBox(height: 20),
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         // Handle final sell action
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xffFF8D41),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                       ),
//                       child: const Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Next',
//                             style: TextStyle(
//                                 fontSize: 20,
//                                 color: Colors.white,
//                                 fontFamily: "MontserratSB"),
//                           ),
//                           SizedBox(width: 10),
//                           Icon(
//                             Icons.arrow_forward_ios,
//                             color: Colors.white,
//                             size: 20,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildUnderlineTextField(
//       {required String label, required String hintText}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.black87,
//             fontSize: 16,
//             fontFamily: 'MontserratR',
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: Colors.transparent,
//             hintText: hintText,
//             hintStyle: const TextStyle(
//               color: Colors.grey,
//               fontFamily: 'MontserratR',
//               fontSize: 14,
//             ),
//             enabledBorder: const UnderlineInputBorder(
//               borderSide: BorderSide(color: Colors.grey),
//             ),
//             focusedBorder: const UnderlineInputBorder(
//               borderSide: BorderSide(color: Colors.orange, width: 2),
//             ),
//             contentPadding: const EdgeInsets.symmetric(vertical: 5),
//           ),
//           style: const TextStyle(fontSize: 16, fontFamily: 'MontserratR'),
//         ),
//       ],
//     );
//   }

//   Widget buildTextField({required String label, required String hintText}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: TextSpan(
//             text: label,
//             style: const TextStyle(
//               color: Colors.black87,
//               fontSize: 16,
//               fontFamily: 'MontserratR',
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: Colors.transparent,
//             hintText: hintText,
//             hintStyle: const TextStyle(
//                 color: Colors.grey, fontFamily: 'MontserratR', fontSize: 12),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Color(0xFFA3A3A3), width: 1),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Color(0xFFFF8D41), width: 2),
//             ),
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           ),
//           style: const TextStyle(fontSize: 14, fontFamily: 'MontserratR'),
//         ),
//       ],
//     );
//   }
// }
