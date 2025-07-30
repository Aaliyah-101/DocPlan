import 'package:workmanager/workmanager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD
import 'package:firebase_auth/firebase_auth.dart';
import '../services/Notifications_service.dart';
import '../models/notification_model.dart';
=======
import '../services/Notifications_service.dart';
import '../models/notification_model.dart';
import 'dart:developer' as developer;

/// Manual trigger for testing reminders
@pragma('vm:entry-point')
Future<void> manualReminderCheck() async {
  try {
    developer.log('🔄 Manual reminder check started');
    
    final now = DateTime.now();
    final thirtyMinutesFromNow = now.add(const Duration(minutes: 30));
    
    // Convert to Timestamp for Firestore query
    final nowTimestamp = Timestamp.fromDate(now);
    final thirtyMinutesTimestamp = Timestamp.fromDate(thirtyMinutesFromNow);
    
    developer.log('⏰ Checking appointments between ${now.toLocal()} and ${thirtyMinutesFromNow.toLocal()}');

    // Get all upcoming appointments that are happening in the next 30 minutes
    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('status', isEqualTo: 'upcoming')
        .where('dateTime', isGreaterThanOrEqualTo: nowTimestamp)
        .where('dateTime', isLessThanOrEqualTo: thirtyMinutesTimestamp)
        .get();

    developer.log('📋 Found ${snapshot.docs.length} appointments to remind');

    final notificationService = NotificationService();
    int notificationsSent = 0;

    for (final doc in snapshot.docs) {
      try {
        final data = doc.data();
        final appointmentTime = data['dateTime'] as Timestamp;
        final patientId = data['patientId'] as String;
        final doctorId = data['doctorId'] as String;
        final patientName = data['patientName'] as String? ?? 'Patient';
        final doctorName = data['doctorName'] as String? ?? 'Doctor';
        
        // Format appointment time
        final appointmentDateTime = appointmentTime.toDate();
        final timeString = '${appointmentDateTime.hour.toString().padLeft(2, '0')}:${appointmentDateTime.minute.toString().padLeft(2, '0')}';

        // Send reminder to patient
        await notificationService.sendNotification(
          NotificationModel(
            id: '',
            title: 'Appointment Reminder',
            message: 'You have an appointment with Dr. $doctorName today at $timeString',
            type: "reminder",
            from: "system",
            to: patientId,
            isRead: false,
            timestamp: Timestamp.now(),
          ),
        );

        // Send reminder to doctor
        await notificationService.sendNotification(
          NotificationModel(
            id: '',
            title: 'Appointment Reminder',
            message: 'You have an appointment with $patientName today at $timeString',
            type: "reminder",
            from: "system",
            to: doctorId,
            isRead: false,
            timestamp: Timestamp.now(),
          ),
        );

        notificationsSent += 2;
        developer.log('✅ Sent reminders for appointment: ${doc.id}');
      } catch (e) {
        developer.log('❌ Error sending reminder for appointment ${doc.id}: $e');
      }
    }

    developer.log('📊 Manual reminder check completed. Sent $notificationsSent notifications');
  } catch (e) {
    developer.log('❌ Error in manual reminder check: $e');
  }
}
>>>>>>> fik

/// 👇 REQUIRED for background isolate in release mode
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
<<<<<<< HEAD
      final currentUser = FirebaseAuth.instance.currentUser;

      // ⚠️ currentUser is null in background isolate
      if (currentUser == null) return Future.value(true);
      final uid = currentUser.uid;

      final now = Timestamp.now();
      final cutoff = Timestamp.fromDate(
        now.toDate().add(Duration(minutes: 30)),
      );

      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: uid)
          .where('dateTime', isGreaterThan: now)
          .where('dateTime', isLessThanOrEqualTo: cutoff)
          .get();

      final notificationService = NotificationService();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final appointmentTime = data['dateTime'] as Timestamp;

        final title = "Upcoming Appointment";
        final message = "You have an appointment at ${appointmentTime.toDate()}";

        await notificationService.sendNotification(
          NotificationModel(
            id: '',
            title: title,
            message: message,
            type: "reminder",
            from: "system",
            to: uid,
            isRead: false,
            timestamp: Timestamp.now(),
          ),
        );
      }

      return Future.value(true);
    } catch (e) {
      print("Error in callbackDispatcher: $e");
      return Future.value(false);
    }
  });
}
=======
      developer.log('🔄 Reminder worker started: $task');
      
      final now = DateTime.now();
      final thirtyMinutesFromNow = now.add(const Duration(minutes: 30));
      
      // Convert to Timestamp for Firestore query
      final nowTimestamp = Timestamp.fromDate(now);
      final thirtyMinutesTimestamp = Timestamp.fromDate(thirtyMinutesFromNow);
      
      developer.log('⏰ Checking appointments between ${now.toLocal()} and ${thirtyMinutesFromNow.toLocal()}');

      // Get all upcoming appointments that are happening in the next 30 minutes
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('status', isEqualTo: 'upcoming')
          .where('dateTime', isGreaterThanOrEqualTo: nowTimestamp)
          .where('dateTime', isLessThanOrEqualTo: thirtyMinutesTimestamp)
          .get();

      developer.log('📋 Found ${snapshot.docs.length} appointments to remind');

      final notificationService = NotificationService();
      int notificationsSent = 0;

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          final appointmentTime = data['dateTime'] as Timestamp;
          final patientId = data['patientId'] as String;
          final doctorId = data['doctorId'] as String;
          final patientName = data['patientName'] as String? ?? 'Patient';
          final doctorName = data['doctorName'] as String? ?? 'Doctor';
          
          // Format appointment time
          final appointmentDateTime = appointmentTime.toDate();
          final timeString = '${appointmentDateTime.hour.toString().padLeft(2, '0')}:${appointmentDateTime.minute.toString().padLeft(2, '0')}';
          final dateString = '${appointmentDateTime.day}/${appointmentDateTime.month}/${appointmentDateTime.year}';

          // Send reminder to patient
          await notificationService.sendNotification(
            NotificationModel(
              id: '',
              title: 'Appointment Reminder',
              message: 'You have an appointment with Dr. $doctorName today at $timeString',
              type: "reminder",
              from: "system",
              to: patientId,
              isRead: false,
              timestamp: Timestamp.now(),
            ),
          );

          // Send reminder to doctor
          await notificationService.sendNotification(
            NotificationModel(
              id: '',
              title: 'Appointment Reminder',
              message: 'You have an appointment with $patientName today at $timeString',
              type: "reminder",
              from: "system",
              to: doctorId,
              isRead: false,
              timestamp: Timestamp.now(),
            ),
          );

          notificationsSent += 2;
          developer.log('✅ Sent reminders for appointment: ${doc.id}');
        } catch (e) {
          developer.log('❌ Error sending reminder for appointment ${doc.id}: $e');
        }
      }

      developer.log('📊 Reminder worker completed. Sent $notificationsSent notifications');
      return Future.value(true);
    } catch (e) {
      developer.log('❌ Error in callbackDispatcher: $e');
      return Future.value(false);
    }
  });
}
>>>>>>> fik
