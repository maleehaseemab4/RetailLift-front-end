import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoplifting_app/providers/app_state.dart';
import 'package:shoplifting_app/screens/dashboard_screen.dart';
import 'package:shoplifting_app/screens/camera_incident_screen.dart';
import 'package:shoplifting_app/screens/live_monitor_screen.dart';
import 'package:shoplifting_app/screens/settings_screen.dart';
import 'package:shoplifting_app/theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppState())],
      child: const ShopliftingApp(),
    ),
  );
}

class ShopliftingApp extends StatelessWidget {
  const ShopliftingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return MaterialApp(
      title: 'RetailLift',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appState.themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/camera': (context) => const CameraIncidentScreen(),
        '/live-monitor': (context) => const LiveMonitorScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
