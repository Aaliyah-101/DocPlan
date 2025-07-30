import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/Notifications_service.dart';
import '../../models/notification_model.dart';
import '../../widgets/notification_list.dart';

class NotificationScreen extends StatefulWidget {
  final String? userId; // Optional for admins or external call

  const NotificationScreen({this.userId, super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> _notifications = [];
  final NotificationService _service = NotificationService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final uid = widget.userId ?? currentUser?.uid;

      if (uid == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final list = await _service.fetchNotifications(uid);
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading notifications: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : NotificationList(notifications: _notifications),
    );
  }
}
