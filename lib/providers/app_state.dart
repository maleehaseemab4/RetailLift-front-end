import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  bool _isLoggedIn = false;

  final List<NotificationItem> _notifications = [];

  AppState() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _isLoggedIn = user != null;
      notifyListeners();
    });
  }

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isLoggedIn => _isLoggedIn;
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  /// Initializes FCM listeners and prints the device token to the console
  // lib/providers/app_state.dart

  void initNotificationListeners() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // 1. Explicitly request permission for Web
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');

        String? token = await messaging.getToken(
          vapidKey:
              "BOhQKfhOy-8aXO1ODCEqMPN-4NA_19eeob-1oOFjaaK6SQvS_Dj6mzie0U6S0CHkcApyvyJZMPfxiCoeYrrS68U",
        );

        debugPrint("================================================");
        debugPrint("RETAILLIFT FCM TOKEN: $token");
        debugPrint("================================================");
      } else {
        debugPrint('User declined or has not accepted permission');
      }

      // 3. Foreground listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          addNotification(
            message.notification!.body ?? "Theft Alert Detected",
            'warning',
          );
        }
      });
    } catch (e) {
      debugPrint("Error initializing FCM: $e");
    }
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleNotifications(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _notifications.clear();
    notifyListeners();
  }

  void addNotification(String message, String type) {
    if (!_notificationsEnabled) return;

    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      type: type,
      timestamp: DateTime.now(),
    );

    _notifications.insert(0, notification);
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}

class NotificationItem {
  final String id;
  final String message;
  final String type;
  final DateTime timestamp;

  NotificationItem({
    required this.id,
    required this.message,
    required this.type,
    required this.timestamp,
  });
}


//BOhQKfhOy-8aXO1ODCEqMPN-4NA_19eeob-1oOFjaaK6SQvS_Dj6mzie0U6S0CHkcApyvyJZMPfxiCoeYrrS68U