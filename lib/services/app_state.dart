import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  bool _isListeningForTrigger = false;
  bool _isLocationEnabled = false;
  bool _isAlertActive = false;

  bool get isListeningForTrigger => _isListeningForTrigger;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get isAlertActive => _isAlertActive;

  Future<void> toggleListening() async {
    _isListeningForTrigger = !_isListeningForTrigger;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('listening_enabled', _isListeningForTrigger);
    notifyListeners();
  }

  Future<void> toggleLocation() async {
    _isLocationEnabled = !_isLocationEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_enabled', _isLocationEnabled);
    notifyListeners();
  }

  void activateAlert() {
    _isAlertActive = true;
    notifyListeners();
  }

  void deactivateAlert() {
    _isAlertActive = false;
    notifyListeners();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isListeningForTrigger = prefs.getBool('listening_enabled') ?? false;
    _isLocationEnabled = prefs.getBool('location_enabled') ?? false;
    notifyListeners();
  }
}
