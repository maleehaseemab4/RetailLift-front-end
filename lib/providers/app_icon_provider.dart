import 'package:flutter/material.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppIconProvider with ChangeNotifier {
  String _selectedIcon = 'default';
  final List<String> _icons = ['default', 'icon1', 'icon2'];

  String get selectedIcon => _selectedIcon;
  List<String> get icons => _icons;

  AppIconProvider() {
    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedIcon = prefs.getString('app_icon') ?? 'default';
    notifyListeners();
  }

  void setSelectedIcon(String icon) async {
    _selectedIcon = icon;
    try {
      await FlutterDynamicIcon.setApplicationIconBadgeNumber(0); // Reset badge
      await FlutterDynamicIcon.setAlternateIconName(
        icon == 'default' ? null : icon,
      );
    } catch (e) {
      // Fallback for unsupported platforms
      debugPrint('Dynamic icon not supported: $e');
    }
    _savePreferences();
    notifyListeners();
  }

  void _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('app_icon', _selectedIcon);
  }
}
