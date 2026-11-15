import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NativeAlarmBridge {
  static const MethodChannel _channel =
      MethodChannel('com.keepremind.app/alarm_manager');

  static final NativeAlarmBridge _instance = NativeAlarmBridge._internal();
  factory NativeAlarmBridge() => _instance;
  NativeAlarmBridge._internal();

  /// Schedule an exact Android native alarm with continuous ringing and full-screen UI
  Future<bool> scheduleAlarm({
    required int id,
    required String medicineId,
    required String medicineName,
    required String dosage,
    required String mealInstruction,
    required String doseTime,
    required DateTime triggerDateTime,
    int snoozeMinutes = 5,
    int maxDurationMinutes = 10,
    bool vibrationEnabled = true,
    String? soundUri,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      debugPrint(
          '[NativeAlarmBridge] Native alarms only supported on Android platform.');
      return false;
    }

    try {
      final success = await _channel.invokeMethod<bool>('scheduleAlarm', {
        'id': id,
        'medicineId': medicineId,
        'medicineName': medicineName,
        'dosage': dosage,
        'mealInstruction': mealInstruction,
        'doseTime': doseTime,
        'triggerTimestamp': triggerDateTime.millisecondsSinceEpoch,
        'snoozeMinutes': snoozeMinutes,
        'maxDurationMinutes': maxDurationMinutes,
        'vibrationEnabled': vibrationEnabled,
        'soundUri': soundUri,
      });
      debugPrint(
          '[NativeAlarmBridge] scheduleAlarm ID $id ($medicineName at $doseTime, $triggerDateTime) returned: $success');
      return success ?? false;
    } on PlatformException catch (e) {
      debugPrint(
          '[NativeAlarmBridge] scheduleAlarm failed with PlatformException: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[NativeAlarmBridge] scheduleAlarm error: $e');
      return false;
    }
  }

  /// Cancel an individual native alarm by ID
  Future<bool> cancelAlarm(int id) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final success =
          await _channel.invokeMethod<bool>('cancelAlarm', {'id': id});
      debugPrint('[NativeAlarmBridge] cancelAlarm ID $id returned: $success');
      return success ?? false;
    } catch (e) {
      debugPrint('[NativeAlarmBridge] cancelAlarm error: $e');
      return false;
    }
  }

  /// Cancel all native alarms registered for a specific medicine
  Future<bool> cancelMedicineAlarms(String medicineId) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final success = await _channel.invokeMethod<bool>(
          'cancelMedicineAlarms', {'medicineId': medicineId});
      debugPrint(
          '[NativeAlarmBridge] cancelMedicineAlarms for $medicineId returned: $success');
      return success ?? false;
    } catch (e) {
      debugPrint('[NativeAlarmBridge] cancelMedicineAlarms error: $e');
      return false;
    }
  }

  /// Cancel all alarms in the system
  Future<bool> cancelAllAlarms() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final success = await _channel.invokeMethod<bool>('cancelAllAlarms');
      return success ?? false;
    } catch (e) {
      debugPrint('[NativeAlarmBridge] cancelAllAlarms error: $e');
      return false;
    }
  }

  /// Stop any currently ringing foreground alarm
  Future<bool> stopActiveAlarm() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final success = await _channel.invokeMethod<bool>('stopActiveAlarm');
      return success ?? false;
    } catch (e) {
      debugPrint('[NativeAlarmBridge] stopActiveAlarm error: $e');
      return false;
    }
  }

  /// Check whether the app has permission to schedule exact alarms
  Future<bool> canScheduleExactAlarms() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return true;
    try {
      final can = await _channel.invokeMethod<bool>('canScheduleExactAlarms');
      return can ?? true;
    } catch (e) {
      debugPrint('[NativeAlarmBridge] canScheduleExactAlarms error: $e');
      return true;
    }
  }

  /// Check whether the app has permission to display full-screen intent
  Future<bool> canUseFullScreenIntent() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return true;
    try {
      final can = await _channel.invokeMethod<bool>('canUseFullScreenIntent');
      return can ?? true;
    } catch (e) {
      debugPrint('[NativeAlarmBridge] canUseFullScreenIntent error: $e');
      return true;
    }
  }

  /// Open device settings for exact alarm permission
  Future<bool> openExactAlarmSettings() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final res = await _channel.invokeMethod<bool>('openExactAlarmSettings');
      return res ?? false;
    } catch (e) {
      debugPrint('[NativeAlarmBridge] openExactAlarmSettings error: $e');
      return false;
    }
  }

  /// Retrieve any pending actions recorded natively (e.g. while app was in background or closed)
  Future<List<Map<String, dynamic>>> getPendingAlarmActions() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return [];
    try {
      final list =
          await _channel.invokeListMethod<dynamic>('getPendingAlarmActions');
      if (list == null) return [];
      return list
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (e) {
      debugPrint('[NativeAlarmBridge] getPendingAlarmActions error: $e');
      return [];
    }
  }

  /// Remove a specific processed action from native storage
  Future<void> removePendingAlarmAction(String actionId) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel
          .invokeMethod('removePendingAlarmAction', {'actionId': actionId});
    } catch (e) {
      debugPrint('[NativeAlarmBridge] removePendingAlarmAction error: $e');
    }
  }

  /// Clear all pending actions
  Future<void> clearPendingAlarmActions() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod('clearPendingAlarmActions');
    } catch (e) {
      debugPrint('[NativeAlarmBridge] clearPendingAlarmActions error: $e');
    }
  }

  /// Inspect currently active native alarms
  Future<List<String>> getPendingNativeAlarms() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return [];
    try {
      final list =
          await _channel.invokeListMethod<String>('getPendingNativeAlarms');
      return list ?? [];
    } catch (e) {
      debugPrint('[NativeAlarmBridge] getPendingNativeAlarms error: $e');
      return [];
    }
  }
}
