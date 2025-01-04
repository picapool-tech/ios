import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picapool/models/live_offer/live_offer_entity.dart';
import 'package:picapool/screens/cabs/CreateCab.dart';
import 'package:picapool/screens/create_pool.dart';
import 'package:get/get.dart';
import 'package:picapool/controllers/live_offer_controller.dart';
import 'package:intl/intl.dart';

class ShowAllCabDetails extends StatefulWidget {
  const ShowAllCabDetails({Key? key}) : super(key: key);

  @override
  State<ShowAllCabDetails> createState() => _ShowAllCabDetailsState();
}

class _ShowAllCabDetailsState extends State<ShowAllCabDetails> {
  final LiveOfferController liveOfferController = Get.find();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    liveOfferController.getAllLiveOffers();
  }

  Widget buildWhiteContainer() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          LocationSelector(),
          const SizedBox(height: 30),
          // DatePickerContainer(
          //   selectedDate: _selectedDate,
          //   onDateSelected: _onDateSelected,
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Share a cab",
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CreateCabPoolScreen()));
        },
        child: Icon(
          Icons.add,
          color: Color(0xffffffff),
        ),
        backgroundColor: Color(0xffFF8D41),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildWhiteContainer(),
              const SizedBox(height: 16),
              AvailableRidesTitle(),
              const SizedBox(height: 16),
              SizedBox(
                height: 250, // Adjust height as needed
                child: GetBuilder<LiveOfferController>(
                  builder: (liveOfferInstance) {
                    if (liveOfferInstance.allLiveofferState ==
                        GetAllLiveOfferState.allLiveOffersLoaded) {
                      final filteredOffers =
                          _filterOffersByDate(liveOfferInstance.liveOffersList);

                      if (filteredOffers.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.no_transfer,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                _selectedDate == null
                                    ? "No rides available"
                                    : "No rides available for ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}",
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: filteredOffers.length,
                        itemBuilder: (context, index) {
                          final offer = filteredOffers[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: HorizontalCabCard(
                                seats: offer.seats,
                                updatedAt: offer.updatedAt,
                                fromAddress: offer.fromAddress,
                                toAddress: offer.toAddress,
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return const Center(
                        child: LinearProgressIndicator(color: Colors.orange));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<LiveOffer> _filterOffersByDate(List<LiveOffer> offers) {
    if (_selectedDate == null) {
      return offers;
    }

    final selectedDateStart =
        DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
    final selectedDateEnd = selectedDateStart.add(const Duration(days: 1));

    return offers.where((offer) {
      final updatedAt = offer.updatedAt;
      return updatedAt!.isAfter(selectedDateStart) &&
          updatedAt.isBefore(selectedDateEnd);
    }).toList();
  }
}

class HorizontalCabCard extends StatelessWidget {
  final int? seats;
  final DateTime? updatedAt;
  final String? fromAddress;
  final String? toAddress;

  const HorizontalCabCard({
    Key? key,
    this.seats,
    this.updatedAt,
    this.fromAddress,
    this.toAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  updatedAt == null
                      ? "--"
                      : DateFormat('yyyy-MM-dd').format(updatedAt!),
                  style:
                      const TextStyle(fontFamily: "MontserratM", fontSize: 20),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: List.generate(
                      seats ?? 0,
                      (index) => Padding(
                        padding: EdgeInsets.only(
                            right: index < (seats ?? 0) - 1 ? 2 : 0),
                        child: const Icon(Icons.person,
                            size: 16, color: Color(0xffFF8D41)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildAddressRow("From", fromAddress ?? ""),
            const SizedBox(height: 8),
            buildAddressRow("To", toAddress ?? ""),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFF8D41),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ImageIcon(
                        AssetImage("assets/icons/bus.png"),
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Join Chat",
                        style: TextStyle(
                          fontFamily: "MontserratR",
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAddressRow(String label, String address) {
    return Row(
      children: [
        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: "MontserratM",
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                address,
                style: const TextStyle(fontFamily: "MontserratM"),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LocationSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildLocationRow(
            Colors.orange[100]!, "6th street, Connaught place, New deli..."),
        SizedBox(height: 25),
        buildLocationRow(
            Colors.orange, "6th street, Connaught place, New deli..."),
      ],
    );
  }

  Widget buildLocationRow(Color color, String text) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 12),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.montserrat(
                fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class DateSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back_ios, size: 16, color: Colors.orange),
          SizedBox(width: 8),
          Text(
            "24 June , 2024",
            style: GoogleFonts.montserrat(
                fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange),
        ],
      ),
    );
  }
}

class AvailableRidesTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Available rides",
            style: GoogleFonts.montserrat(
                fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }
}
