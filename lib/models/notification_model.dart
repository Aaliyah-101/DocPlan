import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String from;
  final String to;
  final bool isRead;
  final Timestamp timestamp;

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