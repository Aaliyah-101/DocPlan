import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/appointment_service.dart';
import '../../models/appointment_model.dart';
import '../../models/emergency_model.dart';
import '../../widgets/gradient_background.dart';
import '../../screens/patient/patient_dashboard_screen.dart';

class DeclareEmergencyScreen extends StatefulWidget {
  const DeclareEmergencyScreen({super.key});

  @override
  State<DeclareEmergencyScreen> createState() => _DeclareEmergencyScreenState();
}

class _DeclareEmergencyScreenState extends State<DeclareEmergencyScreen> {
  final AuthService _authService = AuthService();
  final AppointmentService _appointmentService = AppointmentService();

  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();

  final List<String> _emergencyTypes = [
    'Heart Attack',
    'Stroke',
    'Diabetic Coma',
    'Seizures',
    'Asthma Attack',
    'Severe Allergy',
    'Unconscious Patient',
    'Road Accidents',
    'Fall Injuries',
    'Gunshot Wound',
    'Stab Wound',
    'Burns',
    'Blunt Trauma',
    'Crush Injury',
    'High Fever & Convulsions',
    'Severe Dehydration',
    'Poisoning',
    'Choking',
    'Child Trauma',
    'Other',
  ];

  final List<String> _severityLevels = ['Low', 'Medium', 'High', 'Critical'];

  String _selectedEmergencyType = 'Heart Attack';
  String _selectedSeverity = 'Medium';
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _declareEmergency() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('User not logged in');

      final userModel = await _authService.getUserData(user.uid);
      if (userModel == null) throw Exception('User data not found');

      // Find nearest available doctor
      final availableDoctors = await _findNearestAvailableDoctor();

      if (availableDoctors.isEmpty) {
        setState(() {
          _error =
              'No doctors available for emergency. Please contact emergency services directly.';
        });
        return;
      }

      // Create emergency appointment
      final appointmentId = FirebaseFirestore.instance
          .collection('appointments')
          .doc()
          .id;

      final appointment = AppointmentModel(
        id: appointmentId,
        doctorId: availableDoctors.first['id'],
        patientId: user.uid,
        doctorName: availableDoctors.first['name'],
        patientName: userModel.name,
        dateTime: DateTime.now(),
        status: 'pending',
        reason:
            'EMERGENCY: $_selectedEmergencyType - ${_symptomsController.text.trim()}',
        notes: 'Severity: $_selectedSeverity',
        createdAt: DateTime.now(),
        location: null,
        isEmergency: true,
        specialty: availableDoctors.first['specialty'],
      );
      await _appointmentService.createAppointment(appointment);
      // Create emergency record for doctor's dashboard
      final emergencyId = FirebaseFirestore.instance
          .collection('emergencies')
          .doc()
          .id;
      final emergency = EmergencyModel(
        id: emergencyId,
        doctorId: availableDoctors.first['id'],
        doctorName: availableDoctors.first['name'],
        reason:
            'Patient Emergency: $_selectedEmergencyType - ${_symptomsController.text.trim()}',
        timestamp: DateTime.now(),
        status: 'active',
        affectedAppointments: [appointmentId],
      );
      await _appointmentService.declareEmergency(emergency);
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const PatientDashboardScreen(),
          ),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Emergency request sent successfully! A doctor will contact you shortly.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _findNearestAvailableDoctor() async {
    final Map<String, String> specialistToEmergency = {
      'Cardiologist': 'Heart Attack',
      'Endocrinologist': 'Diabetic Coma',
      'Gastroenterologist': 'Severe Dehydration',
      'Pulmonologist': 'Asthma Attack',
      'Nephrologist': 'Stroke',
      'Hematologist': 'Seizures',
      'Neurosurgeon': 'Unconscious Patient',
      'Cardiothoracic Surgeon': 'Gunshot Wound',
      'Plastic Surgeon': 'Burns',
      'Dermatologist': 'Blunt Trauma',
      'Oncologist': 'High Fever & Convulsions',
      'Radiologist': 'Fall Injuries',
      'Pathologist': 'Poisoning',
      'Rheumatologist': 'Crush Injury',
      'Ophthalmologist': 'Choking',
      'Psychiatrist': 'Other',
      'Urologist': 'Stab Wound',
      'Trauma Surgeon': 'Road Accidents',
      'Allergist': 'Severe Allergy',
      'Toxicologist': 'Child Trauma',
    };

    final Map<String, String> emergencyToSpecialist = {
      for (var entry in specialistToEmergency.entries) entry.value: entry.key,
    };

    final matchedSpecialty = emergencyToSpecialist[_selectedEmergencyType];
    if (matchedSpecialty == null) {
      setState(() => _error = 'No specialty mapped to this emergency type.');
      return [];
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('doctors')
        .where('status', isEqualTo: 'available')
        .where('specialty', isEqualTo: matchedSpecialty)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      setState(
        () => _error =
            'No available doctors for "$matchedSpecialty" at the moment.',
      );
      return [];
    }

    final doc = snapshot.docs.first;
    final data = doc.data();

    return [
      {
        'id': doc.id,
        'name': data['name'] ?? '',
        'specialty': data['specialty'] ?? '',
        'fcmToken': data['fcmToken'],
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Emergency Appointment',
          style: TextStyle(
            color: AppColors.docplanBlue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      backgroundColor: AppColors.backgroundLight,
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, color: AppColors.error, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This is for emergency situations only. For life-threatening emergencies, call emergency services immediately.',
                              style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Type of Emergency',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedEmergencyType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        icon: Icon(
                          Icons.local_hospital,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      items: _emergencyTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedEmergencyType = value!),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Severity Level',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedSeverity,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        icon: Icon(
                          Icons.priority_high,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      items: _severityLevels
                          .map(
                            (severity) => DropdownMenuItem(
                              value: severity,
                              child: Text(severity),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedSeverity = value!),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _symptomsController,
                      decoration: const InputDecoration(
                        labelText: 'Describe your symptoms',
                      ),
                      maxLines: 3,
                      validator: (value) => value == null || value.length < 10
                          ? 'Please provide more detailed symptoms'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _declareEmergency,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.textWhite,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.textWhite,
                              )
                            : const Text('Send Emergency Request'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
