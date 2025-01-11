import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picapool/utils/center_custom_text.dart';
import 'package:picapool/utils/large_button.dart';
import 'package:picapool/widgets/login/as_guest.dart';
import 'package:picapool/widgets/login/country_dropdown.dart';
import 'package:picapool/widgets/login/google_button.dart';
import 'package:picapool/widgets/login/otp_verification.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final List<CountryFlag> countries = [
    CountryFlag.fromCountryCode(
      "in",
      height: 30,
      width: 36,
    ),
    CountryFlag.fromCountryCode(
      "de",
      height: 30,
      width: 36,
    ),
  ];

  TextEditingController phoneController = TextEditingController();

  bool finalPhoneNumberRegex(String phone) {
    RegExp phoneNumberRegExp = RegExp(r'^[6789]\d{9}$');
    if (phoneNumberRegExp.hasMatch(phone)) {
      return true;
    }
    return false;
  }

  bool firstDigitRegex(String input) {
    RegExp regex = RegExp(r'^[6789]');

    if (regex.hasMatch(input)) {
      return true;
    }
    return false;
  }

  bool showError = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(34)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CenterAlignText(
                  text: "Welcome to PicaPool!",
                  size: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff333333)),
              CenterAlignText(
                  text: "Where Savings Meet Community",
                  size: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff333333).withOpacity(0.5)),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CountryDropdown(onSelect: (value) {}, countries: countries),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(child: phoneTextFiled())
                ],
              ),
              const SizedBox(height: 16),
              LargeButton(
                  text: "Continue",
                  onPressed: () {
                    if (!finalPhoneNumberRegex(phoneController.text.trim())) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Center(
                        child: Text("Please Enter valid Phone Number!"),
                      )));
                      return;
                    }
                    showModalBottomSheet(
                        isScrollControlled: true,
                        isDismissible: false,
                        enableDrag: false,
                        barrierColor: Colors.transparent,
                        context: context,
                        builder: (ctx) {
                          return OtpVerificationWidget(
                              phoneNumber:
                                  "+91 ${phoneController.text.trim()}");
                        });
                  }),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Color(0xffAAAAAA),
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Text(
                        "Or",
                        style: GoogleFonts.montserrat(
                            color: const Color(0xffAAAAAA),
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      )),
                  const Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Color(0xffAAAAAA),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // const GoogleButton(),
              const SizedBox(height: 16),
              const AsGuest()
            ],
          ),
        ),
      ),
    );
  }

  Widget phoneTextFiled() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: const Color(0xff333399).withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 3))
        ],
      ),
      child: Center(
        child: TextFormField(
          controller: phoneController,
          onChanged: (value) {
            if (value.isEmpty) {
              setState(() {
                showError = false;
              });
              return;
            }
            if (!firstDigitRegex(value)) {
              setState(() {
                showError = true;
              });
            } else if (value.length > 10) {
              setState(() {
                showError = true;
              });
            } else {
              setState(() {
                showError = false;
              });
            }
          },
          keyboardType: TextInputType.phone,
          keyboardAppearance: Brightness.dark,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
              color: const Color(0xff333333)),
          cursorColor: const Color(0xff333333).withOpacity(0.7),
          decoration: InputDecoration(
              // errorText: showError ? "Please Enter a valid phone number!" : null,
              hintText: 'Enter Phone Number',
              hintStyle: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xffAAAAAA)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    width: 2,
                    color: showError
                        ? const Color.fromARGB(255, 255, 41, 41)
                        : const Color(0xffFF8D41),
                  )),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: showError
                        ? const Color.fromARGB(255, 255, 41, 41)
                        : const Color(0xffFF8D41),
                    width: 1.2,
                  )),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: showError
                        ? const Color.fromARGB(255, 255, 41, 41)
                        : const Color(0xffFF8D41),
                    width: 1.2,
                  ))),
        ),
      ),
    );
  }
}
