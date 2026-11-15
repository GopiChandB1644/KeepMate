import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'app/keepremind_app.dart';
import 'core/database/app_database.dart';
import 'core/notifications/firebase_notification_service.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/reminder_recovery_service.dart';
import 'core/notifications/reminder_scheduler.dart';
import 'features/medicine_care/data/repositories/medicine_repository_impl.dart';
import 'features/medicine_care/domain/entities/dose_log_entity.dart';
import 'features/medicine_care/services/medicine_notification_service.dart';
import 'features/medicine_care/services/native_alarm_bridge.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Local Notifications first (Independent of Firebase & Network)
  final notificationService = NotificationService();
  try {
    await notificationService.init();
    await notificationService.requestPermissions();
  } catch (e, st) {
    debugPrint(
        '[KeepRemind] Local notifications initialization error: $e\n$st');
  }

  // 2. Seamlessly migrate legacy database to KeepRemind if present
  try {
    final appDocDir = await getApplicationDocumentsDirectory();
    final oldDb = File('${appDocDir.path}/keepmate.sqlite');
    final newDb = File('${appDocDir.path}/keepremind.sqlite');
    if (await oldDb.exists() && !await newDb.exists()) {
      await oldDb.copy(newDb.path);
      final oldWal = File('${appDocDir.path}/keepmate.sqlite-wal');
      final newWal = File('${appDocDir.path}/keepremind.sqlite-wal');
      if (await oldWal.exists()) await oldWal.copy(newWal.path);
      final oldShm = File('${appDocDir.path}/keepmate.sqlite-shm');
      final newShm = File('${appDocDir.path}/keepremind.sqlite-shm');
      if (await oldShm.exists()) await oldShm.copy(newShm.path);
    }
  } catch (e) {
    debugPrint('[KeepRemind] DB migration notice: $e');
  }

  // 3. Initialize SQLite Database with Drift
  final database = AppDatabase();

  // 4. Reconcile and replenish local notifications on app startup from SQLite
  final reminderScheduler =
      ReminderScheduler(notificationService: notificationService);
  final recoveryService =
      ReminderRecoveryService(database: database, scheduler: reminderScheduler);
  await recoveryService.reconcileAll();

  // 5. Re-synchronize and schedule all active medicine alarms with accurate local timezone
  try {
    final medicineRepo = MedicineRepositoryImpl(db: database);
    final medicineNotificationService =
        MedicineNotificationService(notificationService: notificationService);

    // Sync any offline/background native alarm actions first
    final pendingActions = await NativeAlarmBridge().getPendingAlarmActions();
    for (final item in pendingActions) {
      final actionId = item['actionId'] as String?;
      final action = item['action'] as String?;
      final medicineId = item['medicineId'] as String?;
      final doseTime = item['doseTime'] as String?;
      final scheduledDate = item['scheduledDate'] as String?;

      if (action == 'taken' &&
          medicineId != null &&
          doseTime != null &&
          scheduledDate != null) {
        await medicineRepo.recordDoseAction(
          medicineId: medicineId,
          scheduledDate: scheduledDate,
          scheduledTime: doseTime,
          status: DoseStatus.taken,
        );
      }
      if (actionId != null) {
        await NativeAlarmBridge().removePendingAlarmAction(actionId);
      }
    }

    final activeMeds = await medicineRepo.getAllMedicines();
    for (final med in activeMeds) {
      if (med.isActive) {
        await medicineNotificationService.scheduleMedicineSchedules(med);
      }
    }
  } catch (e) {
    debugPrint('[KeepRemind] Medicine notification recovery note: $e');
  }

  // 6. Inspect pending notifications on startup
  await notificationService.getPendingNotifications();

  // 7. Decoupled Firebase Cloud Messaging (runs in background, never blocks UI or local reminders)
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    unawaited(
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
          .then((_) => FirebaseNotificationService().initialize())
          .catchError((e) =>
              debugPrint('[KeepRemind] Firebase initialization note: $e')),
    );
  }

  runApp(
    KeepRemindApp(
      database: database,
      notificationService: notificationService,
    ),
  );
}
