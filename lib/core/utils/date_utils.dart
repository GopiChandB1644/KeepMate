import 'package:intl/intl.dart';
import '../enums/item_enums.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat standardFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat displayFormat = DateFormat('dd MMM yyyy');
  static final DateFormat friendlyFormat = DateFormat('d MMM, yyyy');

  /// Parse YYYY-MM-DD string into DateTime in local time without time component
  static DateTime? parseDateOnly(String? dateString) {
    if (dateString == null || dateString.trim().isEmpty) return null;
    try {
      final parsed = DateTime.parse(dateString.trim());
      return DateTime(parsed.year, parsed.month, parsed.day);
    } catch (_) {
      return null;
    }
  }

  /// Format DateTime to YYYY-MM-DD
  static String formatDateOnly(DateTime date) {
    return standardFormat.format(date);
  }

  /// Format DateTime to readable string e.g. "15 Dec 2026"
  static String formatDisplay(DateTime? date) {
    if (date == null) return 'No date';
    return displayFormat.format(date);
  }

  /// Calculate days remaining relative to today (0 = today, negative = past)
  static int daysDifferenceFromToday(DateTime targetDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.difference(today).inDays;
  }

  /// Human-friendly relative label (e.g., "Due Today", "Expires Tomorrow", "In 5 days", "Expired 2 days ago")
  static String getRelativeTimeLabel(DateTime? date) {
    if (date == null) return 'No due date';
    final diff = daysDifferenceFromToday(date);
    if (diff == 0) return 'Due today!';
    if (diff == 1) return 'Tomorrow';
    if (diff > 1 && diff <= 30) return 'In $diff days';
    if (diff > 30) return 'In ${(diff / 30).round()} months';
    if (diff == -1) return 'Expired yesterday';
    return 'Expired ${-diff} days ago';
  }

  /// Derive lifecycle status dynamically based on target date and completion flags
  static ItemStatus deriveStatus({
    required DateTime? targetDate,
    bool isCompleted = false,
    bool isConsumed = false,
    bool isDiscarded = false,
    bool isArchived = false,
  }) {
    if (isArchived) return ItemStatus.archived;
    if (isConsumed) return ItemStatus.consumed;
    if (isDiscarded) return ItemStatus.discarded;
    if (isCompleted) return ItemStatus.completed;
    if (targetDate == null) return ItemStatus.active;

    final diff = daysDifferenceFromToday(targetDate);
    if (diff < 0) return ItemStatus.expired;
    if (diff == 0) return ItemStatus.dueToday;
    if (diff <= 7) return ItemStatus.upcoming;
    return ItemStatus.active;
  }
}

