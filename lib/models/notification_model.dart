import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id; // Firestore document ID (notification ID)
  final String title; // Notification title
  final String message; // Body of the notification
  final String type; // e.g., booking, reminder, cancel_by_patient
  final String from; // Sender UID (e.g., admin or system)
  final String to; // Receiver UID
  bool isRead; // Whether it's been read (mutable)
  final Timestamp timestamp; // Firestore timestamp

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.from,
    required this.to,
    required this.isRead,
    required this.timestamp,
  });

  /// Factory method to create model from Firestore document snapshot
  factory NotificationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? '',
      from: data['from'] ?? '',
      to: data['to'] ?? '',
      isRead: data['isRead'] ?? false,
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  /// Convert model to Firestore-storable map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'from': from,
      'to': to,
      'isRead': isRead,
      'timestamp': timestamp,
    };
  }
}
