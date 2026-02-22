import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

enum AlertType { sound, vibration, silent }

class AlertProvider with ChangeNotifier {
  AlertType _alertType = AlertType.sound;
  double _volume = 50.0;
  String _selectedTone = 'default';
  bool _autoScreenshot = false;

  final List<String> _tones = ['default', 'beep', 'chime', 'alarm'];

  AlertType get alertType => _alertType;
  double get volume => _volume;
  String get selectedTone => _selectedTone;
  bool get autoScreenshot => _autoScreenshot;
  List<String> get tones => _tones;

  AlertProvider() {
    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _alertType = AlertType.values[prefs.getInt('alert_type') ?? 0];
    _volume = prefs.getDouble('alert_volume') ?? 50.0;
    _selectedTone = prefs.getString('alert_tone') ?? 'default';
    _autoScreenshot = prefs.getBool('auto_screenshot') ?? false;
    notifyListeners();
  }

  void setAlertType(AlertType type) {
    _alertType = type;
    _savePreferences();
    notifyListeners();
  }

  void setVolume(double vol) {
    _volume = vol;
    _savePreferences();
    notifyListeners();
  }

  void setSelectedTone(String tone) {
    _selectedTone = tone;
    _savePreferences();
    notifyListeners();
  }

  void setAutoScreenshot(bool value) {
    _autoScreenshot = value;
    _savePreferences();
    notifyListeners();
  }

  void previewTone() async {
    final player = AudioPlayer();
    await player.setVolume(_volume / 100);
    await player.play(AssetSource('sounds/$_selectedTone.mp3'));
  }

  void _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('alert_type', _alertType.index);
    prefs.setDouble('alert_volume', _volume);
    prefs.setString('alert_tone', _selectedTone);
    prefs.setBool('auto_screenshot', _autoScreenshot);
  }

  // Method to trigger alert based on settings
  void triggerAlert(BuildContext context) {
    switch (_alertType) {
      case AlertType.sound:
        previewTone();
        break;
      case AlertType.vibration:
        // Implement vibration if needed
        break;
      case AlertType.silent:
        // Do nothing
        break;
    }
    // If auto screenshot, capture and save
    if (_autoScreenshot) {
      // Assume screenshot logic here
    }
  }
}
