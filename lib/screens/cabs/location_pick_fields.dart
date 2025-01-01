import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class CurrentLocationField extends StatefulWidget {
  const CurrentLocationField(
  {super.key, required this.fromController});

  final TextEditingController fromController;

  @override
  State<CurrentLocationField> createState() => _CurrentLocationFieldState();
}

class _CurrentLocationFieldState extends State<CurrentLocationField> {
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GooglePlaceAutoCompleteTextField(
          textStyle: GoogleFonts.montserrat(
              color: const Color(0xff333333), fontSize: 14, fontWeight: FontWeight.w400),
          boxDecoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: const Color(0xffFF8D41), width: 1.2),
          ),
          textEditingController: widget.fromController,
          googleAPIKey: "AIzaSyBoAHaJWyiCrTL4UnoE0I7jEpYja872Psk",
          inputDecoration: InputDecoration(
            prefix: const Icon(Icons.navigation_rounded, color: Colors.orange, size: 24 ),
            suffix: const Icon(Icons.favorite_border, color: Colors.orange, size: 24 ),
            hintText: " From ",
            hintStyle: GoogleFonts.montserrat(
                color: const Color(0xff333333).withOpacity(0.5),
                fontSize: 14,
                fontWeight: FontWeight.w400),
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          ),
          countries: const ["in"],
          itemClick: (Prediction prediction) {
            widget.fromController.text = prediction.description!;
            widget.fromController.selection = TextSelection.fromPosition(
                TextPosition(offset: prediction.description!.length));
          },
          itemBuilder: (context, index, Prediction prediction) {
            return Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const Icon(Icons.location_on),
                  const SizedBox(
                    width: 7,
                  ),
                  Expanded(child: Text(prediction.description ?? ""))
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}


class DestinationLocationField extends StatefulWidget {
  const DestinationLocationField(
  {super.key, required this.toController});

  final TextEditingController toController;

  @override
  State<DestinationLocationField> createState() => _DestinationLocationFieldState();
}

class _DestinationLocationFieldState extends State<DestinationLocationField> {
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GooglePlaceAutoCompleteTextField(
          textStyle: GoogleFonts.montserrat(
              color: const Color(0xff333333), fontSize: 14, fontWeight: FontWeight.w400),
          boxDecoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: const Color(0xffFF8D41), width: 1.2),
          ),
          textEditingController: widget.toController,
          googleAPIKey: "AIzaSyBoAHaJWyiCrTL4UnoE0I7jEpYja872Psk",
          inputDecoration: InputDecoration(
            prefix: Icon(Icons.location_on, size: 20, color:  Colors.orange,) ,
            hintText: " To ",
            hintStyle: GoogleFonts.montserrat(
                color: const Color(0xff333333).withOpacity(0.5),
                fontSize: 14,
                fontWeight: FontWeight.w400),
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          ),
          countries: const ["in"],
          itemClick: (Prediction prediction) {
            widget.toController.text = prediction.description!;
            widget.toController.selection = TextSelection.fromPosition(
                TextPosition(offset: prediction.description!.length));
          },
          itemBuilder: (context, index, Prediction prediction) {
            return Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const Icon(Icons.location_on),
                  const SizedBox(
                    width: 7,
                  ),
                  Expanded(child: Text(prediction.description ?? ""))
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
