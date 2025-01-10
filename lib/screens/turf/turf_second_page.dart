import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TurfRoomsScreen extends StatelessWidget {
  const TurfRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F0F0),
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(),
            const LocationAndDateSelector(),
            const SizedBox(height: 20),
            SingleChildScrollView(
              child: Container(
                height: 600,
                
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    const AvailableGamesTitle(),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          buildGameRoomCard("5:45 pm", "Basketball", "255m away", "Room for 9"),
                          const SizedBox(height: 10),
                          buildGameRoomCard("5:45 pm", "Squash", "255m away", "Room for 7"),
                          const SizedBox(height: 10),
                          buildGameRoomCard("6:00 pm", "Football", "300m away", "Room for 10"),
                        ],
                      ),
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

  Widget buildGameRoomCard(String time, String gameType, String distance, String roomInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xffFF8D41), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    time,
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.sports_basketball, color: Color(0xffFF8D41), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        gameType,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // SizedBox(width: 30),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xffFF8D41), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        distance,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.run_circle, color: Color(0xffFF8D41), size: 16),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Color(0xffFF8D41), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        roomInfo,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: const Color(0xffFF8D41),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "See Address",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: const Color(0xff000000),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down_circle, color: Color(0xffFF8D41), size: 16),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Container(
                height: 100,
                width: 90,
                decoration: BoxDecoration(
                  color: const Color(0xffFF8D41),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat, color: Colors.white, size: 50),
                    const SizedBox(height: 4),
                    Text(
                      "Go to chat",
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Text(
            "Rooms for turf",
            style: GoogleFonts.montserrat(
                fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class LocationAndDateSelector extends StatelessWidget {
  const LocationAndDateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.circle, color: Color(0xffFF8D41)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "6th street, Connaught place, New delhi...",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "<",
                style: GoogleFonts.montserrat(
                    fontSize: 18, fontWeight: FontWeight.w500, color: const Color(0xffFF8D41)),
              ),
              const SizedBox(width: 16),
              Text(
                "24 June , 2024",
                style: GoogleFonts.montserrat(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 16),
              Text(
                ">",
                style: GoogleFonts.montserrat(
                    fontSize: 18, fontWeight: FontWeight.w500, color: const Color(0xffFF8D41)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AvailableGamesTitle extends StatelessWidget {
  const AvailableGamesTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
              child: Divider(indent: 40, color: Color(0xffFF8D41))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Available games",
              style: GoogleFonts.montserrat(
                  fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const Expanded(
              child: Divider(endIndent: 40, color: Color(0xffFF8D41))),
        ],
      ),
    );
  }
}
