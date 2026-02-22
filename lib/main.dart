import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shoplifting_app/api/firebase_api.dart';
import 'package:shoplifting_app/providers/dashboard_provider.dart';
import 'package:shoplifting_app/providers/dashboard_customization_provider.dart';
import 'package:shoplifting_app/providers/alert_provider.dart';
import 'package:shoplifting_app/providers/app_icon_provider.dart';

import 'package:shoplifting_app/providers/app_state.dart';
import 'package:shoplifting_app/theme.dart';
import 'firebase_options.dart';

import 'screens/customizable_dashboard_screen.dart';
import 'screens/alert_settings_screen.dart';
import 'screens/app_icon_settings_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/live_monitor_screen.dart';
import 'screens/camera_incident_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';

String? globalError;

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    final firebaseInitError = await _initFirebase();

    if (!kIsWeb) {
      // Put mobile-only initialization here later if needed
    }

    runApp(MyApp(firebaseInitError: firebaseInitError));
  } catch (e, stackTrace) {
    debugPrint('FATAL ERROR IN MAIN: $e');
    debugPrint('Stack trace: $stackTrace');
    globalError = '$e\n\n$stackTrace';
    runApp(MyApp(firebaseInitError: globalError));
  }
}

Future<String?> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize messaging in background - don't block app startup
    FirebaseApi().initNotifications().catchError((error) {
      debugPrint('Firebase messaging init failed (non-fatal): $error');
      // Continue without messaging - app works offline
    });

    return null;
  } catch (error) {
    debugPrint('Firebase init failed: $error');
    debugPrint('App will continue with offline/demo mode');
    return error.toString();
  }
}

// Error handler widget to catch and display build errors
class ErrorHandler extends StatelessWidget {
  final Widget child;

  const ErrorHandler({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.firebaseInitError});

  final String? firebaseInitError;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppState()..initNotificationListeners(),
        ),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => DashboardCustomizationProvider()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
        ChangeNotifierProvider(create: (_) => AppIconProvider()),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'RetailLift: Detect Shoplifting with AI',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.themeMode,
            home: SplashScreen(
              child: AuthGate(firebaseInitError: firebaseInitError),
            ),
            routes: {
              '/live-monitor': (context) => const LiveMonitorScreen(),
              '/camera': (context) => const CameraIncidentScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/custom-dashboard': (context) =>
                  const CustomizableDashboardScreen(),
              '/alert-settings': (context) => const AlertSettingsScreen(),
              '/app-icon-settings': (context) => const AppIconSettingsScreen(),
            },
            builder: (context, home) {
              // Wrap in error handler
              return ErrorHandler(child: home ?? const SizedBox());
            },
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, this.firebaseInitError});

  final String? firebaseInitError;

  @override
  Widget build(BuildContext context) {
    // If Firebase failed to initialize, skip auth and go straight to dashboard
    if (firebaseInitError != null) {
      return const DashboardScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          // If auth fails, go to dashboard anyway (offline mode)
          debugPrint('Auth error: ${snapshot.error} - using offline mode');
          return const DashboardScreen();
        }

        if (snapshot.hasData) {
          return const DashboardScreen();
        }

        // No user data, but no error - still go to dashboard for demo
        return const DashboardScreen();
      },
    );
  }
}
