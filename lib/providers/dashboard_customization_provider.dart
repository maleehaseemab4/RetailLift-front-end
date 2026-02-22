import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Quick Action item configuration
class QuickActionItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  int order;

  QuickActionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.order,
  });

  Map<String, dynamic> toJson() => {'id': id, 'order': order};
}

/// Provider for dashboard customization (Quick Actions order + System Status color)
class DashboardCustomizationProvider with ChangeNotifier {
  List<QuickActionItem> _quickActions = [];
  Color _systemStatusColor = const Color(0xFF001F3F); // Default deep navy
  bool _isLoading = true;

  DashboardCustomizationProvider() {
    _initializeDefaults();
    _loadPreferences();
  }

  bool get isLoading => _isLoading;

  List<QuickActionItem> get quickActions =>
      List.from(_quickActions)..sort((a, b) => a.order.compareTo(b.order));

  Color get systemStatusColor => _systemStatusColor;

  void _initializeDefaults() {
    _quickActions = [
      QuickActionItem(
        id: 'monitoring',
        title: 'Monitoring',
        subtitle: 'View live feed and recorded clips',
        icon: Icons.remove_red_eye_rounded,
        route: '/live-monitor',
        order: 1,
      ),
      QuickActionItem(
        id: 'incident-library',
        title: 'Incident Library',
        subtitle: 'Browse archive of all detections',
        icon: Icons.video_library_rounded,
        route: '/camera',
        order: 2,
      ),
      QuickActionItem(
        id: 'settings',
        title: 'Settings',
        subtitle: 'App preferences and alerts',
        icon: Icons.settings_rounded,
        route: '/settings',
        order: 3,
      ),
    ];
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Quick Actions order
      final actionsJson = prefs.getString('quick_actions_order');
      if (actionsJson != null) {
        final List<dynamic> decoded = jsonDecode(actionsJson);
        for (var item in decoded) {
          final index = _quickActions.indexWhere((a) => a.id == item['id']);
          if (index != -1) {
            _quickActions[index].order = item['order'] as int;
          }
        }
      }

      // Load System Status color
      final colorValue = prefs.getInt('system_status_color');
      if (colorValue != null) {
        _systemStatusColor = Color(colorValue);
      }
    } catch (e) {
      debugPrint('Error loading dashboard customization: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save Quick Actions order
      final actionsJson = jsonEncode(
        _quickActions.map((a) => a.toJson()).toList(),
      );
      await prefs.setString('quick_actions_order', actionsJson);

      // Save System Status color
      await prefs.setInt('system_status_color', _systemStatusColor.value);
    } catch (e) {
      debugPrint('Error saving dashboard customization: $e');
    }
  }

  void reorderQuickActions(int oldIndex, int newIndex) {
    final sortedActions = quickActions;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final movedAction = sortedActions.removeAt(oldIndex);
    sortedActions.insert(newIndex, movedAction);

    // Update order values
    for (int i = 0; i < sortedActions.length; i++) {
      final actionIndex = _quickActions.indexWhere(
        (a) => a.id == sortedActions[i].id,
      );
      if (actionIndex != -1) {
        _quickActions[actionIndex].order = i + 1;
      }
    }

    _savePreferences();
    notifyListeners();
  }

  void updateSystemStatusColor(Color color) {
    _systemStatusColor = color;
    _savePreferences();
    notifyListeners();
  }

  void resetToDefaults() {
    _initializeDefaults();
    _systemStatusColor = const Color(0xFF001F3F);
    _savePreferences();
    notifyListeners();
  }
}
