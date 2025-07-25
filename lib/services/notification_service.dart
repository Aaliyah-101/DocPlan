import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

class NotificationService {
  static const String _fcmUrl = 'https://fcm.googleapis.com/fcm/send';
  // You'll need to get this from Firebase Console > Project Settings > Cloud Messaging
  static const String _serverKey = 'YOUR_FCM_SERVER_KEY';

  static final Logger _logger = Logger();

  // Send notification to specific FCM tokens
  static Future<void> sendNotificationToTokens({
    required List<String> fcmTokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (fcmTokens.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({
          'registration_ids': fcmTokens,
          'notification': {
            'title': title,
            'body': body,
            'sound': 'default',
            'priority': 'high',
          },
          'data': data ?? {},
          'priority': 'high',
        }),
      );

      if (response.statusCode == 200) {
        _logger.i('Notification sent successfully');
      } else {
        _logger.e('Failed to send notification: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error sending notification: $e');
    }
  }

  // Send notification to all patients of a specific doctor
  static Future<void> notifyDoctorPatients({
    required String doctorId,
    required String doctorName,
    required String emergencyReason,
  }) async {
    try {
      // Get all upcoming appointments for this doctor
      final appointmentsQuery = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'upcoming')
          .get();

      if (appointmentsQuery.docs.isEmpty) return;

      // Get unique patient IDs
      final patientIds = appointmentsQuery.docs
          .map((doc) => doc.data()['patientId'] as String)
          .toSet()
          .toList();

      // Get FCM tokens for these patients
      final fcmTokens = <String>[];
      for (final patientId in patientIds) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(patientId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final fcmToken = userData['fcmToken'] as String?;
          if (fcmToken != null && fcmToken.isNotEmpty) {
            fcmTokens.add(fcmToken);
          }
        }
      }

      if (fcmTokens.isNotEmpty) {
        await sendNotificationToTokens(
          fcmTokens: fcmTokens,
          title: 'Emergency - Appointment Rescheduled',
          body:
          'Dr. $doctorName has declared an emergency. Your appointment has been rescheduled.',
          data: {
            'type': 'doctor_emergency',
            'doctorId': doctorId,
            'doctorName': doctorName,
            'reason': emergencyReason,
          },
        );
      }
    } catch (e) {
      _logger.e('Error notifying doctor patients: $e');
    }
  }

  // Send notification to all available doctors (for patient emergencies)
  static Future<void> notifyAvailableDoctors({
    required String patientName,
    required String emergencyReason,
  }) async {
    try {
      // Get all available doctors
      final doctorsQuery = await FirebaseFirestore.instance
          .collection('doctors')
          .where('status', isEqualTo: 'available')
          .get();

      if (doctorsQuery.docs.isEmpty) return;

      // Get FCM tokens for available doctors
      final fcmTokens = <String>[];
      for (final doctorDoc in doctorsQuery.docs) {
        final doctorId = doctorDoc.id;
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(doctorId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final fcmToken = userData['fcmToken'] as String?;
          if (fcmToken != null && fcmToken.isNotEmpty) {
            fcmTokens.add(fcmToken);
          }
        }
      }

      if (fcmTokens.isNotEmpty) {
        await sendNotificationToTokens(
          fcmTokens: fcmTokens,
          title: 'Patient Emergency',
          body: 'Emergency declared by $patientName: $emergencyReason',
          data: {
            'type': 'patient_emergency',
            'patientName': patientName,
            'reason': emergencyReason,
          },
        );
      }
    } catch (e) {
      _logger.e('Error notifying available doctors: $e');
    }
  }

  // Send appointment status change notification
  static Future<void> notifyAppointmentStatusChange({
    required String patientId,
    required String doctorName,
    required String status,
    required DateTime appointmentTime,
  }) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(patientId)
          .get();

      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final fcmToken = userData['fcmToken'] as String?;

      if (fcmToken == null || fcmToken.isEmpty) return;

      String title, body;
      switch (status) {
        case 'rescheduled':
          title = 'Appointment Rescheduled';
          body = 'Your appointment with Dr. $doctorName has been rescheduled.';
          break;
        case 'cancelled':
          title = 'Appointment Cancelled';
          body = 'Your appointment with Dr. $doctorName has been cancelled.';
          break;
        default:
          return;
      }

      await sendNotificationToTokens(
        fcmTokens: [fcmToken],
        title: title,
        body: body,
        data: {
          'type': 'appointment_status',
          'status': status,
          'doctorName': doctorName,
          'appointmentTime': appointmentTime.toIso8601String(),
        },
      );
    } catch (e) {
      _logger.e('Error notifying appointment status change: $e');
    }
  }

  // Send notification for new chat message
  static Future<void> notifyNewChatMessage({
    required String receiverId,
    required String senderName,
    required String message,
  }) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverId)
          .get();
      if (!userDoc.exists) return;
      final userData = userDoc.data() as Map<String, dynamic>;
      final fcmToken = userData['fcmToken'] as String?;
      if (fcmToken == null || fcmToken.isEmpty) return;
      await sendNotificationToTokens(
        fcmTokens: [fcmToken],
        title: 'New Message from $senderName',
        body: message,
        data: {
          'type': 'chat_message',
          'senderName': senderName,
        },
      );
    } catch (e) {
      _logger.e('Error notifying new chat message: $e');
    }
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> AaliyahM
