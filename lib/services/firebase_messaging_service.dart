import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

<<<<<<< HEAD
import '../screens/chat_screen.dart'; // Adjust the path if necessary
=======
import '../screens/chat_screen.dart';
>>>>>>> fik

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

<<<<<<< HEAD
    // ✅ Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
=======
    // ✅ Emergency Alerts Channel
    const AndroidNotificationChannel emergencyChannel = AndroidNotificationChannel(
      'emergency_alerts',
      'Emergency Alerts',
      description: 'Used for emergency alert notifications.',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('emergency_alarm'), // .mp3 file in res/raw/
    );

    // ✅ General Channel (Optional if you still want other notifications)
    const AndroidNotificationChannel generalChannel = AndroidNotificationChannel(
>>>>>>> fik
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

<<<<<<< HEAD
    await flnPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 🎯 Local Notification initialization (when tapped while app is running)
=======
    final androidPlugin = flnPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(emergencyChannel);
    await androidPlugin?.createNotificationChannel(generalChannel);

    // 🎯 Local Notification initialization
>>>>>>> fik
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

<<<<<<< HEAD
      // Fallback title/body for emergency types
      if ((title == null || body == null) && type == 'emergency_alert') {
        title ??= "🚨 Emergency Alert";
        body ??= "An emergency has been assigned to you.";
      } else if ((title == null || body == null) &&
          type == 'emergency_update') {
=======
      // 🛑 Emergency fallback title/body
      if ((title == null || body == null) && type == 'emergency_alert') {
        title ??= "🚨 Emergency Alert";
        body ??= "An emergency has been assigned to you.";
      } else if ((title == null || body == null) && type == 'emergency_update') {
>>>>>>> fik
        title ??= "🚨 Emergency Update";
        body ??= "Emergency has been marked as ${data['status']}.";
      }

<<<<<<< HEAD
=======
      // 🧠 Decide channel based on type
      final String channelId =
      type == 'emergency_alert' ? 'emergency_alerts' : 'high_importance_channel';

      final String soundName =
      type == 'emergency_alert' ? 'emergency_alarm' : 'default';

>>>>>>> fik
      flnPlugin.show(
        message.hashCode,
        title,
        body,
<<<<<<< HEAD
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
=======
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelId == 'emergency_alerts' ? 'Emergency Alerts' : 'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound(soundName),
          ),
        ),
        payload: appointmentId,
>>>>>>> fik
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
      ) async {
    final type = data['type'];

    if (type == 'emergency_alert' && data['appointmentId'] != null) {
      navigatorKey.currentState?.pushNamed(
        '/emergency_response',
        arguments: data['appointmentId'],
      );
    } else if (type == 'chat_message') {
      final String senderId = data['senderId'];
      final String senderName = data['senderName'] ?? 'User';
      final String receiverId = data['receiverId'];

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final String currentUserId = currentUser.uid;
<<<<<<< HEAD
      final String otherUserId =
      currentUserId == senderId ? receiverId : senderId;
      final String otherUserName = currentUserId == senderId
          ? (data['receiverName'] ?? 'User')
          : senderName;
=======
      final String otherUserId = currentUserId == senderId ? receiverId : senderId;
      final String otherUserName =
      currentUserId == senderId ? (data['receiverName'] ?? 'User') : senderName;
>>>>>>> fik

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            currentUserId: currentUserId,
            otherUserId: otherUserId,
            otherUserName: otherUserName,
          ),
        ),
      );
    } else {
      print('[Notification] No matching navigation for type: $type');
    }
  }

  /// Handles navigation if app was killed and opened by notification
  static void handleInitialMessage(
      Map<String, dynamic> data,
      GlobalKey<NavigatorState> navigatorKey,
      ) async {
    final type = data['type'];

    if (type == 'emergency_alert' && data['appointmentId'] != null) {
      navigatorKey.currentState?.pushNamed(
        '/emergency_response',
        arguments: data['appointmentId'],
      );
    } else if (type == 'chat_message') {
      final String senderId = data['senderId'];
      final String senderName = data['senderName'] ?? 'User';
      final String receiverId = data['receiverId'];

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final String currentUserId = currentUser.uid;
<<<<<<< HEAD
      final String otherUserId =
      currentUserId == senderId ? receiverId : senderId;
      final String otherUserName = currentUserId == senderId
          ? (data['receiverName'] ?? 'User')
          : senderName;
=======
      final String otherUserId = currentUserId == senderId ? receiverId : senderId;
      final String otherUserName =
      currentUserId == senderId ? (data['receiverName'] ?? 'User') : senderName;
>>>>>>> fik

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            currentUserId: currentUserId,
            otherUserId: otherUserId,
            otherUserName: otherUserName,
          ),
        ),
      );
    }
  }
}
