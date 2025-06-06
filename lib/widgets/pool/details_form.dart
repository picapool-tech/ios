import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picapool/utils/center_custom_text.dart';
import 'package:picapool/utils/custom_textfield.dart';
import 'package:picapool/utils/large_button.dart';
import 'package:picapool/utils/svg_icon.dart';
import 'package:picapool/widgets/pool/online_offline_switch.dart';

class OfferDetailsForm extends StatefulWidget {
  const OfferDetailsForm({super.key});

  @override
  State<OfferDetailsForm> createState() => _OfferDetailsFormState();
}

class _OfferDetailsFormState extends State<OfferDetailsForm> {
  TextEditingController offerController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  bool isOffline = true;

  String? selectedCategory;
  List<String> categories = ["Food", "Apparel", "Entertainment", "Electronics"];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        height: size.height * 0.55,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
        ),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
            child: SingleChildScrollView(
                child: Column(children: [
              const CenterAlignText(
                  text: "Create your Pool!",
                  size: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff333333)),
              const CenterAlignText(
                  text: "Enter Offer Details",
                  size: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff666666)),
              const SizedBox(
                height: 24,
              ),
              OnlineOfflineSwtich(onChange: (value) {
                setState(() {
                  isOffline = value;
                });
              }),
              const SizedBox(
                height: 24,
              ),
              CustomTextfield(
                controller: offerController,
                hint: "Offer Name",
                icon: const SvgIcon(
                  "assets/icons/ticket.svg",
                  size: 30,
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              CustomTextfield(
                controller: brandController,
                hint: "Brand",
                icon: const SvgIcon(
                  "assets/icons/bag.svg",
                  size: 30,
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              categoryWidget(),
              const SizedBox(
                height: 14,
              ),
              CustomTextfield(
                controller: locationController,
                hint: isOffline ? "Location" : "Website",
                icon: SvgIcon(
                  isOffline
                      ? "assets/icons/marker.svg"
                      : "assets/icons/link.svg",
                  size: 30,
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              LargeButton(text: "Next", onPressed: () {})
            ]))));
  }

  Widget categoryWidget() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xff333399).withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffFF8D41), width: 1.2),
      ),
      child: Center(
        child: DropdownButton<String>(
          padding: const EdgeInsets.only(left: 12),
          borderRadius: BorderRadius.circular(16),
          focusColor: Colors.transparent,
          iconEnabledColor: const Color(0xffAAAAAA),
          icon: Container(
            margin: const EdgeInsets.only(right: 12),
            child: const Icon(
              Icons.arrow_drop_down,
              size: 32,
            ),
          ),
          isExpanded: true,
          underline: Container(),
          value: selectedCategory,
          onChanged: (String? value) {
            if (value != null) {
              setState(() {
                selectedCategory = value;
              });
            }
          },
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Row(
                children: [
                  const SvgIcon(
                    "assets/icons/sort.svg",
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Category",
                    style: GoogleFonts.montserrat(
                      color: const Color(0xffAAAAAA),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            ...categories.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    const SvgIcon(
                      "assets/icons/sort.svg",
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      value,
                      style: GoogleFonts.montserrat(
                        color: const Color(0xff333333),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
