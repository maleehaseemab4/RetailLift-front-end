import 'package:flutter/material.dart';


class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  bool _isLoggedIn = false;
  
  final List<NotificationItem> _notifications = [];

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isLoggedIn => _isLoggedIn;
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleNotifications(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  void login(String email, String password) {
    // In a real app, validate credentials here
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
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
    
    // Play system beep
    // FlutterBeep.beep(); // Removed due to build error
    
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
  final String type; // 'warning', 'info', etc.
  final DateTime timestamp;

  NotificationItem({
    required this.id,
    required this.message,
    required this.type,
    required this.timestamp,
  });
}
