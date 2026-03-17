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
    (icon: HugeIcons.strokeRoundedFileVideo, label: 'Library'),
    (icon: HugeIcons.strokeRoundedAccountSetting02, label: 'Settings'),
    (icon: HugeIcons.strokeRoundedUser, label: 'User'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    const barHeight = 74.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(40, 0, 40, 16 + bottomPadding),
      child: Container(
        height: barHeight,
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
          ],
        ),
        child: Row(
          children: List.generate(_items.length, (i) {
            final active = i == currentIndex;

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    // 🔥 ICON FLOAT EFFECT
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      transform: Matrix4.identity()
                        ..translate(0.0, active ? -10.0 : 0.0)
                        ..scale(active ? 1.1 : 1.0),
                      child: Icon(
                        _items[i].icon,
                        size: 24,
                        color: active
                            ? Colors.white
                            : Colors.white.withOpacity(0.45),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // 🔥 LABEL
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: active ? 1 : 0.5,
                      child: Text(
                        _items[i].label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: active
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
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