import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/appointment_service.dart';
import 'view_appointments_screen.dart';
import 'radius_settings_screen.dart';
import 'patient_records_screen.dart';
import 'doctor_emergency_dialog.dart';
import '../../widgets/gradient_background.dart';
import '../../models/emergency_model.dart';
import '../settings/settings_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
                icon: Icon(Icons.list_alt),
                label: Text('Appointments'),
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
          const VerticalDivider(thickness: 1, width: 1),
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
    final List<String> imagePaths = [
      'lib/images/p2.jpg',
      'lib/images/p3.jpg',
      'lib/images/p4.jpg',
      'lib/images/p5.jpg',
      'lib/images/p6.jpg',
      'lib/images/p7.jpg',
      'lib/images/p8.jpg',
    ];
    final ValueNotifier<int> currentNotifier = ValueNotifier<int>(0);
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
            const SizedBox(height: 16),
            // Carousel (smaller height for mobile)
            ValueListenableBuilder<int>(
              valueListenable: currentNotifier,
              builder: (context, current, _) {
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    CarouselSlider(
                      items: imagePaths.map((path) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            path,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 180,
                          ),
                        );
                      }).toList(),
                      options: CarouselOptions(
                        height: 180,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        autoPlayAnimationDuration: const Duration(milliseconds: 800),
                        enlargeCenterPage: false,
                        viewportFraction: 1.0,
                        onPageChanged: (index, reason) {
                          currentNotifier.value = index;
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: imagePaths.asMap().entries.map((entry) {
                          return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: current == entry.key
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade300,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
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

class EmergencyAlertsWidget extends StatefulWidget {
  const EmergencyAlertsWidget({Key? key}) : super(key: key);

  @override
  State<EmergencyAlertsWidget> createState() => _EmergencyAlertsWidgetState();
}

class _EmergencyAlertsWidgetState extends State<EmergencyAlertsWidget> {
  @override
  void initState() {
    super.initState();
    // Subscribe to 'doctors' topic for FCM
    FirebaseMessaging.instance.subscribeToTopic('doctors');
  }

  Future<void> _markAsResolved(String emergencyId) async {
    await FirebaseFirestore.instance
        .collection('emergencies')
        .doc(emergencyId)
        .update({'status': 'resolved'});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('emergencies')
          .where('status', isEqualTo: 'active')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Text('No active emergencies.');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Active Emergencies:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                color: Colors.red[50],
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text('Patient: ${data['patientName']} (${data['patientId']})'),
                  subtitle: Text('Message: ${data['message']}'),
                  trailing: ElevatedButton(
                    onPressed: () => _markAsResolved(data['id']),
                    child: const Text('Mark as Resolved'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              );
            }),
          ],
        );
      },
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
