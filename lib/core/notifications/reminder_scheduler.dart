import '../database/app_database.dart';
import '../enums/item_enums.dart';
import '../utils/date_utils.dart';
import 'notification_id_generator.dart';
import 'notification_service.dart';

class ReminderScheduler {
  final NotificationService notificationService;

  const ReminderScheduler({required this.notificationService});

  /// Get suggested default reminder offsets (in days before) for a subcategory
  static List<int> getDefaultOffsets(ItemSubcategory subcategory) {
    switch (subcategory) {
      case ItemSubcategory.warranty:
      case ItemSubcategory.insurance:
        return [30, 7, 1];
      case ItemSubcategory.document:
        return [30, 7, 1];
      case ItemSubcategory.grocery:
        return [2, 1];
      case ItemSubcategory.bill:
      case ItemSubcategory.subscription:
        return [3, 1];
      case ItemSubcategory.purchase:
        return [7, 1];
    }
  }

  /// Calculate the trigger DateTime given target expiry/due date, offsetDays and preferred time (HH:mm)
  DateTime calculateReminderDateTime({
    required DateTime targetDate,
    required int offsetDays,
    String preferredTime = '09:00',
  }) {
    final parts = preferredTime.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 9 : 9;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final baseDate = targetDate.subtract(Duration(days: offsetDays));
    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }

  /// Schedule notifications for an item and its configured reminder offsets
  Future<void> scheduleForItem({
    required TrackedItem item,
    required List<int> offsetDaysList,
    String reminderTime = '09:00',
  }) async {
    final targetDateStr = item.expiryDate ?? item.dueDate;
    if (targetDateStr == null) return;

    final targetDate = AppDateUtils.parseDateOnly(targetDateStr);
    if (targetDate == null) return;

    for (final offset in offsetDaysList) {
      final notifId = NotificationIdGenerator.generate(item.id, offset);
      final triggerAt = calculateReminderDateTime(
        targetDate: targetDate,
        offsetDays: offset,
        preferredTime: reminderTime,
      );

      final offsetText = offset == 0
          ? 'is due today!'
          : offset == 1
              ? 'is due tomorrow!'
              : 'is due in $offset days!';

      await notificationService.scheduleNotification(
        id: notifId,
        title: '⚠️ KeepRemind: ${item.title}',
        body: '${item.title} $offsetText Please check and take action.',
        scheduledDate: triggerAt,
        payload: item.id,
      );
    }
  }

  /// Cancel all reminders for an item
  Future<void> cancelForItem({
    required String itemId,
    required List<int> offsetDaysList,
  }) async {
    for (final offset in offsetDaysList) {
      final notifId = NotificationIdGenerator.generate(itemId, offset);
      await notificationService.cancel(notifId);
    }
  }
}

