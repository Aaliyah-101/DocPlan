import 'package:docplan/screens/patient/book_appointment_screen.dart';
import 'package:docplan/screens/patient/view_appointments_screen.dart';
import 'package:docplan/screens/patient/declare_emergency_screen.dart';
import 'package:docplan/screens/patient/medical_records_screen.dart';
import 'package:docplan/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/gradient_background.dart';

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

  static const List<String> _menuTitles = [
    'Home',
    'Book Appointment',
    'View Appointments',
    'Declare Emergency',
    'Medical Records',
    'Settings',
  ];

  static const List<IconData> _menuIcons = [
    Icons.home,
    Icons.add_circle_outline,
    Icons.list_alt,
    Icons.emergency,
    Icons.medical_services,
    Icons.settings,
  ];

  void _onMenuSelected(int index) {
    Navigator.pop(context); // Close the drawer
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(_menuTitles[_selectedIndex]),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.account_circle, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text("Menu", style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            ...List.generate(
              _menuTitles.length,
                  (index) => ListTile(
                leading: Icon(_menuIcons[index], color: AppColors.primary),
                title: Text(_menuTitles[index], style: const TextStyle(fontSize: 16)),
                selected: _selectedIndex == index,
                selectedTileColor: AppColors.primary.withOpacity(0.1),
                onTap: () => _onMenuSelected(index),
              ),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
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
          image: DecorationImage(
            image: AssetImage('lib/images/docplan2.jpg'),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
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
            ],
          ),
        ),
      ),
    );
  }
}
