import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔔 Send notification to specific user under `notifications/{userId}/items`
  Future<void> sendNotification(NotificationModel notification) async {
    await _firestore
        .collection('notifications')
        .doc(notification.to)
        .collection('items')
        .add(notification.toMap());
  }

  /// 📥 Fetch all notifications for a specific user (newest first)
  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => NotificationModel.fromDoc(doc)).toList();
  }

  /// ✅ Mark notification as read
  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// ❌ Delete notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .doc(notificationId)
        .delete();
  }
}
