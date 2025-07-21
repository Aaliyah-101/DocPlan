import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'app.dart'; // Your app structure (routing, theming)
import 'constants/app_theme.dart';

final FlutterLocalNotificationsPlugin flnPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for web or mobile
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAmTyL5LzrJqmcOhdOpuZqESS438bxkClQ",
        authDomain: "docplan22-87323.firebaseapp.com",
        projectId: "docplan22-87323",
        storageBucket: "docplan22-87323.appspot.com",
        messagingSenderId: "751987947078",
        appId: "1:751987947078:web:4061bced04e0e16fc27c47",
        measurementId: "G-XXXXXXX", // Optional
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // 🌙 Load saved theme
  final themeNotifier = ThemeNotifier();
  await themeNotifier.loadThemeMode();

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeNotifier,
      child: const MyApp(), // ⬅️ Defined in app.dart
    ),
  );
}
