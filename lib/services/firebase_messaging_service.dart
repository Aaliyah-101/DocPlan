import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initializeFCM(
      FlutterLocalNotificationsPlugin flnPlugin,
      GlobalKey<NavigatorState> navigatorKey,
      ) async {
    // Request notification permission
    await _messaging.requestPermission();

    // Define Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    // Register the channel with the plugin
    await flnPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialize local notifications plugin with navigation on tap
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

    // Handle foreground Firebase messages: show local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final data = message.data;
      final type = data['type'];
      final appointmentId = data['appointmentId'];

      String? title = notification?.title;
      String? body = notification?.body;

      if ((title == null || body == null) && type == 'emergency_alert') {
        title ??= "🚨 Emergency Alert";
        body ??= "An emergency has been assigned to you.";
      } else if ((title == null || body == null) && type == 'emergency_update') {
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
        payload: appointmentId,
      );
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message.data, navigatorKey);
    });

    // Handle notification tap when app launched from terminated state
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage.data, navigatorKey);
    }
  }

  static void _handleNotificationClick(
      Map<String, dynamic> data, GlobalKey<NavigatorState> navigatorKey) {
    final type = data['type'];
    final appointmentId = data['appointmentId'];

    if (type == 'emergency_alert' && appointmentId != null) {
      navigatorKey.currentState?.pushNamed(
        '/emergency_response',
        arguments: appointmentId,
      );
    } else {
      print('No navigation matched for: $type');
    }
  }
}
