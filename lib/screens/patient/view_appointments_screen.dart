import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../services/appointment_service.dart';
import '../../services/auth_service.dart';
import '../../models/appointment_model.dart';
import '../../widgets/gradient_background.dart';
import '../../screens/chat_screen.dart';
import '../../services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD
=======
import '../../screens/patient/patient_dashboard_screen.dart';
>>>>>>> AaliyahM

class ViewAppointmentsScreen extends StatelessWidget {
  final bool showGoHomeDialog;
  const ViewAppointmentsScreen({super.key, this.showGoHomeDialog = false});

  void _showGoHomeDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Appointment Booked!'),
          content: const Text('Would you like to go back to the home page or stay on your appointments?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Stay on Appointments'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const PatientDashboardScreen()),
                  (route) => false,
                );
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showGoHomeDialog) {
      _showGoHomeDialog(context);
    }
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
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text('Message Doctor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      currentUserId: appointment.patientId,
                      otherUserId: appointment.doctorId,
                      otherUserName: appointment.doctorName ?? 'Doctor',
                    ),
                  ),
                );
              },
            ),
            // Last message preview
            StreamBuilder(
              stream: ChatService()
                  .streamMessages(appointment.patientId, appointment.doctorId)
                  .map((snapshot) => snapshot.docs.isNotEmpty ? snapshot.docs.last : null),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: LinearProgressIndicator(minHeight: 2),
                  );
                }
                final msg = snapshot.data;
                if (msg == null) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text('No messages yet.', style: TextStyle(color: AppColors.textSecondary)),
                  );
                }
                final text = msg['message'] ?? '';
                final senderId = msg['senderId'] ?? '';
                final ts = msg['timestamp'] != null && msg['timestamp'] is Timestamp
                    ? (msg['timestamp'] as Timestamp).toDate()
                    : null;
                final timeStr = ts != null ? DateFormat('MMM d, h:mm a').format(ts) : '';
                final isMe = senderId == appointment.patientId;
                final senderLabel = isMe ? 'You' : (appointment.doctorName ?? 'Doctor');
                return StreamBuilder<Timestamp?>(
                  stream: ChatService().getLastRead(appointment.patientId, appointment.doctorId, appointment.patientId),
                  builder: (context, readSnapshot) {
                    final lastRead = readSnapshot.data;
                    final isUnread = ts != null && (lastRead == null || ts.isAfter(lastRead.toDate()));
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '$senderLabel: $text',
                              style: TextStyle(
                                color: isUnread ? AppColors.primary : AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (timeStr.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(timeStr, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ]
                        ],
                      ),
                    );
                  },
                );
              },
            ),
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