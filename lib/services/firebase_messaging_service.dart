import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static RemoteMessage? _initialMessage;

  // Expose this to MyApp so it can safely handle it after build
  static RemoteMessage? get initialMessage => _initialMessage;

  static Future<void> initializeFCM(
      FlutterLocalNotificationsPlugin flnPlugin,
      GlobalKey<NavigatorState> navigatorKey,
      ) async {
    // Request notification permissions
    await _messaging.requestPermission();

    // Set up Android notification channel
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

    // Initialize local notification settings
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

    // Handle foreground messages
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
        payload: appointmentId,
      );
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message.data, navigatorKey);
    });

    // Store the initial message (if app was launched by notification)
    _initialMessage = await _messaging.getInitialMessage();
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
