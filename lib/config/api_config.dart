import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Base URL configuration based on platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to reach host localhost
      return 'http://10.0.2.2:3000/api';
    }
    if (Platform.isIOS) {
      return 'http://localhost:3000/api';
    }
    // Desktop / other platforms
    return 'http://localhost:3000/api';
  }

  // For real device testing, replace with your PC's local IP
  // Example: static const String deviceBaseUrl = 'http://192.168.1.100:5000/api';
}
