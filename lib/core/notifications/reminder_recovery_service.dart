import '../database/app_database.dart';
import 'reminder_scheduler.dart';

class ReminderRecoveryService {
  final AppDatabase database;
  final ReminderScheduler scheduler;

  const ReminderRecoveryService({
    required this.database,
    required this.scheduler,
  });

  /// Reconcile and replenish all active notification schedules from SQLite source of truth
  Future<void> reconcileAll() async {
    try {
      final activeItems = await (database.select(database.trackedItems)
            ..where((tbl) => tbl.deletedAt.isNull()))
          .get();

      for (final item in activeItems) {
        // Fetch enabled reminder rules for this item
        final rules = await (database.select(database.reminderRules)
              ..where((tbl) => tbl.itemId.equals(item.id))
              ..where((tbl) => tbl.isEnabled.equals(true)))
            .get();

        if (rules.isEmpty) continue;

        final offsets = rules.map((r) => r.offsetDays).toList();
        final preferredTime = rules.first.reminderTime;

        await scheduler.scheduleForItem(
          item: item,
          offsetDaysList: offsets,
          reminderTime: preferredTime,
        );
      }
    } catch (_) {}
  }
}
