import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shoplifting_app/theme.dart';

/// Wraps any screen in the app's dark gradient background with subtle wave lines.
/// In light mode it is a transparent pass-through so the scaffold shows normally.
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) return child;

    return DecoratedBox(
      decoration: AppTheme.darkGradientBackground,
      child: CustomPaint(painter: _WavePainter(), child: child),
    );
  }
}

class _WavePainter extends CustomPainter {
  // [amplitude, cycleCount, yFraction, opacity, strokeWidth]
  static const _waves = [
    [52.0, 2.4, 0.04, 0.11, 0.8],
    [72.0, 1.7, 0.16, 0.07, 1.1],
    [44.0, 3.1, 0.28, 0.13, 0.7],
    [83.0, 1.4, 0.41, 0.08, 1.2],
    [57.0, 2.7, 0.54, 0.10, 0.9],
    [66.0, 1.9, 0.67, 0.09, 1.0],
    [41.0, 3.3, 0.79, 0.12, 0.7],
    [74.0, 1.6, 0.91, 0.07, 1.1],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final w in _waves) {
      final amplitude = w[0];
      final cycles = w[1];
      final yCenter = size.height * w[2];
      final opacity = w[3];
      final strokeW = w[4];

      final paint = Paint()
        ..color = const Color(0xFF4DA8DA).withOpacity(opacity)
        ..strokeWidth = strokeW
        ..style = PaintingStyle.stroke;

      final path = Path();
      bool first = true;
      for (double x = 0; x <= size.width; x += 2.0) {
        final y = yCenter + amplitude * sin(cycles * x * 2 * pi / size.width);
        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
