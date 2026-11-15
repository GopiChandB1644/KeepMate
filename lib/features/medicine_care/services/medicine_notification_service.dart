import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../domain/entities/medicine_entity.dart';

class MedicineNotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  static const String channelId = 'medicine_reminders';
  static const String channelName = 'Medicine Reminders';
  static const String channelDescription = 'Timely notifications for scheduled medication doses';

  static const String caregiverChannelId = 'caregiver_alerts';
  static const String caregiverChannelName = 'Caregiver Dose Alerts';
  static const String caregiverChannelDescription = 'Unconfirmed medicine alerts sent after grace period';

  MedicineNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  NotificationDetails _medicineNotificationDetails({
    required String medicineName,
    required String dosage,
    required String mealInstruction,
  }) {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'action_taken',
          '✓ Taken',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'action_snooze',
          '⏰ Snooze 15m',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'action_skip',
          '✕ Skip',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'MEDICINE_ACTIONS',
    );

    return const NotificationDetails(android: androidDetails, iOS: darwinDetails);
  }

  int generateNotificationId(String medicineId, String doseTime) {
    // Generate deterministic 31-bit positive int from medicineId + doseTime
    final combined = '$medicineId-$doseTime';
    var hash = 0;
    for (var i = 0; i < combined.length; i++) {
      hash = (31 * hash + combined.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash;
  }

  Future<void> scheduleMedicineSchedules(MedicineEntity medicine) async {
    for (final schedule in medicine.schedules) {
      if (!schedule.reminderEnabled) continue;

      final notifId = generateNotificationId(medicine.id, schedule.doseTime);
      final parts = schedule.doseTime.split(':');
      if (parts.length != 2) continue;
      final hour = int.tryParse(parts[0]) ?? 8;
      final minute = int.tryParse(parts[1]) ?? 0;

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If scheduled time for today has passed, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final payload = jsonEncode({
        'type': 'medicine_dose',
        'medicineId': medicine.id,
        'medicineName': medicine.name,
        'dosage': medicine.dosage,
        'scheduledTime': schedule.doseTime,
        'scheduleId': schedule.id,
      });

      try {
        await _plugin.zonedSchedule(
          notifId,
          'Time for medicine: ${medicine.name}',
          '${medicine.dosage} • ${medicine.instructions.label}. Please take according to your prescription.',
          scheduledDate,
          _medicineNotificationDetails(
            medicineName: medicine.name,
            dosage: medicine.dosage,
            mealInstruction: medicine.instructions.label,
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time, // Daily recurring
          payload: payload,
        );
      } catch (e) {
        debugPrint('[MedicineNotificationService] Scheduling error: $e');
      }
    }
  }

  Future<void> cancelMedicineSchedules(String medicineId, List<MedicineScheduleEntity> schedules) async {
    for (final schedule in schedules) {
      final notifId = generateNotificationId(medicineId, schedule.doseTime);
      try {
        await _plugin.cancel(notifId);
      } catch (e) {
        debugPrint('[MedicineNotificationService] Cancel error: $e');
      }
    }
  }

  Future<void> scheduleSnoozeNotification({
    required String medicineId,
    required String medicineName,
    required String dosage,
    required String mealInstruction,
    int minutes = 15,
  }) async {
    final notifId = (medicineId.hashCode + 9999).abs() & 0x7FFFFFFF;
    final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes));

    final payload = jsonEncode({
      'type': 'medicine_snooze',
      'medicineId': medicineId,
      'medicineName': medicineName,
      'dosage': dosage,
    });

    try {
      await _plugin.zonedSchedule(
        notifId,
        'Reminder: $medicineName',
        '$dosage • $mealInstruction (Snoozed $minutes mins ago)',
        scheduledDate,
        _medicineNotificationDetails(
          medicineName: medicineName,
          dosage: dosage,
          mealInstruction: mealInstruction,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[MedicineNotificationService] Snooze error: $e');
    }
  }
}
