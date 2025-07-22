import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart'; // Your app structure (routing, theming)
import 'constants/app_theme.dart';
import '/../controllers/reminder_worker.dart'; // <-- Add this

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAmTyL5LzrJqmcOhdOpuZqESS438bxkClQ",
        authDomain: "docplan22-87323.firebaseapp.com",
        projectId: "docplan22-87323",
        storageBucket: "docplan22-87323.appspot.com",
        messagingSenderId: "751987947078",
        appId: "1:751987947078:web:4061bced04e0e16fc27c47",
        measurementId: "G-XXXXXXX",
      ),
    );
  } else {
    await Firebase.initializeApp();

    // ⏰ Initialize Workmanager for background reminders
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

    // 🔁 Periodic task to check for reminders every 15 minutes
    Workmanager().registerPeriodicTask(
      "reminder_task", // Unique task name
      "check_reminders", // Callback task name
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(seconds: 10), // Optional delay after app start
    );
  }

  // Load saved theme mode
  final themeNotifier = ThemeNotifier();
  await themeNotifier.loadThemeMode();

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeNotifier,
      child: const MyApp(),
    ),
  );
}
