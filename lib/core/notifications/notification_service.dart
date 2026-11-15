import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../constants/app_constants.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  FlutterLocalNotificationsPlugin get plugin => _notificationsPlugin;

  Future<bool> canScheduleExactAlarms() async {
    if (kIsWeb || !Platform.isAndroid) return true;
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await androidPlugin?.canScheduleExactNotifications() ?? false;
  }

  Future<void> init() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();
      try {
        final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
        debugPrint('[NotificationService] Local timezone configured: ${timeZoneInfo.identifier}');
      } catch (e) {
        debugPrint('[NotificationService] Could not resolve device timezone, defaulting to UTC: $e');
      }

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      final darwinCategories = <DarwinNotificationCategory>[
        DarwinNotificationCategory(
          'MEDICINE_ACTIONS',
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('action_taken', '✓ Taken'),
            DarwinNotificationAction.plain('action_snooze', '⏰ Snooze 15m'),
            DarwinNotificationAction.plain('action_skip', '✕ Skip'),
          ],
        ),
      ];

      final iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: darwinCategories,
      );

      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        linux: const LinuxInitializationSettings(defaultActionName: 'Open'),
        windows: const WindowsInitializationSettings(
          appName: 'KeepRemind',
          appUserModelId: 'KeepRemindApp',
          guid: '7c9e6679-7425-40de-944b-e07fc1f90ae7',
        ),
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('[NotificationService] Response received: ${response.payload}');
        },
      );

      // Register Android Notification Channels
      if (!kIsWeb && Platform.isAndroid) {
        final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

        const reminderChannel = AndroidNotificationChannel(
          AppConstants.reminderChannelId,
          AppConstants.reminderChannelName,
          description: AppConstants.reminderChannelDescription,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        );

        const medicineChannel = AndroidNotificationChannel(
          'medicine_reminders',
          'Medicine Reminders',
          description: 'Timely notifications for scheduled medication doses',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        );

        const caregiverChannel = AndroidNotificationChannel(
          'caregiver_alerts',
          'Caregiver Dose Alerts',
          description: 'Unconfirmed medicine alerts sent after grace period',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        );

        await androidPlugin?.createNotificationChannel(reminderChannel);
        await androidPlugin?.createNotificationChannel(medicineChannel);
        await androidPlugin?.createNotificationChannel(caregiverChannel);
      }

      _initialized = true;
    } catch (e, st) {
      debugPrint('[NotificationService] Init error: $e\n$st');
      rethrow;
    }
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidPlugin?.requestNotificationsPermission();
        try {
          await androidPlugin?.requestExactAlarmsPermission();
        } catch (e) {
          debugPrint('[NotificationService] Exact alarm permission request note: $e');
        }
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
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return const NotificationDetails(android: androidDetails, iOS: darwinDetails);
  }

  Future<bool> scheduleNotification({
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
        debugPrint('[NotificationService] Past date ($scheduledDate vs now $now), skipping ID: $id');
        return false;
      }

      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);
      final details = _notificationDetails(title: title, body: body);
      final exactAllowed = await canScheduleExactAlarms();

      if (exactAllowed) {
        try {
          await _notificationsPlugin.zonedSchedule(
            id,
            title,
            body,
            tzDateTime,
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            payload: payload,
          );
          debugPrint('[NotificationService] Exact reminder scheduled for "$title" at $tzDateTime (id: $id, tz: ${tz.local.name})');
          return true;
        } catch (e) {
          debugPrint('[NotificationService] Exact alarm rejected ($e), falling back to inexact');
        }
      }

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
      debugPrint('[NotificationService] Inexact reminder scheduled for "$title" at $tzDateTime (id: $id)');
      return true;
    } catch (e, st) {
      debugPrint('[NotificationService] scheduleNotification FAILED for ID $id ($title): $e\n$st');
      rethrow;
    }
  }

  /// Low-level zoned scheduling with custom details, repeating components, and strict error reporting
  Future<bool> scheduleZonedNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    DateTimeComponents? matchDateTimeComponents,
    String? payload,
  }) async {
    await init();
    final exactAllowed = await canScheduleExactAlarms();
    final mode = exactAllowed
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: mode,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: payload,
      );
      debugPrint('[NotificationService] Zoned notification scheduled ($mode) ID $id for "$title" at $scheduledDate (tz: ${tz.local.name})');
      return true;
    } catch (e, st) {
      debugPrint('[NotificationService] scheduleZonedNotification FAILED for ID $id ($title): $e\n$st');
      rethrow;
    }
  }

  /// Show an immediate notification for urgent reminders or in-app testing
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await init();
      final details = _notificationDetails(title: title, body: body);
      await _notificationsPlugin.show(id, title, body, details, payload: payload);
      debugPrint('[NotificationService] Immediate notification shown: $title');
    } catch (e, st) {
      debugPrint('[NotificationService] showNotification error: $e\n$st');
      rethrow;
    }
  }

  /// Queries all currently pending notifications queued in Android / iOS alarm manager
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      await init();
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      debugPrint('[NotificationService] Currently ${pending.length} pending notification(s) in system queue:');
      for (final n in pending) {
        debugPrint('  -> Pending ID: ${n.id}, Title: "${n.title}", Body: "${n.body}"');
      }
      return pending;
    } catch (e) {
      debugPrint('[NotificationService] Error querying pending notifications: $e');
      return [];
    }
  }

  Future<void> cancel(int id) async {
    try {
      await init();
      await _notificationsPlugin.cancel(id);
      debugPrint('[NotificationService] Cancelled notification ID: $id');
    } catch (e) {
      debugPrint('[NotificationService] cancel error: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await init();
      await _notificationsPlugin.cancelAll();
      debugPrint('[NotificationService] Cancelled ALL notifications.');
    } catch (e) {
      debugPrint('[NotificationService] cancelAll error: $e');
    }
  }
}
