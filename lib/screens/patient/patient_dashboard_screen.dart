import 'package:docplan/screens/patient/book_appointment_screen.dart';
import 'package:docplan/screens/patient/view_appointments_screen.dart';
import 'package:docplan/screens/patient/declare_emergency_screen.dart';
import 'package:docplan/screens/patient/medical_records_screen.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/gradient_background.dart';
import 'package:docplan/screens/settings/settings_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hello message and user name at the top
              FutureBuilder(
                future: AuthService().getUserData(user?.uid ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 24, child: LinearProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Text('Hello, Patient', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold));
                  }
                  final userModel = snapshot.data as dynamic;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Hello, ${userModel.name ?? 'Patient'}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (userModel.role == 'doctor') ...[
                        Card(
                          margin: const EdgeInsets.only(bottom: 16, left: 0, right: 0),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (userModel.profilePictureUrl != null && userModel.profilePictureUrl.isNotEmpty)
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(userModel.profilePictureUrl),
                                        radius: 28,
                                      )
                                    else
                                      const CircleAvatar(
                                        radius: 28,
                                        child: Icon(Icons.person, size: 32),
                                      ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(userModel.name ?? '', style: Theme.of(context).textTheme.titleMedium),
                                          if (userModel.specialty != null && userModel.specialty.isNotEmpty)
                                            Text(userModel.specialty, style: const TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (userModel.bio != null && userModel.bio.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(userModel.bio, style: const TextStyle(fontSize: 15)),
                                ],
                                if (userModel.rating != null) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 20),
                                      const SizedBox(width: 4),
                                      Text(userModel.rating.toStringAsFixed(1)),
                                      if (userModel.totalRatings != null) ...[
                                        const SizedBox(width: 8),
                                        Text('(${userModel.totalRatings} ratings)', style: const TextStyle(color: Colors.grey)),
                                      ],
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (userModel.role == 'patient') ...[
                        Card(
                          margin: const EdgeInsets.only(bottom: 16, left: 0, right: 0),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (userModel.profilePictureUrl != null && userModel.profilePictureUrl.isNotEmpty)
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(userModel.profilePictureUrl),
                                        radius: 28,
                                      )
                                    else
                                      const CircleAvatar(
                                        radius: 28,
                                        child: Icon(Icons.person, size: 32),
                                      ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(userModel.name ?? '', style: Theme.of(context).textTheme.titleMedium),
                                          if (userModel.email != null && userModel.email.isNotEmpty)
                                            Text(userModel.email, style: const TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (userModel.phoneNumber != null && userModel.phoneNumber.isNotEmpty)
                                  Text('Phone: ${userModel.phoneNumber}', style: const TextStyle(fontSize: 15)),
                                if (userModel.country != null && userModel.country.isNotEmpty)
                                  Text('Country: ${userModel.country}', style: const TextStyle(fontSize: 15)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
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
            ],
          ),
        ),
      ),
    );
  }
}
