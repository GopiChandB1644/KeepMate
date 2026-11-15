import 'package:flutter_test/flutter_test.dart';
import 'package:keepremind/core/database/app_database.dart';
import 'package:keepremind/core/enums/item_enums.dart';
import 'package:keepremind/core/notifications/notification_id_generator.dart';
import 'package:keepremind/core/notifications/notification_service.dart';
import 'package:keepremind/core/notifications/reminder_scheduler.dart';

class MockNotificationService extends NotificationService {
  final List<Map<String, dynamic>> scheduledCalls = [];

  @override
  Future<bool> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    scheduledCalls.add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate,
      'payload': payload,
    });
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockNotificationService mockNotificationService;
  late ReminderScheduler scheduler;

  setUp(() {
    mockNotificationService = MockNotificationService();
    scheduler = ReminderScheduler(notificationService: mockNotificationService);
  });

  group('All Categories Reminder Scheduling Tests', () {
    test('Default offsets are properly assigned for all categories', () {
      // LifePocket
      expect(ReminderScheduler.getDefaultOffsets(ItemSubcategory.bill), [3, 1]);
      expect(ReminderScheduler.getDefaultOffsets(ItemSubcategory.subscription),
          [3, 1]);
      expect(ReminderScheduler.getDefaultOffsets(ItemSubcategory.warranty),
          [30, 7, 1]);
      expect(ReminderScheduler.getDefaultOffsets(ItemSubcategory.purchase),
          [7, 1]);

      // FreshCheck
      expect(
          ReminderScheduler.getDefaultOffsets(ItemSubcategory.grocery), [2, 1]);

      // DocAlert
      expect(ReminderScheduler.getDefaultOffsets(ItemSubcategory.document),
          [30, 7, 1]);
      expect(ReminderScheduler.getDefaultOffsets(ItemSubcategory.insurance),
          [30, 7, 1]);
    });

    test('LifePocket Warranty: schedules 30, 7, and 1 day offsets correctly',
        () async {
      final now = DateTime.now();
      final futureDate = now.add(const Duration(days: 45));
      final dateStr =
          '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}';

      final item = TrackedItem(
        id: 'item_warranty_1',
        category: 'life_pocket',
        subcategory: 'warranty',
        title: 'MacBook Pro Warranty',
        expiryDate: dateStr,
        status: 'active',
        metadataJson: '{}',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      );

      await scheduler.scheduleForItem(
        item: item,
        offsetDaysList: [30, 7, 1],
        reminderTime: '09:00',
      );

      expect(mockNotificationService.scheduledCalls.length, 3);
      for (final call in mockNotificationService.scheduledCalls) {
        expect(call['title'], contains('MacBook Pro Warranty'));
        expect(call['payload'], 'item_warranty_1');
      }
    });

    test(
        'FreshCheck Grocery: schedules offsets and ensures zero offset due today alerts',
        () async {
      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final item = TrackedItem(
        id: 'item_grocery_1',
        category: 'fresh_check',
        subcategory: 'grocery',
        title: 'Organic Milk',
        expiryDate: todayStr,
        status: 'active',
        metadataJson: '{}',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      );

      await scheduler.scheduleForItem(
        item: item,
        offsetDaysList: [0], // expiring today!
        reminderTime: '08:00',
      );

      expect(mockNotificationService.scheduledCalls.length, 1);
      final call = mockNotificationService.scheduledCalls.first;
      expect(call['title'], contains('Organic Milk'));
      expect(call['body'], contains('is due today!'));
      final scheduled = call['scheduledDate'] as DateTime;
      // Must not be in the past:
      expect(
          scheduled.isAfter(now.subtract(const Duration(seconds: 1))), isTrue);
    });

    test(
        'DocAlert Document & Insurance: IDs are uniquely generated for multiple offsets',
        () {
      final id30 = NotificationIdGenerator.generate('doc_passport', 30);
      final id7 = NotificationIdGenerator.generate('doc_passport', 7);
      final id1 = NotificationIdGenerator.generate('doc_passport', 1);

      expect(id30, isNot(equals(id7)));
      expect(id7, isNot(equals(id1)));
      expect(id30 > 0, isTrue);
      expect(id7 > 0, isTrue);
      expect(id1 > 0, isTrue);
    });
  });
}
