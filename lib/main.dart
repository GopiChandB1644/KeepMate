import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'app/keepremind_app.dart';
import 'core/database/app_database.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/reminder_recovery_service.dart';
import 'core/notifications/reminder_scheduler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Seamlessly migrate legacy database to KeepRemind if present
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

  // Initialize Local Notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  // Initialize SQLite Database with Drift
  final database = AppDatabase();

  // Reconcile and replenish local notifications on app startup
  final reminderScheduler = ReminderScheduler(notificationService: notificationService);
  final recoveryService = ReminderRecoveryService(database: database, scheduler: reminderScheduler);
  await recoveryService.reconcileAll();

  runApp(
    KeepRemindApp(
      database: database,
      notificationService: notificationService,
    ),
  );
}
