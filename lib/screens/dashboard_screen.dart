import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shoplifting_app/data/mock_repository.dart';
import 'package:shoplifting_app/widgets/menu_card.dart';
import 'package:shoplifting_app/widgets/app_drawer.dart';
import 'package:shoplifting_app/widgets/notification_menu.dart';
import 'package:shoplifting_app/widgets/system_status_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access theme colors directly for consistency
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: InkWell(
          onTap: () => Navigator.pushReplacementNamed(context, '/'),
          child: Text(
            'RetailLift',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [const NotificationMenu(), const SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                  'Overview',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 500))
                .slide(
                  duration: const Duration(milliseconds: 500),
                  begin: const Offset(0, 1),
                ),
            const SizedBox(height: 10),
            // Stats Square: single rounded card containing 2x2 tiles (no icons)
            // System Status Card
            Center(
              child: SystemStatusCard(
                alertsToday: MockRepository.alertsToday,
                theftRate: '1.2%',
                activeCameras: 4,
              ),
            ),
            const SizedBox(height: 32),
            Text(
                  'Quick Actions',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                )
                .animate(delay: const Duration(milliseconds: 200))
                .fadeIn()
                .slide(begin: const Offset(0, 1)),
            const SizedBox(height: 16),
            MenuCard(
                  title: 'Monitoring',
                  subtitle: 'View live feed and recorded clips',
                  icon: Icons.remove_red_eye_rounded,
                  color: colorScheme.primary,
                  onTap: () => Navigator.pushNamed(context, '/live-monitor'),
                )
                .animate(delay: const Duration(milliseconds: 300))
                .slide(begin: const Offset(-1, 0))
                .fadeIn(),
            const SizedBox(height: 16),
            MenuCard(
                  title: 'Incident Library',
                  subtitle: 'Browse archive of all detections',
                  icon: Icons.video_library_rounded,
                  color: colorScheme.primary,
                  onTap: () => Navigator.pushNamed(context, '/camera'),
                )
                .animate(delay: const Duration(milliseconds: 400))
                .slide(begin: const Offset(-1, 0))
                .fadeIn(),
            const SizedBox(height: 16),
            MenuCard(
                  title: 'Settings',
                  subtitle: 'App preferences and alerts',
                  icon: Icons.settings_rounded,
                  color: colorScheme.primary,
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                )
                .animate(delay: const Duration(milliseconds: 500))
                .slide(begin: const Offset(-1, 0))
                .fadeIn(),
          ],
        ),
      ),
    );
  }

  // Helper to build a single stat tile (no icon) used inside the 2x2 square

}
