import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../services/Notifications_service.dart';
<<<<<<< HEAD
=======
import 'dart:developer' as developer;
>>>>>>> fik

class NotificationController {
  final NotificationService _service = NotificationService();

  Future<void> sendBookingNotification({
    required String patientName,
    required String doctorId,
    required DateTime appointmentTime,
    required String patientId,
  }) async {
    await _service.sendNotification(NotificationModel(
      id: '',
      title: 'New Appointment Booked',
      message: 'New appointment from $patientName on ${appointmentTime.toLocal()}',
      type: 'booking',
      from: patientId,
      to: doctorId,
      isRead: false,
      timestamp: Timestamp.now(),
    ));
  }

  Future<void> sendPatientCancelNotification({
    required String patientName,
    required String doctorId,
    required DateTime appointmentTime,
    required String patientId,
  }) async {
    await _service.sendNotification(NotificationModel(
      id: '',
      title: 'Appointment Cancelled',
      message: '$patientName cancelled their appointment on ${appointmentTime.toLocal()}',
      type: 'cancel_by_patient',
      from: patientId,
      to: doctorId,
      isRead: false,
      timestamp: Timestamp.now(),
    ));
  }

  Future<void> sendDoctorCancelNotification({
    required String doctorName,
    required String patientId,
    required DateTime appointmentTime,
    required String doctorId,
  }) async {
    await _service.sendNotification(NotificationModel(
      id: '',
      title: 'Doctor Cancelled Appointment',
      message: '$doctorName cancelled your appointment on ${appointmentTime.toLocal()}',
      type: 'cancel_by_doctor',
      from: doctorId,
      to: patientId,
      isRead: false,
      timestamp: Timestamp.now(),
    ));
  }

<<<<<<< HEAD
=======
  /// Schedule a reminder for an appointment (30 minutes before)
>>>>>>> fik
  void scheduleReminder({
    required DateTime appointmentTime,
    required String doctorId,
    required String patientId,
    required String doctorName,
    required String patientName,
  }) {
    final now = DateTime.now();
    final diff = appointmentTime.difference(now);
    final reminderTime = diff - const Duration(minutes: 30);

<<<<<<< HEAD
    if (reminderTime.isNegative) return;

    Timer(reminderTime, () async {
      final timestamp = Timestamp.now();

      await _service.sendNotification(NotificationModel(
        id: '',
        title: 'Appointment Reminder',
        message: 'You have an appointment with Dr. $doctorName at ${appointmentTime.hour}:${appointmentTime.minute}.',
        type: 'reminder',
        from: 'system',
        to: patientId,
        isRead: false,
        timestamp: timestamp,
      ));

      await _service.sendNotification(NotificationModel(
        id: '',
        title: 'Appointment Reminder',
        message: 'You have an appointment with $patientName at ${appointmentTime.hour}:${appointmentTime.minute}.',
        type: 'reminder',
        from: 'system',
        to: doctorId,
        isRead: false,
        timestamp: timestamp,
      ));
    });
  }
}
=======
    if (reminderTime.isNegative) {
      developer.log('⚠️ Appointment is too soon to schedule reminder');
      return;
    }

    developer.log('⏰ Scheduling reminder for appointment in ${reminderTime.inMinutes} minutes');

    Timer(reminderTime, () async {
      try {
        final timestamp = Timestamp.now();
        final timeString = '${appointmentTime.hour.toString().padLeft(2, '0')}:${appointmentTime.minute.toString().padLeft(2, '0')}';

        // Send reminder to patient
        await _service.sendNotification(NotificationModel(
          id: '',
          title: 'Appointment Reminder',
          message: 'You have an appointment with Dr. $doctorName today at $timeString',
          type: 'reminder',
          from: 'system',
          to: patientId,
          isRead: false,
          timestamp: timestamp,
        ));

        // Send reminder to doctor
        await _service.sendNotification(NotificationModel(
          id: '',
          title: 'Appointment Reminder',
          message: 'You have an appointment with $patientName today at $timeString',
          type: 'reminder',
          from: 'system',
          to: doctorId,
          isRead: false,
          timestamp: timestamp,
        ));

        developer.log('✅ Sent appointment reminders for $patientName and Dr. $doctorName');
      } catch (e) {
        developer.log('❌ Error sending appointment reminders: $e');
      }
    });
  }
}
>>>>>>> fik
