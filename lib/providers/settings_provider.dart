import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _darkModeKey = 'darkMode';
  static const String _localeKey = 'locale';
  static const String _apiIpKey = 'api_ip';

  bool _isDarkMode = false;
  Locale _locale = const Locale('fr', 'FR');
  String _apiIp = '';

  bool get isDarkMode => _isDarkMode;
  Locale get locale => _locale;
  String get apiIp => _apiIp;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
      final savedLang = prefs.getString(_localeKey);
      if (savedLang != null) {
        _locale = Locale(savedLang);
      }
      _apiIp = (prefs.getString(_apiIpKey) ?? '').trim();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, _isDarkMode);
    } catch (e) {
      debugPrint('Error saving dark mode: $e');
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
    notifyListeners();
  }

  Future<void> setApiIp(String ip) async {
    _apiIp = ip.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_apiIpKey, _apiIp);
    } catch (e) {
      debugPrint('Error saving api ip: $e');
    }
    notifyListeners();
  }
}
