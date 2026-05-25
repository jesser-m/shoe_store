import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String _apiIpKey = 'api_ip';
  static String? _savedApiBaseUrl;

  /// Call once at app startup.
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ip = prefs.getString(_apiIpKey);
      final trimmed = ip?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        _savedApiBaseUrl = 'http://$trimmed:3000/api';
      }
    } catch (_) {
      // Fallback to default URLs.
    }
  }

  /// Base URL configuration based on platform.
  static String get baseUrl {
    // Saved (phone local) URL has priority over everything.
    if (_savedApiBaseUrl != null && _savedApiBaseUrl!.isNotEmpty) {
      return _savedApiBaseUrl!;
    }

    // IP locale détectée du PC (remplace-la si ton IP change)
    const String lanUrl = 'http://10.25.0.157:3000/api';

    return lanUrl;
  }
}
