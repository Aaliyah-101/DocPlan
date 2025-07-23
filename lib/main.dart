import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'app.dart';
import 'constants/app_theme.dart';
import 'controllers/reminder_worker.dart';
import 'services/firebase_messaging_service.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flnPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase initialization
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

    // ✅ Initialize WorkManager
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    Workmanager().registerPeriodicTask(
      "reminder_task",
      "check_reminders",
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(seconds: 10),
    );
  }

  // ✅ Initialize FCM and notifications
  await FirebaseMessagingService.initializeFCM(flnPlugin, navigatorKey);

  // ✅ Handle initial notification if app was opened via notification
  final initialMessage = FirebaseMessagingService.initialMessage;
  if (initialMessage != null) {
    FirebaseMessagingService.handleInitialMessage(initialMessage.data, navigatorKey);
  }

  // ✅ Theme
  final themeNotifier = ThemeNotifier();
  await themeNotifier.loadThemeMode();

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeNotifier,
      child: MyApp(
        navigatorKey: navigatorKey,
        flnPlugin: flnPlugin,
      ),
    ),
  );
}
