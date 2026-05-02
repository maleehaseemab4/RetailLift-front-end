import 'package:flutter/material.dart';
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
    // Dynamic icon switching not available in current version
    _savePreferences();
    notifyListeners();
  }

  void _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('app_icon', _selectedIcon);
  }
}
