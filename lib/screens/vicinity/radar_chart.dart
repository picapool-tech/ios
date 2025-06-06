import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const RadarChartApp());

class RadarChartAnimation extends StatefulWidget {
  const RadarChartAnimation({super.key});

  @override
  State<RadarChartAnimation> createState() => _RadarChartAnimationState();
}

class RadarChartApp extends StatelessWidget {
  const RadarChartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Radar Chart Animation')),
        body: const Center(child: RadarChartAnimation()),
      ),
    );
  }
}

class RadarChartPainter extends CustomPainter {
  final double animationValue;
  final double radius;

  RadarChartPainter(this.animationValue, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint radarPaint = Paint()
      ..color = Colors.deepPurpleAccent.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final Offset center = Offset(size.width / 2, size.height / 2);

    // Draw the radar circle
    canvas.drawCircle(center, radius, radarPaint);

    // Calculate the position of the moving point (clockwise direction)
    final Offset movingPoint = Offset(
      center.dx + radius * cos(animationValue * 2 * pi),
      center.dy + radius * sin(animationValue * 2 * pi),
    );

    // Draw the shaded area
    final Path shadedPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(movingPoint.dx, movingPoint.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        animationValue * 2 * pi,
        pi / 6,
        false,
      )
      ..close();

    canvas.drawPath(shadedPath, radarPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _RadarChartAnimationState extends State<RadarChartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _radius = 100.0; // Initial radius value

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Slider(
          value: _radius,
          min: 50.0,
          max: 150.0,
          divisions: 20,
          label: _radius.round().toString(),
          onChanged: (double value) {
            setState(() {
              _radius = value;
            });
          },
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: RadarChartPainter(_controller.value, _radius),
                size: const Size(300, 300),
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
      duration: const Duration(seconds: 10), // Slow, continuous animation
    )..repeat(); // Loop continuously without reversing
  }
}
