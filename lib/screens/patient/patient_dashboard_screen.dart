import 'package:docplan/screens/patient/book_appointment_screen.dart';
import 'package:docplan/screens/patient/view_appointments_screen.dart';
import 'package:docplan/screens/patient/declare_emergency_screen.dart';
import 'package:docplan/screens/patient/medical_records_screen.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/gradient_background.dart';

class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with reduced opacity
          Opacity(
            opacity: 0.3,
            child: Image.asset(
              'assets\images\img_4.png',
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
                              Icons.person,
                              color: AppColors.textWhite,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // User greeting (keeping existing text)
                      Text(
                        'Hello,',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textWhite,
                        ),
                      ),
                      FutureBuilder(
                        future: AuthService().getUserData(user?.uid ?? ''),
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
                              'Patient',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textWhite,
                              ),
                            );
                          }
                          return Text(
                            (snapshot.data as dynamic).name ?? 'Patient',
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
                                  text: 'View Appointments',
                                  icon: Icons.list_alt,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ViewAppointmentsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                
                                // Book Appointment
                                _buildServiceButton(
                                  context,
                                  text: 'Book Appointment',
                                  icon: Icons.calendar_today,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const BookAppointmentScreen(),
                                      ),
                                    );
                                  },
                                ),
                                
                                // Emergency Declaration
                                _buildServiceButton(
                                  context,
                                  text: 'Declare Emergency',
                                  icon: Icons.emergency,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const DeclareEmergencyScreen(),
                                      ),
                                    );
                                  },
                                ),
                                
                                // Medical Records
                                _buildServiceButton(
                                  context,
                                  text: 'Medical Records',
                                  icon: Icons.medical_services,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const MedicalRecordsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                
                                // Logout (additional button to fill the grid)
                                _buildServiceButton(
                                  context,
                                  text: 'Logout',
                                  icon: Icons.logout,
                                  onTap: () async {
                                    await AuthService().signOut();
                                    if (context.mounted) {
                                      Navigator.pushReplacementNamed(context, '/auth');
                                    }
                                  },
                                ),
                                
                                // Settings (additional button to fill the grid)
                                _buildServiceButton(
                                  context,
                                  text: 'Settings',
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
    required String text,
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
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.primary,
            ),
            Text(text, style: const TextStyle(fontSize: 12, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
