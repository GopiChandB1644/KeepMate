import 'package:flutter/foundation.dart';
import '../database/app_database.dart';
import '../enums/item_enums.dart';
import 'reminder_scheduler.dart';

class ReminderRecoveryService {
  final AppDatabase database;
  final ReminderScheduler scheduler;

  const ReminderRecoveryService({
    required this.database,
    required this.scheduler,
  });

  /// Reconcile and replenish all active notification schedules from SQLite source of truth
  Future<({int succeeded, int failed})> reconcileAll() async {
    int succeeded = 0;
    int failed = 0;

    try {
      final activeItems = await (database.select(database.trackedItems)
            ..where((tbl) => tbl.deletedAt.isNull()))
          .get();

      for (final item in activeItems) {
        if (item.status == 'completed' || item.status == 'consumed' || item.status == 'archived') {
          continue;
        }

        try {
          // Fetch enabled reminder rules for this item
          final rules = await (database.select(database.reminderRules)
                ..where((tbl) => tbl.itemId.equals(item.id))
                ..where((tbl) => tbl.isEnabled.equals(true)))
              .get();

          final List<int> offsets;
          final String preferredTime;
          if (rules.isNotEmpty) {
            offsets = rules.map((r) => r.offsetDays).toList();
            preferredTime = rules.first.reminderTime;
          } else {
            final subcategory = ItemSubcategory.fromCode(item.subcategory);
            offsets = ReminderScheduler.getDefaultOffsets(subcategory);
            preferredTime = '09:00';
          }

          await scheduler.scheduleForItem(
            item: item,
            offsetDaysList: offsets,
            reminderTime: preferredTime,
          );
          succeeded++;
        } catch (itemErr, st) {
          failed++;
          debugPrint('[ReminderRecoveryService] Failed to reschedule item "${item.title}" (${item.id}): $itemErr\n$st');
        }
      }
      debugPrint('[ReminderRecoveryService] Reconcile completed: $succeeded item(s) restored, $failed failed.');
    } catch (e, st) {
      debugPrint('[ReminderRecoveryService] Database recovery query failed: $e\n$st');
    }

    return (succeeded: succeeded, failed: failed);
  }
}
