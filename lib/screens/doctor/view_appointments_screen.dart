import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: unused_import
import 'package:geolocator/geolocator.dart';
import '../../constants/app_colors.dart';
import '../../services/appointment_service.dart';
import '../../services/auth_service.dart';
import '../../models/appointment_model.dart';
import '../../widgets/gradient_background.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../screens/chat_screen.dart';
import '../../services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_location_map_screen.dart';

class DoctorViewAppointmentsScreen extends StatelessWidget {
  const DoctorViewAppointmentsScreen({super.key});

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
                stream: AppointmentService().getUserAppointments(
                  user.uid,
                  'doctor',
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No appointments found.'));
                  }
                  final now = DateTime.now();
                  final upcoming = snapshot.data!
                      .where(
                        (a) => a.dateTime.isAfter(now) && a.status == 'upcoming',
                      )
                      .toList();
                  final past = snapshot.data!
                      .where(
                        (a) => a.dateTime.isBefore(now) || a.status != 'upcoming',
                      )
                      .toList();
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (upcoming.isNotEmpty) ...[
                        const Text(
                          'Upcoming',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...upcoming.map(
                          (a) => _DoctorAppointmentCard(appointment: a),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (past.isNotEmpty) ...[
                        const Text(
                          'Past',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...past.map(
                          (a) => _DoctorAppointmentCard(appointment: a),
                        ),
                      ],
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _DoctorAppointmentCard extends StatefulWidget {
  final AppointmentModel appointment;
  const _DoctorAppointmentCard({required this.appointment});

  @override
  State<_DoctorAppointmentCard> createState() => _DoctorAppointmentCardState();
}

class _DoctorAppointmentCardState extends State<_DoctorAppointmentCard> {
  bool? _inRadius;
  bool _checking = false;
  String? _radiusMessage;

  Future<void> _checkRadius() async {
    setState(() {
      _checking = true;
      _radiusMessage = null;
    });
    final location = widget.appointment.location;
    if (location == null) {
      setState(() {
        _inRadius = null;
        _radiusMessage = 'No patient location.';
        _checking = false;
      });
      return;
    }
    final doctorId = widget.appointment.doctorId;
    final patientLat = location['latitude'];
    final patientLng = location['longitude'];
    final inRadius = await AppointmentService().isPatientWithinRadius(
      doctorId,
      patientLat,
      patientLng,
    );
    setState(() {
      _inRadius = inRadius;
      _radiusMessage = inRadius
          ? 'Patient is in range.'
          : 'Patient is NOT in range.';
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.appointment;
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
                    'Patient: ${a.patientName}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(a.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    a.status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(DateFormat('EEE, MMM d, yyyy').format(a.dateTime)),
                const SizedBox(width: 16),
                const Icon(
                  Icons.access_time,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(DateFormat('h:mm a').format(a.dateTime)),
              ],
            ),
            if (a.reason != null && a.reason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Reason: ${a.reason!}', style: const TextStyle(color: AppColors.textSecondary)),
            ],
            if (a.location != null) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('View on Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientLocationMapScreen(
                        appointment: a,
                      ),
                    ),
                  );
                },
              ),
            ],
            if (a.location != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Lat: ${a.location!['latitude']?.toStringAsFixed(5) ?? '-'}',
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Lng: ${a.location!['longitude']?.toStringAsFixed(5) ?? '-'}',
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.map),
                    label: const Text('View on Map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textWhite,
                    ),
                    onPressed: () async {
                      final lat = a.location!['latitude'];
                      final lng = a.location!['longitude'];
                      final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open Google Maps.')),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _checking ? null : _checkRadius,
                    icon: _checking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.radar),
                    label: const Text('Check Radius'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textWhite,
                    ),
                  ),
                  if (_radiusMessage != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _radiusMessage!,
                        style: TextStyle(
                          color: _inRadius == true
                              ? AppColors.success
                              : _inRadius == false
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            if (a.notes != null && a.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Note: ${a.notes!}', style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text('Message Patient'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      currentUserId: a.doctorId,
                      otherUserId: a.patientId,
                      otherUserName: a.patientName ?? 'Patient',
                    ),
                  ),
                );
              },
            ),
            // Last message preview
            StreamBuilder(
              stream: ChatService()
                  .streamMessages(a.doctorId, a.patientId)
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
                final isMe = senderId == a.doctorId;
                final senderLabel = isMe ? 'You' : (a.patientName ?? 'Patient');
                return StreamBuilder<Timestamp?>(
                  stream: ChatService().getLastRead(a.doctorId, a.patientId, a.doctorId),
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
