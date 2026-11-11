import 'package:flutter/material.dart';
import 'app/keepmate_app.dart';
import 'core/database/app_database.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/reminder_recovery_service.dart';
import 'core/notifications/reminder_scheduler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    KeepMateApp(
      database: database,
      notificationService: notificationService,
    ),
  );
}
