import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';
import '../../widgets/notification_list.dart';

class NotificationScreen extends StatefulWidget {
  final String userId;

  const NotificationScreen({required this.userId, super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> _notifications = [];
  final NotificationService _service = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final list = await _service.fetchNotifications(widget.userId);
    setState(() => _notifications = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: NotificationList(notifications: _notifications),
    );
  }
}