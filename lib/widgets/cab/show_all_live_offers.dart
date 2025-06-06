import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:picapool/controllers/live_offer_controller.dart';
import 'package:picapool/models/live_offer/live_offer_entity.dart';
import 'package:picapool/widgets/cab/create_live_offer.dart';

class ShowAllLiveOffers extends StatefulWidget {
  const ShowAllLiveOffers({Key? key}) : super(key: key);

  @override
  State<ShowAllLiveOffers> createState() => _ShowAllLiveOffersState();
}

class _ShowAllLiveOffersState extends State<ShowAllLiveOffers> {

  DateTime? _selectedDate;
  
  LiveOfferController get liveOfferController => Get.find();

  @override
  void initState() {
    liveOfferController.getAllLiveOffers();
    super.initState();
  }

  void _onDateSelected(DateTime? date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
      bottomNavigationBar: const BottomAppBar(
        color: Color.fromARGB(255, 228, 228, 228),
        height: 65,
        elevation: 7,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CreateLiveOffer()));
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.orange,
        elevation: 7,
        child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(36)),
                border: Border.all(
                    color: Colors.white, width: 2, style: BorderStyle.solid)),
            child: const Icon(
              Icons.local_taxi,
              color: Colors.white,
              size: 24,
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildWhiteContainer(),
              const SizedBox(height: 16),
              const AvailableRidesHeader(),
              const SizedBox(height: 16),
              GetBuilder<LiveOfferController>(
                builder: (liveOfferInstance) {
                  if (liveOfferInstance.allLiveofferState == GetAllLiveOfferState.allLiveOffersLoaded) {
                    final filteredOffers = _filterOffersByDate(liveOfferInstance.liveOffersList);
                    
                    if (filteredOffers.isEmpty) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.no_transfer, size: 48, color: Colors.grey[400]),
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
                        ),
                      );
                    }

                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredOffers.length,
                        itemBuilder: (context, index) {
                          return AvailableCabCard(
                            seats: filteredOffers[index].seats,
                            updatedAt: filteredOffers[index].updatedAt,
                          );
                        }),
                    );
                  }
                  return const Center(child: LinearProgressIndicator(color: Colors.orange));
                },
              )
            ],
          ),
        ),
      ),
    );
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
          const LocationSelector(),
          const SizedBox(height: 30),
          DatePickerContainer(
            selectedDate: _selectedDate,
            onDateSelected: _onDateSelected,
          ),
        ],
      ),
    );
  }
    List<LiveOffer> _filterOffersByDate(List<LiveOffer> offers) {
    if (_selectedDate == null) {
      return offers; // Return all offers if no date is selected
    }

    final selectedDateStart = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
    final selectedDateEnd = selectedDateStart.add(const Duration(days: 1));

    return offers.where((offer) {
      final updatedAt = offer.updatedAt;
      return updatedAt!.isAfter(selectedDateStart) && updatedAt.isBefore(selectedDateEnd);
    }).toList();
  }
}

class AvailableCabCard extends StatefulWidget {
  int? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? expiryAt;
  int? seats;
  dynamic userId;
  int? livePartnerId;
  
  AvailableCabCard(
      {this.id,
      this.createdAt,
      this.updatedAt,
      this.expiryAt,
      this.seats,
      this.userId,
      this.livePartnerId,
      super.key});

  @override
  State<AvailableCabCard> createState() => AvailableCabCardState();
}

class AvailableCabCardState extends State<AvailableCabCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
      child: Container(
        height: 80,
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.updatedAt == null
                              ? "--"
                              : DateFormat('yyyy-MM-dd')
                                  .format(widget.updatedAt!),
                          style: const TextStyle(
                              fontFamily: "MontserratM", fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: List.generate(
                              widget.seats ?? 0,
                              (index) => Padding(
                                padding:
                                    EdgeInsets.only(right: index < 2 ? 2 : 0),
                                child: const Icon(Icons.person,
                                    size: 16, color: Color(0xffFF8D41)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        const Flexible(
                          child: Text(
                            "6th street, C...",
                            style: TextStyle(fontFamily: "MontserratM"),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "See Route",
                          style: TextStyle(
                              fontFamily: "MontserratM",
                              color: Color(0xffFF8D41)),
                        ),
                        const Icon(Icons.keyboard_arrow_down,
                            size: 14, color: Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
                width: 120,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFF8D41),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ImageIcon(
                          AssetImage("assets/icons/bus.png"),
                          color: Colors.white,
                          size: 10,
                        ),
                        SizedBox(width: 6),
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
      ),
    );
  }
}

class LocationSelector extends StatelessWidget {
  const LocationSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildLocationRow(
            Colors.orange[100]!, "6th street, Connaught place, New deli..."),
        const SizedBox(height: 25),
        buildLocationRow(
            Colors.orange, "6th street, Connaught place, New deli..."),
      ],
    );
  }

  Widget buildLocationRow(Color color, String text) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 8),
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

class DatePickerContainer extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;

  const DatePickerContainer({
    Key? key, 
    this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<DatePickerContainer> createState() => _DatePickerContainerState();
}

class _DatePickerContainerState extends State<DatePickerContainer> {
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != widget.selectedDate) {
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.arrow_back_ios, size: 16, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              widget.selectedDate == null
                  ? 'Select Date'
                  : DateFormat('yyyy-MM-dd').format(widget.selectedDate!),
              style: GoogleFonts.montserrat(
                  fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange),
          ],
        ),
      ),
    );
  }
}
class AvailableRidesHeader extends StatelessWidget {
  const AvailableRidesHeader({super.key});

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

