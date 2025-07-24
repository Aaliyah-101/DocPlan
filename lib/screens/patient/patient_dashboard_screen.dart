import 'package:docplan/screens/patient/book_appointment_screen.dart';
import 'package:docplan/screens/patient/view_appointments_screen.dart';
import 'package:docplan/screens/patient/declare_emergency_screen.dart';
import 'package:docplan/screens/patient/medical_records_screen.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/gradient_background.dart';
import 'package:docplan/screens/settings/settings_screen.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    _PatientHomeContent(),
    BookAppointmentScreen(),
    ViewAppointmentsScreen(),
    DeclareEmergencyScreen(),
    MedicalRecordsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            unselectedIconTheme: const IconThemeData(
              color: AppColors.textSecondary,
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add_circle_outline),
                label: Text('Book'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.list_alt),
                label: Text('Appointments'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.emergency),
                label: Text('Emergency'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.medical_services),
                label: Text('Records'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Expanded page content
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}

class _PatientHomeContent extends StatelessWidget {
  const _PatientHomeContent();

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    return GradientBackground(
      child: Container(
        decoration: const BoxDecoration(
          // image: DecorationImage(
          //   image: AssetImage('lib/images/docplan2.jpg'),
          //   fit: BoxFit.cover,
          //   opacity: 0.2,
          // ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Hello,', style: Theme.of(context).textTheme.titleMedium),
              FutureBuilder(
                future: AuthService().getUserData(user?.uid ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 24,
                      child: LinearProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Text('Patient');
                  }
                  return Text(
                    (snapshot.data as dynamic).name ?? 'Patient',
                    style: Theme.of(context).textTheme.headlineMedium,
                  );
                },
              ),
              const SizedBox(height: 40),
              // No dashboard grid/buttons here
            ],
          ),
        ),
      ),
    );
  }
}
