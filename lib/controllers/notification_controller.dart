import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../services/Notifications_service.dart';

class NotificationController {
  final NotificationService _service = NotificationService();

  Future<void> sendBookingNotification({
    required String patientName,
    required String doctorId,
    required DateTime appointmentTime,
    required String patientId,
  }) async {
<<<<<<< HEAD
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
=======
    await _service.sendNotification(
      NotificationModel(
        id: '',
        title: 'New Appointment Booked',
        message:
            'New appointment from $patientName on ${appointmentTime.toLocal()}',
        type: 'booking',
        from: patientId,
        to: doctorId,
        isRead: false,
        timestamp: Timestamp.now(),
      ),
    );
>>>>>>> AaliyahM
  }

  Future<void> sendPatientCancelNotification({
    required String patientName,
    required String doctorId,
    required DateTime appointmentTime,
    required String patientId,
  }) async {
<<<<<<< HEAD
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
=======
    await _service.sendNotification(
      NotificationModel(
        id: '',
        title: 'Appointment Cancelled',
        message:
            '$patientName cancelled their appointment on ${appointmentTime.toLocal()}',
        type: 'cancel_by_patient',
        from: patientId,
        to: doctorId,
        isRead: false,
        timestamp: Timestamp.now(),
      ),
    );
>>>>>>> AaliyahM
  }

  Future<void> sendDoctorCancelNotification({
    required String doctorName,
    required String patientId,
    required DateTime appointmentTime,
    required String doctorId,
  }) async {
<<<<<<< HEAD
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
=======
    await _service.sendNotification(
      NotificationModel(
        id: '',
        title: 'Doctor Cancelled Appointment',
        message:
            '$doctorName cancelled your appointment on ${appointmentTime.toLocal()}',
        type: 'cancel_by_doctor',
        from: doctorId,
        to: patientId,
        isRead: false,
        timestamp: Timestamp.now(),
      ),
    );
>>>>>>> AaliyahM
  }

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

    if (reminderTime.isNegative) return;

    Timer(reminderTime, () async {
      final timestamp = Timestamp.now();

<<<<<<< HEAD
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
=======
      await _service.sendNotification(
        NotificationModel(
          id: '',
          title: 'Appointment Reminder',
          message:
              'You have an appointment with Dr. $doctorName at ${appointmentTime.hour}:${appointmentTime.minute}.',
          type: 'reminder',
          from: 'system',
          to: patientId,
          isRead: false,
          timestamp: timestamp,
        ),
      );

      await _service.sendNotification(
        NotificationModel(
          id: '',
          title: 'Appointment Reminder',
          message:
              'You have an appointment with $patientName at ${appointmentTime.hour}:${appointmentTime.minute}.',
          type: 'reminder',
          from: 'system',
          to: doctorId,
          isRead: false,
          timestamp: timestamp,
        ),
      );
>>>>>>> AaliyahM
    });
  }
}
