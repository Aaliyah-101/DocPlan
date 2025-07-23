import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/chat_screen.dart';

import 'constants/app_theme.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/patient/patient_dashboard_screen.dart';
import 'screens/doctor/doctor_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
    ChangeNotifierProvider(create: (_) => themeNotifier, child: const MyApp()),
  );

  // Handle notification tap if app was launched by notification
  _checkInitialMessage();
}

Future<void> _initFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle foreground messages if needed
    // print("Foreground notification:  [38;5;2m${message.notification?.title} [0m");
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _handleNotificationNavigation(message.data);
  });
}

Future<void> _checkInitialMessage() async {
  RemoteMessage? initialMessage = await FirebaseMessaging.instance
      .getInitialMessage();
  if (initialMessage != null) {
    _handleNotificationNavigation(initialMessage.data);
  }
}

void _handleNotificationNavigation(Map<String, dynamic> data) async {
  if (data['type'] == 'chat_message') {
    final String senderId = data['senderId'];
    final String senderName = data['senderName'] ?? 'User';
    final String receiverId = data['receiverId'];
    // Get current user ID
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    final String currentUserId = currentUser.uid;
    final String otherUserId = currentUserId == senderId
        ? receiverId
        : senderId;
    final String otherUserName = currentUserId == senderId
        ? (data['receiverName'] ?? 'User')
        : senderName;
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          currentUserId: currentUserId,
          otherUserId: otherUserId,
          otherUserName: otherUserName,
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
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
