import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shoplifting_app/data/mock_repository.dart';
import 'package:shoplifting_app/widgets/notification_menu.dart';
import 'package:shoplifting_app/widgets/system_status_card.dart';
import 'package:shoplifting_app/widgets/simple_dashboard_customization_sheet.dart';
import 'package:shoplifting_app/widgets/trend_card.dart';
import 'package:shoplifting_app/widgets/peak_hours_card.dart';
import 'package:shoplifting_app/widgets/weekly_rate_card.dart';
import 'package:shoplifting_app/widgets/alert_counts_card.dart';
import 'package:provider/provider.dart';
import 'package:shoplifting_app/providers/dashboard_customization_provider.dart';
import 'package:hugeicons/hugeicons.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'RetailLift',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(HugeIcons.strokeRoundedMenuSquare),
              tooltip: 'Customize Dashboard',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => Consumer<DashboardCustomizationProvider>(
                    builder: (context, _, _) =>
                        const SimpleDashboardCustomizationSheet(),
                  ),
                );
              },
            ),
            const NotificationMenu(),
            const SizedBox(width: 8),
          ],
        ),
        body: Consumer<DashboardCustomizationProvider>(
          builder: (context, customizationProvider, _) {
            final bottomNavPadding =
                MediaQuery.of(context).padding.bottom + 100;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomNavPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                        'Overview',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 500))
                      .slide(
                        duration: const Duration(milliseconds: 500),
                        begin: const Offset(0, 1),
                      ),
                  const SizedBox(height: 10),
                  // System Status Card with customizable color
                  SystemStatusCard(
                    alertsToday: MockRepository.alertsToday,
                    theftRate: '1.2%',
                    activeCameras: 4,
                    backgroundColor: customizationProvider.systemStatusColor,
                  ),
                  const SizedBox(height: 20),
                  // Analytics Widgets
                  SizedBox(height: 300, child: TrendCard()),
                  const SizedBox(height: 16),
                  SizedBox(height: 250, child: PeakHoursCard()),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(height: 120, child: WeeklyRateCard()),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(height: 120, child: AlertCountsCard()),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    } catch (e, _) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  HugeIcons.strokeRoundedAlert02,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Dashboard Error',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  '$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed('/login'),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
