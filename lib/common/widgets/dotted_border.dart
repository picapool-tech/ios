import 'package:flutter/material.dart';

class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;
  final double borderRadius;

  DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashGap,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    // Create a dash path
    final dashPath = Path();
    final dashOffset = dashLength + dashGap;

    // Calculate the length of the path
    var metricsIterator = path.computeMetrics().iterator;
    while (metricsIterator.moveNext()) {
      var metric = metricsIterator.current;
      var totalLength = metric.length;
      var currentDistance = 0.0;

      while (currentDistance < totalLength) {
        // Draw dash
        var dashEndPoint = currentDistance + dashLength;
        dashEndPoint = dashEndPoint > totalLength ? totalLength : dashEndPoint;
        dashPath.addPath(
          metric.extractPath(currentDistance, dashEndPoint),
          Offset.zero,
        );

        // Move to next dash start point
        currentDistance += dashOffset;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
