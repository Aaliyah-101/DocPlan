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


class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final FlutterLocalNotificationsPlugin flnPlugin;

  const MyApp({
    super.key,
    required this.navigatorKey,
    required this.flnPlugin,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) {
        return MaterialApp(
          navigatorKey: widget.navigatorKey,
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
                    appointmentId: appointmentId, // <-- or appointmentId!
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
