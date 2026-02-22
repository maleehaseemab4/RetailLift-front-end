import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class SystemStatusCard extends StatelessWidget {
  final int alertsToday;
  final String theftRate;
  final int activeCameras;
  final Color? backgroundColor;

  const SystemStatusCard({
    super.key,
    required this.alertsToday,
    required this.theftRate,
    required this.activeCameras,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            backgroundColor ?? const Color(0xFFE1F5FE), // Light Blue background
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SYSTEM STATUS',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monitoring Active',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0D47A1), // Deep Blue Text
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$activeCameras Cameras Online',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFCCFFCC,
                  ).withValues(alpha: 0.5), // Light Green
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.gpp_good_rounded,
                  color: Color(0xFF00AA00), // Green Icon
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _statBox(
                  context,
                  'ALERTS TODAY',
                  alertsToday.toString(),
                  delayMs: 200,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _statBox(context, 'THEFT RATE', theftRate, delayMs: 300),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, duration: 400.ms);
  }

  Widget _statBox(
    BuildContext context,
    String label,
    String value, {
    required int delayMs,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0D47A1),
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: delayMs)).fadeIn().scale();
  }
}
