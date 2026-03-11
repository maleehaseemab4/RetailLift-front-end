import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  final Widget child;

  const SplashScreen({super.key, required this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _entryController;
  late Animation<double> _fadeIn;
  late Animation<double> _scale;
  bool _showChild = false;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeIn));

    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    _entryController.forward();

    Future.delayed(const Duration(milliseconds: 3800), () {
      if (mounted) setState(() => _showChild = true);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showChild) return widget.child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.transparent : const Color(0xFFF5F7FA);
    final textColor = isDark ? Colors.white : const Color(0xFF001F3F);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 340,
                  height: 340,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Radar pulse rings
                      AnimatedBuilder(
                        animation: _pulseController,
                        // ignore: unnecessary_underscores
                        builder: (_, __) => CustomPaint(
                          size: const Size(340, 340),
                          painter: _RadarPainter(_pulseController.value),
                        ),
                      ),
                      // Original logo — rounded square, unchanged
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4DA8DA).withOpacity(0.35),
                              blurRadius: 40,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: SvgPicture.asset(
                            'assets/icons/logo.svg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'RetailLift',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Detect Shoplifting with AI',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.65),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;

  static const Color _blue = Color(0xFF4DA8DA);
  static const int _pulseCount = 4;
  // Static ring radii (depth rings, always visible)
  static const List<double> _staticRings = [78, 105, 132, 160];

  _RadarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final logoRadius = 75.0; // half of 150px logo
    final maxRadius = size.width / 2;

    // 1. Static depth rings — faint, always visible
    for (int i = 0; i < _staticRings.length; i++) {
      final t = i / (_staticRings.length - 1);
      final opacity = 0.18 - t * 0.10;
      final paint = Paint()
        ..color = _blue.withOpacity(opacity.clamp(0.04, 0.18))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(center, _staticRings[i], paint);
    }

    // 2. Centre glow halo
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [_blue.withOpacity(0.22), _blue.withOpacity(0.0)],
      ).createShader(Rect.fromCircle(center: center, radius: logoRadius + 18));
    canvas.drawCircle(center, logoRadius + 18, haloPaint);

    // 3. Animated pulsing rings — 4 rings staggered evenly
    for (int i = 0; i < _pulseCount; i++) {
      final t = ((progress + i / _pulseCount) % 1.0);
      final radius = logoRadius + (maxRadius - logoRadius) * t;
      final opacity = (1.0 - t) * 0.55;
      final strokeWidth = (1.0 - t) * 3.0 + 0.4;

      final paint = Paint()
        ..color = _blue.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.progress != progress;
}
