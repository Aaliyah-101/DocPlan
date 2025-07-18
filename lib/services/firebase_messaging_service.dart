import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initializeFCM(
      FlutterLocalNotificationsPlugin flnPlugin,
      GlobalKey<NavigatorState> navigatorKey,
      ) async {
    await _messaging.requestPermission();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await flnPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final data = message.data;
      final type = data['type'];
      final appointmentId = data['appointmentId'];

      String? title = message.notification?.title;
      String? body = message.notification?.body;

      // Fallback values
      if (title == null || body == null) {
        if (type == 'emergency_alert') {
          title = "🚨 Emergency Alert";
          body = "An emergency has been assigned to you.";
        } else if (type == 'emergency_update') {
          final status = data['status'];
          title = "🔄 Emergency Update";
          body = "Emergency has been marked as $status.";
        } else if (type == 'delay_notice') {
          title = "⚠️ Appointment Delayed";
          body = "Your appointment is delayed due to an emergency.";
        }
      }

      if (title != null && body != null) {
        flnPlugin.show(
          message.hashCode,
          title,
          body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
            ),
          ),
          payload: jsonEncode({
            'type': type,
            'appointmentId': appointmentId,
          }),
        );
      }
    });

    // App opened from background
    FirebaseMessaging.onMessageOpenedApp.listen(
            (message) => _handleTap(message, navigatorKey));

    // App opened from terminated state
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleTap(initialMessage, navigatorKey);
    }
  }

  static void _handleTap(
      RemoteMessage message, GlobalKey<NavigatorState> navigatorKey) {
    try {
      final data = message.data;
      final type = data['type'];
      final appointmentId = data['appointmentId'];

      if (type == 'emergency_alert' && appointmentId != null) {
        navigatorKey.currentState?.pushNamed(
          '/emergency_response',
          arguments: appointmentId,
        );
      } else {
        print("⚠️ Invalid notification data: $data");
      }
    } catch (e) {
      print("❌ Failed to handle notification tap: $e");
    }
  }
}
