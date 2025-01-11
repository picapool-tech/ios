import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VendorLoginButton extends StatelessWidget {
  final String title;
  final Function() onPressed;
  final String assetName;

  const VendorLoginButton({
    super.key,
    required this.title,
    required this.onPressed,
    required this.assetName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 48,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: const Color(0xff333399).withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 3))
        ],
        color: Colors.white,
        border: Border.all(
          color: const Color(0xffBDBDBD),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 16),
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  assetName,
                  width: 30,
                  height: 30,
                  scale: 0.85,
                  fit: BoxFit.scaleDown,
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xffAAAAAA),
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
