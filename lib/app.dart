import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'constants/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/doctor/doctor_dashboard_screen.dart';
import 'screens/doctor/emergency_response_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/patient/patient_dashboard_screen.dart';
import 'services/firebase_messaging_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flnPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Messaging and Local Notifications
  await FirebaseMessagingService.initializeFCM(flnPlugin, navigatorKey);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Delay execution until widgets are fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final message = FirebaseMessagingService.initialMessage;
      if (message != null) {
        final data = message.data;
        final type = data['type'];
        final appointmentId = data['appointmentId'];

        if (type == 'emergency_alert' && appointmentId != null) {
          navigatorKey.currentState?.pushNamed(
            '/emergency_response',
            arguments: appointmentId,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'DocPlan',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeNotifier.themeMode,
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
                  builder: (_) => EmergencyResponseScreen(
                    appointmentId: appointmentId,
                  ),
                );
              }
            }
            return null;
          },
        );
      },
    );
  }
}
