import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LargeButton extends StatefulWidget {
  final String text;
  final void Function() onPressed;
  final bool isEnabled;
  final Color bgColor;
  final double size;
  const LargeButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.isEnabled = true,
      this.bgColor = const Color(0xffFF8D41),
      this.size = 16.0});

  @override
  State<StatefulWidget> createState() {
    return _LargeButtonState();
  }
}

class _LargeButtonState extends State<LargeButton> {
  @override
  Widget build(context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: const Color(0xff333399).withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, -4))
        ],
        color: widget.isEnabled ? widget.bgColor : Colors.grey,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isEnabled ? widget.onPressed : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              widget.text,
              style: GoogleFonts.montserrat(
                  fontSize: widget.size,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xffFFF7F3)),
            ),
          ),
        ),
      ),
    );
  }
}
