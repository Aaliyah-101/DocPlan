import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/appointment_service.dart';
import 'view_appointments_screen.dart';
import 'radius_settings_screen.dart';
import 'patient_records_screen.dart';
import '../../widgets/gradient_background.dart';
import '../../models/emergency_model.dart';
import '../settings/settings_screen.dart';
import '../../widgets/notification_bell.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final AuthService _authService = AuthService();
  final AppointmentService _appointmentService = AppointmentService();
  static const List<double> _offsets = [0, 24, 48];

  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    _DoctorHomeContent(),
    DoctorViewAppointmentsScreen(),
    PatientRecordsScreen(),
    RadiusSettingsScreen(),
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
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        backgroundColor: AppColors.primary,
        actions: const [
          NotificationBell(), // 🔔 Bell with badge
        ],
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5, // 👈 Reduces width to 70% of screen
        child: Drawer(
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
                    Text("Doctor Menu", style: TextStyle(color: Colors.white, fontSize: 20)),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: AppColors.primary),
                title: const Text('Home'),
                selected: _selectedIndex == 0,
                selectedTileColor: AppColors.primary.withOpacity(0.1),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = 0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt, color: AppColors.primary),
                title: const Text('Appointments'),
                selected: _selectedIndex == 1,
                selectedTileColor: AppColors.primary.withOpacity(0.1),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = 1);
                },
              ),
              NavigationRailDestination(
                icon: Icon(Icons.medical_services),
                label: Text('Records'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.my_location),
                label: Text('Set Radius'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          // Add the selected page to the right of the NavigationRail
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}

class _DoctorHomeContent extends StatelessWidget {
  const _DoctorHomeContent();

  Future<void> _releaseAllFrozenAppointments(BuildContext context) async {
    final user = AuthService().currentUser;
    if (user == null) return;
    await AppointmentService().releaseAllFrozenAppointments(user.uid);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All frozen appointments have been released.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;
    return GradientBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text('Hello,', style: Theme.of(context).textTheme.titleMedium),
            FutureBuilder(
              future: authService.getUserData(user?.uid ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 24,
                    child: LinearProgressIndicator(),
                  );
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Text('Doctor');
                }
                return Text(
                  (snapshot.data as dynamic).name ?? 'Doctor',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
            const SizedBox(height: 20),
            // Status Banner with real-time updates
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctors')
                  .doc(user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 50,
                    child: LinearProgressIndicator(),
                  );
                }
                final doctorData =
                    snapshot.data!.data() as Map<String, dynamic>?;
                final specialty = doctorData?['specialty'] ?? 'General';
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status: Available',
                              style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Specialty: $specialty',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Emergency List Section
            Builder(
              builder: (context) {
                final user = authService.currentUser;
                if (user == null) {
                  return const SizedBox();
                }
                return StreamBuilder<List<EmergencyModel>>(
                  stream: AppointmentService().getActiveEmergencies(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 50,
                        child: LinearProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: const Text(
                          'No active emergencies.',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                    final emergencies = snapshot.data!
                        .where((e) => e.doctorId == user.uid)
                        .toList();
                    if (emergencies.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: const Text(
                          'No active emergencies.',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Active Emergencies',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...emergencies.map(
                          (e) => Card(
                            color: AppColors.emergencyLight,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reason: ${e.reason}',
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Time: ${e.timestamp}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Affected Appointments: ${e.affectedAppointments.length}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.check),
                                    label: const Text('Mark as Resolved'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                      foregroundColor: AppColors.textWhite,
                                    ),
                                    onPressed: () async {
                                      await AppointmentService()
                                          .resolveEmergency(user.uid);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Release all frozen appointments button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text(
                              'Release All Frozen Appointments',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textWhite,
                            ),
                            onPressed: () =>
                                _releaseAllFrozenAppointments(context),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            // No dashboard grid/buttons here
          ],
        ),
      ),
    );
  }
}

// Placeholder screen for doctor availability management
class DoctorAvailabilityScreen extends StatelessWidget {
  const DoctorAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Availability'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: const Center(child: Text('Availability management screen')),
    );
  }
}
