import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shoplifting_app/screens/dashboard_screen.dart';
import 'package:shoplifting_app/screens/live_monitor_screen.dart';
import 'package:shoplifting_app/screens/camera_incident_screen.dart';
import 'package:shoplifting_app/screens/settings_screen.dart';
import 'package:shoplifting_app/screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  static const List<Widget> _screens = [
    DashboardScreen(),
    LiveMonitorScreen(),
    CameraIncidentScreen(),
    SettingsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final void Function(int) onTap;

  static const _items = [
    (icon: HugeIcons.strokeRoundedDashboardBrowsing, label: 'Home'),
    (icon: HugeIcons.strokeRoundedCameraTripod, label: 'Monitor'),
    (icon: HugeIcons.strokeRoundedFileVideo, label: 'History'),
    (icon: HugeIcons.strokeRoundedAccountSetting02, label: 'Settings'),
    (icon: HugeIcons.strokeRoundedUser, label: 'User'),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(40, 0, 40, 16 + bottomPadding),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF0C0E22),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: primary.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_items.length, (i) {
            final active = i == currentIndex;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: SizedBox(
                width: 60,
                height: 64,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: active
                            ? primary.withOpacity(0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _items[i].icon,
                        size: 22,
                        color: active
                            ? primary
                            : Colors.white.withOpacity(0.40),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _items[i].label,
                      style: TextStyle(
                        fontSize: 10,
                        color: active
                            ? primary
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}