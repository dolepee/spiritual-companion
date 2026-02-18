import 'dart:math' as math;
import 'package:flutter/material.dart';

class QiblaCompass extends StatelessWidget {
  final double heading;
  final double qiblaDirection;

  const QiblaCompass({
    super.key,
    required this.heading,
    required this.qiblaDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 3,
            ),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: CustomPaint(
            painter: CompassPainter(
              heading: heading,
              qiblaDirection: qiblaDirection,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.navigation,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Qibla',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class CompassPainter extends CustomPainter {
  final double heading;
  final double qiblaDirection;

  CompassPainter({
    required this.heading,
    required this.qiblaDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.grey;

    canvas.drawCircle(center, radius, paint);

    _drawDirectionMark(canvas, center, radius, 0, 'N', Colors.red);
    _drawDirectionMark(canvas, center, radius, 90, 'E', Colors.grey);
    _drawDirectionMark(canvas, center, radius, 180, 'S', Colors.grey);
    _drawDirectionMark(canvas, center, radius, 270, 'W', Colors.grey);

    final qiblaAngle = ((qiblaDirection - heading) % 360 + 360) % 360;
    _drawQiblaIndicator(canvas, center, radius * 0.8, qiblaAngle);
  }

  void _drawDirectionMark(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    String label,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3;

    final angleRad = (angle - 90) * math.pi / 180;
    final start = center;
    final end = Offset(
      center.dx + radius * 0.9 * math.cos(angleRad),
      center.dy + radius * 0.9 * math.sin(angleRad),
    );

    canvas.drawLine(start, end, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    final labelRadius = radius * 1.15;
    final labelPos = Offset(
      center.dx + labelRadius * math.cos(angleRad) - 8,
      center.dy + labelRadius * math.sin(angleRad) - 8,
    );

    textPainter.layout();
    textPainter.paint(canvas, labelPos);
  }

  void _drawQiblaIndicator(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
  ) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4;

    final angleRad = (angle - 90) * math.pi / 180;
    final end = Offset(
      center.dx + radius * math.cos(angleRad),
      center.dy + radius * math.sin(angleRad),
    );

    canvas.drawLine(center, end, paint);

    final indicatorPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    canvas.drawCircle(end, 8, indicatorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! CompassPainter) return true;
    return oldDelegate.heading != heading ||
        oldDelegate.qiblaDirection != qiblaDirection;
  }
}
