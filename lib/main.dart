import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shoplifting_app/providers/app_state.dart';
import 'package:shoplifting_app/screens/dashboard_screen.dart';
import 'package:shoplifting_app/screens/camera_incident_screen.dart';
import 'package:shoplifting_app/screens/live_monitor_screen.dart';
import 'package:shoplifting_app/screens/settings_screen.dart';
import 'package:shoplifting_app/screens/auth/login_screen.dart';
import 'package:shoplifting_app/screens/auth/register_screen.dart';
import 'package:shoplifting_app/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBpLCZNnzLyfdw0oEl3x1Esd3HFAFgWAPw",
        authDomain: "retaillift-8ea18.firebaseapp.com",
        projectId: "retaillift-8ea18",
        storageBucket: "retaillift-8ea18.firebasestorage.app",
        messagingSenderId: "575695088801",
        appId: "1:575695088801:web:073e88c9cf91c3bf9854e0",
        measurementId: "G-2V2L50ZFT2",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  // Register a simple foreground message handler where supported.
  try {
    if (!kIsWeb) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          // Safe debug log for incoming foreground messages
          // message.notification may be null depending on payload
          print('Firebase onMessage: ${message.messageId}');
        }
      });
    }
  } catch (e) {
    // If firebase_messaging isn't configured for a platform, ignore.
  }

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
    // Watch auth state to update initial route if needed,
    // though typically this is done via a splash screen or route guard.
    // For simplicity, we just define the routes here.
    final appState = context.watch<AppState>();

    return MaterialApp(
      title: 'RetailLift',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appState.themeMode,
      // Start app at login if not authenticated
      initialRoute: appState.isLoggedIn ? '/' : '/login',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/camera': (context) => const CameraIncidentScreen(),
        '/live-monitor': (context) => const LiveMonitorScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
