import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../services/appointment_service.dart';
import '../../services/auth_service.dart';
import '../../models/appointment_model.dart';
import '../../widgets/gradient_background.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  final AuthService _authService = AuthService();

  // ignore: unused_field
  String? _selectedDoctorId;
  // ignore: unused_field
  String? _selectedDoctorName;
  String? _selectedSpecialty;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  bool _isLoading = false;
  String? _error;
  String? _reason;

  // Doctor specialties
  final List<String> _specialties = [
    'Cardiologist',
    'Endocrinologist',
    'Gastroenterologist',
    'Pulmonologist',
    'Nephrologist',
    'Hematologist',
    'Neurosurgeon',
    'Cardiothoracic Surgeon',
    'Plastic Surgeon',
    'Dermatologist',
    'Oncologist',
    'Radiologist',
    'Pathologist',
    'Rheumatologist',
    'Ophthalmologist',
    'Psychiatrist',
    'Urologist',
    'Trauma Surgeon',
    'Allergist',
    'Toxicologist',
  ];

  // Days of the week
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DocPlan',
          style: TextStyle(
            color: AppColors.docplanBlue,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      backgroundColor: AppColors.backgroundLight,
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Specialty Selection
                Text(
                  'Select Specialty',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.textSecondary),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedSpecialty,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.medical_services,
                        color: AppColors.textSecondary,
                      ),
                      hintText: 'Select Specialty',
                    ),
                    items: _specialties.map((specialty) {
                      return DropdownMenuItem(
                        value: specialty,
                        child: Text(specialty),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSpecialty = value;
                        _selectedDoctorId = null;
                        _selectedDoctorName = null;
                        _selectedTimeSlot = null;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Doctor selection removed; doctor will be auto-assigned

                // Date Selection
                Text(
                  'Select Date',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 60)),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                        _selectedTimeSlot = null;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.textSecondary),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate == null
                              ? 'Choose a date'
                              : DateFormat(
                                  'EEE, MMM d, yyyy',
                                ).format(_selectedDate!),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Time Slot Selection (based on doctor availability)
                if (_selectedSpecialty != null && _selectedDate != null) ...[
                  Text(
                    'Select Time Slot',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _appointmentService
                        .getAvailableDoctorsBySpecialty(_selectedSpecialty!)
                        .first,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LinearProgressIndicator();
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text(
                          'No doctors available for this specialty.',
                        );
                      }
                      final doctors = snapshot.data!;
                      // Gather all available slots for all doctors for the selected day
                      final dayName = _daysOfWeek[_selectedDate!.weekday - 1];
                      final Set<String> allSlots = {};
                      for (final doc in doctors) {
                        final availability =
                            doc['availability'] as Map<String, dynamic>?;
                        if (availability != null &&
                            availability[dayName] != null) {
                          for (final slot in (availability[dayName] as List)) {
                            allSlots.add(slot);
                          }
                        }
                      }
                      if (allSlots.isEmpty) {
                        return const Text(
                          'No available time slots for this day.',
                        );
                      }
                      final sortedSlots = allSlots.toList()..sort();
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: sortedSlots.map((timeSlot) {
                          bool isSelected = _selectedTimeSlot == timeSlot;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTimeSlot = timeSlot;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              child: Text(
                                timeSlot,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.textWhite
                                      : AppColors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Reason for Appointment
                Text(
                  'Reason for Appointment',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'Please describe your reason for the appointment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                  ),
                  onChanged: (value) {
                    _reason = value;
                  },
                ),
                const SizedBox(height: 32),

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
                    onPressed: _isLoading ? null : _bookAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textWhite,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.textWhite,
                          )
                        : const Text('Book Appointment'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _bookAppointment() async {
    setState(() {
      _error = null;
    });
    if (_selectedSpecialty == null ||
        _selectedDate == null ||
        _selectedTimeSlot == null) {
      setState(() {
        _error = 'Please select specialty, date, and time slot.';
      });
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('User not logged in');
      final userModel = await _authService.getUserData(user.uid);
      if (userModel == null) throw Exception('User data not found');

      // Parse time slot (e.g., "09:00" -> hour: 9, minute: 0)
      final timeParts = _selectedTimeSlot!.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final appointmentDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        hour,
        minute,
      );

      // Find all available doctors for the specialty
      final doctorsSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .where('status', isEqualTo: 'available')
          .where('specialty', isEqualTo: _selectedSpecialty)
          .get();
      final doctors = doctorsSnapshot.docs;
      if (doctors.isEmpty) {
        throw Exception('No available doctors for this specialty.');
      }

      // For each doctor, count their appointments at this date/time
      String? chosenDoctorId;
      String? chosenDoctorName;
      int minAppointments = 999999;
      for (final doc in doctors) {
        final docId = doc.id;
        final docName = doc['name'] ?? '';
        final appointmentsSnapshot = await FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorId', isEqualTo: docId)
            .where('dateTime', isEqualTo: appointmentDateTime.toIso8601String())
            .get();
        final count = appointmentsSnapshot.docs.length;
        if (count < minAppointments) {
          minAppointments = count;
          chosenDoctorId = docId;
          chosenDoctorName = docName;
        }
      }
      if (chosenDoctorId == null) {
        throw Exception('No available doctor for the selected time slot.');
      }

      final appointmentId = FirebaseFirestore.instance
          .collection('appointments')
          .doc()
          .id;
      final appointment = AppointmentModel(
        id: appointmentId,
        doctorId: chosenDoctorId,
        patientId: user.uid,
        doctorName: chosenDoctorName ?? '',
        patientName: userModel.name,
        dateTime: appointmentDateTime,
        status: 'upcoming',
        reason: _reason,
        notes: null,
        createdAt: DateTime.now(),
        location: null,
        isEmergency: false,
        specialty: _selectedSpecialty,
      );
      await _appointmentService.createAppointment(appointment);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Appointment booked with Dr. ${chosenDoctorName ?? ''}!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
