import 'package:flutter/material.dart';
import '../../models/notification_model.dart';

class NotificationList extends StatelessWidget {
  final List<NotificationModel> notifications;

  const NotificationList({required this.notifications, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: notifications.length,
      separatorBuilder: (_, __) => Divider(),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return ListTile(
          title: Text(notification.title),
          subtitle: Text(notification.message),
          trailing: notification.isRead
              ? null
              : Icon(Icons.circle, size: 10, color: Colors.red),
        );
      },
    );
  }
}