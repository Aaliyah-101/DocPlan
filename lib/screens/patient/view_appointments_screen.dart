import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../services/appointment_service.dart';
import '../../services/auth_service.dart';
import '../../models/appointment_model.dart';
import '../../widgets/gradient_background.dart';

class ViewAppointmentsScreen extends StatelessWidget {
  const ViewAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
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
        child: user == null
            ? const Center(child: Text('Not logged in'))
            : StreamBuilder<List<AppointmentModel>>(
                stream: AppointmentService().getUserAppointments(user.uid, 'patient'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No appointments found.'));
                  }
                  final now = DateTime.now();
                  final upcoming = snapshot.data!
                      .where((a) => a.dateTime.isAfter(now) && a.status == 'upcoming')
                      .toList();
                  final past = snapshot.data!
                      .where((a) => a.dateTime.isBefore(now) || a.status != 'upcoming')
                      .toList();
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (upcoming.isNotEmpty) ...[
                        const Text('Upcoming', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ...upcoming.map((a) => _AppointmentCard(appointment: a)),
                        const SizedBox(height: 24),
                      ],
                      if (past.isNotEmpty) ...[
                        const Text('Past', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ...past.map((a) => _AppointmentCard(appointment: a)),
                      ],
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Doctor: ${appointment.doctorName}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(appointment.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment.status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(DateFormat('EEE, MMM d, yyyy').format(appointment.dateTime)),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(DateFormat('h:mm a').format(appointment.dateTime)),
              ],
            ),
            if (appointment.reason != null && appointment.reason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Reason: ${appointment.reason!}', style: const TextStyle(color: AppColors.textSecondary)),
            ],
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Note: ${appointment.notes!}', style: const TextStyle(color: AppColors.error)),
            ],
            if (appointment.status == 'frozen') ...[
              const SizedBox(height: 12),
              Text(
                'This appointment is temporarily frozen due to a doctor emergency. Please reschedule to a new time.',
                style: const TextStyle(color: AppColors.emergencyDark, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.schedule),
                label: const Text('Reschedule'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textWhite,
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                  );
                  if (picked != null) {
                    final timeOfDay = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (timeOfDay != null) {
                      final newDateTime = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        timeOfDay.hour,
                        timeOfDay.minute,
                      );
                      await AppointmentService().rescheduleAppointment(
                        appointment.id,
                        newDateTime,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Appointment rescheduled!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'upcoming':
        return AppColors.primary;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'rescheduled':
        return AppColors.accent;
      case 'frozen':
        return AppColors.emergencyDark;
      default:
        return AppColors.textSecondary;
    }
  }
} 