import 'package:flutter/material.dart';

class SparklePainter extends CustomPainter {
  final double sparklePosition;
  final double progressWidth;

  SparklePainter({required this.sparklePosition, required this.progressWidth});

  @override
  void paint(Canvas canvas, Size size) {
    if (sparklePosition > progressWidth) return;

    final sparklePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final sparkle = Offset(sparklePosition, size.height / 2);
    canvas.drawCircle(sparkle, 5, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SparklingProgressIndicator extends StatefulWidget {
  final double value;

  const SparklingProgressIndicator({super.key, required this.value});

  @override
  State<SparklingProgressIndicator> createState() =>
      _SparklingProgressIndicatorState();
}

class _SparklingProgressIndicatorState extends State<SparklingProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The LinearProgressIndicator
        LinearProgressIndicator(
          value: widget.value,
          minHeight: 10,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        // The sparkle effect
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double sparkleX =
                  widget.value * MediaQuery.of(context).size.width;
              double offset = (sparkleX - sparkleX * _controller.value);

              return CustomPaint(
                painter: SparklePainter(
                  sparklePosition: sparkleX * _controller.value - offset,
                  progressWidth:
                      widget.value * MediaQuery.of(context).size.width,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }
}
