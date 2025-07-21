import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/appointment_service.dart';
import 'view_appointments_screen.dart';
import 'radius_settings_screen.dart';
import 'patient_records_screen.dart';
import 'doctor_emergency_dialog.dart';
import '../../widgets/gradient_background.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final AuthService _authService = AuthService();
  // ignore: unused_field
  final AppointmentService _appointmentService = AppointmentService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with reduced opacity
          Opacity(
            opacity: 0.5,
            child: Image.asset(
              'assets/images/26087.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Semi-transparent overlay for better text visibility
          Container(
            color: Colors.black.withOpacity(0.2),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header Section (Teal Background with transparency)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.9),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row with welcome text and avatar
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'WELCOME.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textWhite,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                          // Avatar circle
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.medical_services,
                              color: AppColors.textWhite,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // User greeting
                      Text(
                        'Hello,',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textWhite,
                        ),
                      ),
                      FutureBuilder(
                        future: _authService.getUserData(user?.uid ?? ''),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              height: 24,
                              child: LinearProgressIndicator(
                                backgroundColor: AppColors.textWhite,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                              ),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data == null) {
                            return const Text(
                              'Doctor',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textWhite,
                              ),
                            );
                          }
                          return Text(
                            (snapshot.data as dynamic).name ?? 'Doctor',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // Main Content Area (White Card with shadow)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // Service Grid
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              children: [
                                // View Appointments
                                _buildServiceButton(
                                  context,
                                  icon: Icons.list_alt,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const DoctorViewAppointmentsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                
                                // Emergency Toggle
                                _buildServiceButton(
                                  context,
                                  icon: Icons.emergency,
                                  onTap: () {
                                    _showEmergencyDialog(context);
                                  },
                                ),
                                
                                // Set Availability
                                _buildServiceButton(
                                  context,
                                  icon: Icons.schedule,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const RadiusSettingsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                
                                // Patient Records
                                _buildServiceButton(
                                  context,
                                  icon: Icons.medical_services,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const PatientRecordsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                
                                // Logout
                                _buildServiceButton(
                                  context,
                                  icon: Icons.logout,
                                  onTap: () async {
                                    await AuthService().signOut();
                                    if (context.mounted) {
                                      Navigator.pushReplacementNamed(context, '/auth');
                                    }
                                  },
                                ),
                                
                                // Settings
                                _buildServiceButton(
                                  context,
                                  icon: Icons.settings,
                                  onTap: () {
                                    // Add settings functionality here
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          // Pagination dots
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.textSecondary.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.textSecondary.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 32,
          color: AppColors.primary,
        ),
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DoctorEmergencyDialog(),
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
