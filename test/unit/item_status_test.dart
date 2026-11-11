import 'package:flutter_test/flutter_test.dart';
import 'package:keepremind/core/enums/item_enums.dart';
import 'package:keepremind/core/utils/date_utils.dart';

void main() {
  group('Item Status & Date Derivation Tests', () {
    test('Date in the past derives as expired', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 3));
      final status = AppDateUtils.deriveStatus(targetDate: pastDate);
      expect(status, equals(ItemStatus.expired));
    });

    test('Date today derives as dueToday', () {
      final today = DateTime.now();
      final status = AppDateUtils.deriveStatus(targetDate: today);
      expect(status, equals(ItemStatus.dueToday));
    });

    test('Date in 3 days derives as upcoming', () {
      final upcomingDate = DateTime.now().add(const Duration(days: 3));
      final status = AppDateUtils.deriveStatus(targetDate: upcomingDate);
      expect(status, equals(ItemStatus.upcoming));
    });

    test('Date in 30 days derives as active', () {
      final futureDate = DateTime.now().add(const Duration(days: 30));
      final status = AppDateUtils.deriveStatus(targetDate: futureDate);
      expect(status, equals(ItemStatus.active));
    });

    test('Explicit completed flag overrides date to completed', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 10));
      final status = AppDateUtils.deriveStatus(targetDate: pastDate, isCompleted: true);
      expect(status, equals(ItemStatus.completed));
    });

    test('Explicit consumed flag overrides date to consumed', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 5));
      final status = AppDateUtils.deriveStatus(targetDate: pastDate, isConsumed: true);
      expect(status, equals(ItemStatus.consumed));
    });
  });
}

