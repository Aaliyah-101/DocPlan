import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendNotification(NotificationModel notification) async {
    await _firestore
        .collection('notifications')
        .doc(notification.to)
        .collection('items')
        .add(notification.toMap());
  }

  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => NotificationModel.fromDoc(doc))
        .toList();
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .doc(notificationId)
        .update({'isRead': true});
  }
}