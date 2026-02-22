import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shoplifting_app/models/dashboard_widget_config.dart';

class DashboardProvider with ChangeNotifier {
  late List<DashboardWidgetConfig> _widgets;
  bool _isLoading = true;
  String? _errorMessage;

  DashboardProvider() {
    _initializeDefaults();
    _loadPreferencesSafely();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _initializeDefaults() {
    _widgets = [
      DashboardWidgetConfig(
        id: 'alerts',
        title: 'Alerts Summary',
        description: 'Daily alerts and theft detection summary',
        isVisible: true,
        size: WidgetSize.medium,
        color: const Color(0xFF001F3F),
        order: 1,
      ),
      DashboardWidgetConfig(
        id: 'camera',
        title: 'Camera Status',
        description: 'Active cameras and their status',
        isVisible: true,
        size: WidgetSize.medium,
        color: const Color(0xFF003366),
        order: 2,
      ),
      DashboardWidgetConfig(
        id: 'incidents',
        title: 'Recent Incidents',
        description: 'Latest detected incidents',
        isVisible: true,
        size: WidgetSize.large,
        color: const Color(0xFF90CAF9),
        order: 3,
      ),
      DashboardWidgetConfig(
        id: 'system-analysis',
        title: 'System Analysis',
        description: 'AI model performance and system analytics',
        isVisible: true,
        size: WidgetSize.medium,
        color: const Color(0xFF4CAF50),
        order: 4,
      ),
    ];
  }

  List<DashboardWidgetConfig> get widgets =>
      _widgets..sort((a, b) => a.order.compareTo(b.order));

  DashboardWidgetConfig getWidget(String id) {
    return _widgets.firstWhere((w) => w.id == id);
  }

  void _loadPreferencesSafely() {
    _loadPreferences()
        .then((_) {
          _isLoading = false;
          notifyListeners();
        })
        .catchError((error) {
          debugPrint('Error in DashboardProvider initialization: $error');
          _isLoading = false;
          _errorMessage = error.toString();
          notifyListeners();
        });
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configsJson = prefs.getString('dashboard_configs');

      if (configsJson != null) {
        try {
          final List<dynamic> decoded = jsonDecode(configsJson);
          _widgets = decoded
              .map((item) => DashboardWidgetConfig.fromJson(item))
              .toList();
          // Sort by order after loading
          _widgets.sort((a, b) => a.order.compareTo(b.order));
        } catch (e) {
          debugPrint('Error decoding dashboard configs: $e');
          // Keep defaults if decode fails
          _errorMessage = 'Failed to load saved preferences';
        }
      } else {
        // First time setup - save defaults
        await _saveConfigurations();
      }
    } catch (e) {
      debugPrint('Error loading dashboard preferences: $e');
      // On web, this might fail due to tracking prevention
      if (e.toString().contains('storage') ||
          e.toString().contains('localStorage')) {
        debugPrint(
          'Storage access blocked - using default dashboard configuration',
        );
      }
      _errorMessage = 'Failed to load dashboard: $e';
      // Keep defaults on error
    }
  }

  void reorderWidgets(int oldIndex, int newIndex) {
    // Get the sorted widgets for correct indexing
    final sortedWidgets = widgets;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Update order values for all widgets
    final movedWidget = sortedWidgets[oldIndex];
    sortedWidgets.removeAt(oldIndex);
    sortedWidgets.insert(newIndex, movedWidget);

    // Reassign order values based on new positions
    for (int i = 0; i < sortedWidgets.length; i++) {
      final widget = sortedWidgets[i];
      final widgetIndex = _widgets.indexWhere((w) => w.id == widget.id);
      if (widgetIndex != -1) {
        _widgets[widgetIndex] = _widgets[widgetIndex].copyWith(order: i + 1);
      }
    }

    _saveConfigurations();
    notifyListeners();
  }

  void toggleVisibility(String id) {
    final index = _widgets.indexWhere((w) => w.id == id);
    if (index != -1) {
      _widgets[index] = _widgets[index].copyWith(
        isVisible: !_widgets[index].isVisible,
      );
      _saveConfigurations();
      notifyListeners();
    }
  }

  void updateWidgetSize(String id, WidgetSize size) {
    final index = _widgets.indexWhere((w) => w.id == id);
    if (index != -1) {
      _widgets[index] = _widgets[index].copyWith(size: size);
      _saveConfigurations();
      notifyListeners();
    }
  }

  void updateWidgetColor(String id, Color color) {
    final index = _widgets.indexWhere((w) => w.id == id);
    if (index != -1) {
      _widgets[index] = _widgets[index].copyWith(color: color);
      _saveConfigurations();
      notifyListeners();
    }
  }

  void resetToDefaults() {
    _initializeDefaults();
    _saveConfigurations();
    notifyListeners();
  }

  void updateWidgetOrder(String id, int newOrder) {
    final index = _widgets.indexWhere((w) => w.id == id);
    if (index != -1) {
      _widgets[index] = _widgets[index].copyWith(order: newOrder);
      _saveConfigurations();
      notifyListeners();
    }
  }

  Future<void> _saveConfigurations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configsJson = jsonEncode(_widgets.map((w) => w.toJson()).toList());
      await prefs.setString('dashboard_configs', configsJson);
    } catch (e) {
      debugPrint('Error saving dashboard configurations: $e');
    }
  }
}
