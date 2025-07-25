import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/notification_model.dart';

class NotificationList extends StatefulWidget {
  final List<NotificationModel> notifications;

  const NotificationList({required this.notifications, super.key});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  late List<NotificationModel> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = widget.notifications;
  }

  // 🔄 Mark notification as read ✅ FIXED PATH
  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notification.to) // ✅ use `to` (user ID)
        .collection('items')
        .doc(notification.id) // ✅ use item ID
        .update({'isRead': true});

    setState(() {
      notification.isRead = true;
    });
  }

  // ❌ Delete notification ✅ FIXED PATH
  Future<void> _deleteNotification(NotificationModel notification) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notification.to) // ✅ use `to` (user ID)
        .collection('items')
        .doc(notification.id) // ✅ use item ID
        .delete();

    setState(() {
      _notifications.removeWhere((n) => n.id == notification.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notification deleted")),
    );
  }

  // 📊 Count notifications by type
  Map<String, int> _countByType() {
    final counts = <String, int>{};
    for (var n in _notifications) {
      counts[n.type] = (counts[n.type] ?? 0) + 1;
    }
    return counts;
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'booking':
        return Icons.calendar_today;
      case 'cancel_by_patient':
        return Icons.cancel;
      case 'cancel_by_doctor':
        return Icons.cancel_presentation;
      case 'reminder':
        return Icons.notifications_active;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeCounts = _countByType();

    return Column(
      children: [
        if (typeCounts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Wrap(
              spacing: 10,
              children: typeCounts.entries.map((entry) {
                return Chip(
                  label: Text("${_formatType(entry.key)}: ${entry.value}"),
                  backgroundColor: Colors.grey.shade200,
                );
              }).toList(),
            ),
          ),
        Expanded(
          child: _notifications.isEmpty
              ? const Center(child: Text("No notifications found."))
              : ListView.separated(
            itemCount: _notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = _notifications[index];
              final formattedTime = DateFormat('MMM d, h:mm a')
                  .format(notification.timestamp.toDate());

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                leading: Icon(
                  _getIcon(notification.type),
                  color: Colors.blueAccent,
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.message),
                    const SizedBox(height: 4),
                    Text(
                      formattedTime,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: notification.isRead
                    ? null
                    : const Icon(Icons.circle,
                    size: 10, color: Colors.red),
                onTap: () => _markAsRead(notification),
                onLongPress: () => _confirmDelete(notification),
              );
            },
          ),
        ),
      ],
    );
  }

  void _confirmDelete(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Notification?"),
        content:
        const Text("Are you sure you want to delete this notification?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNotification(notification);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatType(String type) {
    switch (type) {
      case 'booking':
        return 'Bookings';
      case 'cancel_by_patient':
        return 'Cancelled by Patient';
      case 'cancel_by_doctor':
        return 'Cancelled by Doctor';
      case 'reminder':
        return 'Reminders';
      default:
        return type;
    }
  }
}
