import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shoplifting_app/screens/dashboard_screen.dart';
import 'package:shoplifting_app/screens/live_monitor_screen.dart';
import 'package:shoplifting_app/screens/camera_incident_screen.dart';
import 'package:shoplifting_app/screens/settings_screen.dart';
import 'package:shoplifting_app/screens/profile_screen.dart';
import 'package:shoplifting_app/widgets/floating_bottom_nav_bar.dart';

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
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          NavBarItemData(
            icon: HugeIcons.strokeRoundedDashboardBrowsing,
            label: 'Home',
          ),
          NavBarItemData(
            icon: HugeIcons.strokeRoundedCameraTripod,
            label: 'Monitor',
          ),
          NavBarItemData(
            icon: HugeIcons.strokeRoundedFileVideo,
            label: 'Library',
          ),
          NavBarItemData(
            icon: HugeIcons.strokeRoundedAccountSetting02,
            label: 'Settings',
          ),
          NavBarItemData(
            icon: HugeIcons.strokeRoundedUser,
            label: 'User',
          ),
        ],
      ),
    );
  }
}
