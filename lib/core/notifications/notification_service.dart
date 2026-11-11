import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../constants/app_constants.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        linux: LinuxInitializationSettings(defaultActionName: 'Open'),
        windows: WindowsInitializationSettings(appName: 'KeepRemind', appUserModelId: 'KeepRemindApp', guid: '7c9e6679-7425-40de-944b-e07fc1f90ae7'),
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('[NotificationService] Response received: ${response.payload}');
        },
      );
      _initialized = true;
    } catch (e) {
      debugPrint('[NotificationService] Init error: $e');
    }
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidPlugin?.requestNotificationsPermission();
        return granted ?? false;
      } else if (Platform.isIOS) {
        final iosPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('[NotificationService] requestPermissions error: $e');
      return false;
    }
  }

  NotificationDetails _notificationDetails({required String title, required String body}) {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.reminderChannelId,
      AppConstants.reminderChannelName,
      channelDescription: AppConstants.reminderChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return const NotificationDetails(android: androidDetails, iOS: darwinDetails);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      await init();
      final now = DateTime.now();
      if (scheduledDate.isBefore(now)) {
        return; // Past date, do not schedule
      }

      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        _notificationDetails(title: title, body: body),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[NotificationService] scheduleNotification error: $e');
    }
  }

  Future<void> cancel(int id) async {
    try {
      await init();
      await _notificationsPlugin.cancel(id);
    } catch (e) {
      debugPrint('[NotificationService] cancel error: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await init();
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('[NotificationService] cancelAll error: $e');
    }
  }
}

