import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/patient/patient_dashboard_screen.dart';
import 'screens/doctor/doctor_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/doctor/emergency_response_screen.dart';

import 'services/firebase_messaging_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flnPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flnPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (response) {
      if (response.payload != null && response.payload == 'emergency_alert') {
        // NOTE: You must send an appointmentId in arguments when using pushNamed
        // This is a fallback, but normally handled in FirebaseMessagingService
        navigatorKey.currentState?.pushNamed('/emergency_response', arguments: 'fallback-id');
      }
    },
  );

  // Initialize Firebase messaging
  await FirebaseMessagingService.initializeFCM(flnPlugin, navigatorKey);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
          onGenerateRoute: (settings) {
            if (settings.name == '/emergency_response') {
              final appointmentId = settings.arguments as String?;
              if (appointmentId != null) {
                return MaterialPageRoute(
                  builder: (_) => EmergencyResponseScreen(appointmentId: appointmentId),
                );
              } else {
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(
                    body: Center(child: Text('❗ Missing appointment ID')),
                  ),
                );
              }
            }

            return null; // fallback to default
          },
        );
      },
    );
  }
}
