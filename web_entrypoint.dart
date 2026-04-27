import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import './lib/main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If Firebase initialization fails on web, continue without it
    // This allows the app to run in demo mode
    debugPrint('Firebase initialization failed: $e');
  }
  runApp(const MyApp());
}
