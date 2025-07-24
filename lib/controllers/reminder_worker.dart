import 'package:workmanager/workmanager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return Future.value(true);

    final uid = currentUser.uid;

    final now = Timestamp.now();
    final cutoff = Timestamp.fromDate(
      now.toDate().add(Duration(minutes: 30)),
    );

    // 🔧 Change 'dateTime' field to be stored as Timestamp in Firestore
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
      final message =
          "You have an appointment at ${appointmentTime.toDate()}";

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
  });
}
