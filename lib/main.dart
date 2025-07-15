import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'constants/app_theme.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/patient/patient_dashboard_screen.dart';
import 'screens/doctor/doctor_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // ✅ Provide Firebase options for web
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAmTyL5LzrJqmcOhdOpuZqESS438bxkClQ",
        authDomain: "docplan22-87323.firebaseapp.com",
        projectId: "docplan22-87323",
        storageBucket: "docplan22-87323.appspot.com",
        messagingSenderId: "751987947078",
        appId: "1:751987947078:web:4061bced04e0e16fc27c47",
        measurementId: "G-XXXXXXX", // Replace with actual if used
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  await _initFirebaseMessaging();

  final themeNotifier = ThemeNotifier();
  await themeNotifier.loadThemeMode();

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeNotifier,
      child: const MyApp(),
    ),
  );
}

Future<void> _initFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle foreground messages if needed
    // print("Foreground notification: ${message.notification?.title}");
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // Handle app launch from notification
    // print("Notification opened: ${message.notification?.title}");
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) {
        return MaterialApp(
          title: 'DocPlan',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeNotifier.themeMode,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/auth': (context) => const AuthScreen(),
            '/doctor_dashboard': (context) => const DoctorDashboardScreen(),
            '/admin_dashboard': (context) => const AdminDashboardScreen(),
            '/patient_dashboard': (context) => const PatientDashboardScreen(),
          },
        );
      },
    );
  }
}
