import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static RemoteMessage? _initialMessage;

  /// Expose this to main.dart
  static RemoteMessage? get initialMessage => _initialMessage;

  /// Initialize FCM and local notifications
  static Future<void> initializeFCM(
      FlutterLocalNotificationsPlugin flnPlugin,
      GlobalKey<NavigatorState> navigatorKey,
      ) async {
    // 🔒 Request notification permissions
    await _messaging.requestPermission();

    // ✅ Create Android notification channel
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

    // 🎯 Local Notification initialization (when tapped while app is running)
    await flnPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null) {
          navigatorKey.currentState?.pushNamed(
            '/emergency_response',
            arguments: payload,
          );
        }
      },
    );

    // 💬 Foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final data = message.data;
      final type = data['type'];
      final appointmentId = data['appointmentId'];
      final notification = message.notification;

      String? title = notification?.title;
      String? body = notification?.body;

      // Fallback title/body for emergency types
      if ((title == null || body == null) && type == 'emergency_alert') {
        title ??= "🚨 Emergency Alert";
        body ??= "An emergency has been assigned to you.";
      } else if ((title == null || body == null) &&
          type == 'emergency_update') {
        title ??= "🚨 Emergency Update";
        body ??= "Emergency has been marked as ${data['status']}.";
      }

      flnPlugin.show(
        message.hashCode,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        payload: appointmentId, // This is passed to onDidReceiveNotificationResponse
      );
    });

    // ⬅️ Background tap handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message.data, navigatorKey);
    });

    // 💾 If app was terminated and opened by notification
    _initialMessage = await _messaging.getInitialMessage();
  }

  /// Handles navigation when notification is tapped from background
  static void _handleNotificationClick(
      Map<String, dynamic> data,
      GlobalKey<NavigatorState> navigatorKey,
      ) {
    final type = data['type'];
    final appointmentId = data['appointmentId'];

    if (type == 'emergency_alert' && appointmentId != null) {
      navigatorKey.currentState?.pushNamed(
        '/emergency_response',
        arguments: appointmentId,
      );
    } else {
      print('[Notification] No matching navigation for type: $type');
    }
  }

  /// Handles navigation if app was killed and opened by notification
  static void handleInitialMessage(
      Map<String, dynamic> data,
      GlobalKey<NavigatorState> navigatorKey,
      ) {
    final type = data['type'];
    final appointmentId = data['appointmentId'];

    if (type == 'emergency_alert' && appointmentId != null) {
      navigatorKey.currentState?.pushNamed(
        '/emergency_response',
        arguments: appointmentId,
      );
    }
  }
}
