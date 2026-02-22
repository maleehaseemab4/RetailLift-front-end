import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shoplifting_app/data/mock_repository.dart';
import 'package:shoplifting_app/widgets/menu_card.dart';
import 'package:shoplifting_app/widgets/app_drawer.dart';
import 'package:shoplifting_app/widgets/notification_menu.dart';
import 'package:shoplifting_app/widgets/system_status_card.dart';
import 'package:shoplifting_app/widgets/simple_dashboard_customization_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shoplifting_app/providers/dashboard_customization_provider.dart';

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
      // Access theme colors directly for consistency
      final colorScheme = Theme.of(context).colorScheme;

      return Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: InkWell(
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/logo.svg',
                  width: 32,
                  height: 32,
                ),
                const SizedBox(width: 8),
                Text(
                  'RetailLift',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune),
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
            final quickActions = customizationProvider.quickActions;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                  const SizedBox(height: 32),
                  Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      .animate(delay: const Duration(milliseconds: 200))
                      .fadeIn()
                      .slide(begin: const Offset(0, 1)),
                  const SizedBox(height: 16),
                  // Quick Actions with customizable order
                  ...quickActions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final action = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child:
                          MenuCard(
                                title: action.title,
                                subtitle: action.subtitle,
                                icon: action.icon,
                                color: colorScheme.primary,
                                onTap: () =>
                                    Navigator.pushNamed(context, action.route),
                              )
                              .animate(
                                delay: Duration(
                                  milliseconds: 300 + (index * 100),
                                ),
                              )
                              .slide(begin: const Offset(-1, 0))
                              .fadeIn(),
                    );
                  }),
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
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
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
