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

    // Define channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    // Register channel
    await flnPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Init local notification click listener
    await flnPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null) {
          // You can handle simple payload here if needed
          print('Tapped notification with payload: $payload');
        }
      },
    );

    // Foreground message
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final data = message.data;
      final type = data['type'];
      final appointmentId = data['appointmentId'];

      String? title = notification?.title;
      String? body = notification?.body;

      // Fallback for some emergency types
      if ((title == null || body == null) && type == 'emergency_alert') {
        title ??= "🚨 Emergency Alert";
        body ??= "An emergency has been assigned to you.";
      } else if ((title == null || body == null) &&
          type == 'emergency_update') {
        title ??= "🚨 Emergency Update";
        body ??= "Emergency has been marked as ${data['status']}.";
      }

      // Show notification locally
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
        payload: appointmentId, // used when tapping
      );
    });

    // Tapped while app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message.data, navigatorKey);
    });

    // Tapped while app was terminated
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
