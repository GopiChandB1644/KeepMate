import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../firebase_options.dart';

/// Top-level background message handler for Firebase Messaging.
/// Must be top-level and annotated with @pragma('vm:entry-point') so Flutter can invoke it
/// when the application process is completely closed/killed.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('[FirebaseNotificationService] Background Firebase.initializeApp error: $e');
  }

  debugPrint('[FirebaseNotificationService] Handling background/killed message ID: ${message.messageId}');

  // If the message is a data-only payload (no notification object),
  // Android system tray won't automatically display it. We trigger a local notification here
  // so the user is guaranteed to receive an alert even when the app is terminated.
  if (message.notification == null && message.data.isNotEmpty) {
    final title = message.data['title'] as String? ?? 'KeepRemind Notification';
    final body = message.data['body'] as String? ?? '';
    if (title.isNotEmpty || body.isNotEmpty) {
      final localNotifications = FlutterLocalNotificationsPlugin();
      const androidDetails = AndroidNotificationDetails(
        FirebaseNotificationService.channelId,
        FirebaseNotificationService.channelName,
        channelDescription: FirebaseNotificationService.channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );
      const notificationDetails = NotificationDetails(android: androidDetails);
      await localNotifications.show(
        message.hashCode,
        title,
        body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    }
  }
}

class FirebaseNotificationService {
  static const String channelId = 'firebase_push_channel';
  static const String channelName = 'High Priority Alerts';
  static const String channelDescription =
      'Important reminders, caregiver alerts, and urgent notifications across foreground, background, and killed states.';

  final FirebaseMessaging _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  FirebaseNotificationService({
    FirebaseMessaging? fcm,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _fcm = fcm ?? FirebaseMessaging.instance,
        _localNotifications = localNotifications ?? FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    channelId,
    channelName,
    description: channelDescription,
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  /// Initializes Firebase Messaging, creates channels, sets up listeners for all app states
  Future<void> initialize({void Function(RemoteMessage message)? onNotificationTap}) async {
    try {
      // 1. Request Notification Permissions
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );
      debugPrint('[FirebaseNotificationService] Notification permission status: ${settings.authorizationStatus}');

      // 2. Set iOS foreground notification presentation options
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Register Android High Priority Notification Channel
      final androidPlatform = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlatform?.createNotificationChannel(_androidChannel);

      // 4. Register Background & Killed State Handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 5. FOREGROUND STATE: Listen for incoming messages while app is open and in use.
      // Firebase by default does NOT show heads-up banners on Android when app is in foreground.
      // We explicitly trigger a local notification to guarantee visibility!
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FirebaseNotificationService] Foreground message received: ${message.messageId}');
        _showForegroundNotification(message);
      });

      // 6. BACKGROUND STATE: Handle when notification is tapped and brings app from background to foreground
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FirebaseNotificationService] Notification opened from background: ${message.messageId}');
        onNotificationTap?.call(message);
      });

      // 7. KILLED STATE: Check if the app was launched by tapping a notification when terminated
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[FirebaseNotificationService] App launched from killed state: ${initialMessage.messageId}');
        onNotificationTap?.call(initialMessage);
      }

      // 8. Retrieve & Listen for FCM Token
      await _fetchToken();
      _fcm.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('[FirebaseNotificationService] FCM Token refreshed: $newToken');
      });
    } catch (e) {
      debugPrint('[FirebaseNotificationService] Initialization error: $e');
    }
  }

  Future<void> _fetchToken() async {
    try {
      _fcmToken = await _fcm.getToken();
      debugPrint('[FirebaseNotificationService] FCM Device Token: $_fcmToken');
    } catch (e) {
      debugPrint('[FirebaseNotificationService] Error getting FCM token: $e');
    }
  }

  /// Displays an immediate high-priority heads-up notification while the app is actively running
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] as String? ?? 'KeepRemind';
    final body = notification?.body ?? message.data['body'] as String? ?? '';

    if (title.isEmpty && body.isEmpty) return;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      details,
      payload: jsonEncode(message.data),
    );
  }
}
