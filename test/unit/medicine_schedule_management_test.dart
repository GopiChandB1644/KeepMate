import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:keepremind/core/database/app_database.dart';
import 'package:keepremind/core/notifications/notification_service.dart';
import 'package:keepremind/features/medicine_care/cubit/medicine_cubit.dart';
import 'package:keepremind/features/medicine_care/data/repositories/medicine_repository_impl.dart';
import 'package:keepremind/features/medicine_care/domain/entities/dose_log_entity.dart';
import 'package:keepremind/features/medicine_care/services/medicine_notification_service.dart';

class FakeNotificationService extends Fake implements NotificationService {
  final List<int> scheduledIds = [];
  final List<int> cancelledIds = [];

  @override
  Future<bool> scheduleZonedNotification({
    required int id,
    required String title,
    required String body,
    required dynamic scheduledDate,
    required dynamic notificationDetails,
    String? payload,
    dynamic matchDateTimeComponents,
  }) async {
    scheduledIds.add(id);
    return true;
  }

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
  }

  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async =>
      [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late MedicineRepositoryImpl repo;
  late FakeNotificationService fakeNotif;
  late MedicineNotificationService notifService;
  late MedicineCubit cubit;
  final List<MethodCall> nativeCalls = [];

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Calcutta'));

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.keepremind.app/alarm_manager'),
      (call) async {
        nativeCalls.add(call);
        switch (call.method) {
          case 'scheduleAlarm':
            return true;
          case 'cancelAlarm':
            return true;
          case 'cancelMedicineAlarms':
            return true;
          case 'getPendingAlarmActions':
            return <Map<String, dynamic>>[];
          default:
            return true;
        }
      },
    );
  });

  setUp(() {
    nativeCalls.clear();
    db = AppDatabase(NativeDatabase.memory());
    repo = MedicineRepositoryImpl(db: db);
    fakeNotif = FakeNotificationService();
    notifService = MedicineNotificationService(notificationService: fakeNotif);
    cubit = MedicineCubit(repository: repo, notificationService: notifService);
  });

  tearDown(() async {
    await cubit.close();
    await db.close();
  });

  group('Medicine Schedule Modification & Deletion Tests', () {
    test(
        'Scenario: Prescribed for 3 days afternoon (14:00), then shifted to night (21:00) '
        'cancels old alarm, schedules new alarm, and preserves past dose logs',
        () async {
      const medId = 'med-scenario-001';
      final now = DateTime.now();
      final day1 = DateTime(now.year, now.month, now.day - 2);
      final day1Str =
          '${day1.year}-${day1.month.toString().padLeft(2, '0')}-${day1.day.toString().padLeft(2, '0')}';
      final day3 = DateTime(now.year, now.month, now.day);

      // 1. Initial Prescription: Tablet X at 14:00 (Afternoon)
      await cubit.saveMedicine(
        medicine: MedicinesCompanion.insert(
          id: medId,
          name: 'Tablet X',
          medicineType: 'tablet',
          dosage: '500 mg',
          instructions: 'after_food',
          startDate: day1Str,
          reminderMode: const Value('alarm'),
          createdAt: day1.toIso8601String(),
          updatedAt: day1.toIso8601String(),
        ),
        schedules: [
          MedicineSchedulesCompanion.insert(
            id: 'sched-afternoon',
            medicineId: medId,
            doseTime: '14:00',
            createdAt: day1.toIso8601String(),
          ),
        ],
      );

      // Verify alarm scheduled for 14:00
      final initialAlarms =
          nativeCalls.where((c) => c.method == 'scheduleAlarm').toList();
      expect(initialAlarms.length, 1);
      expect(initialAlarms.first.arguments['doseTime'], '14:00');

      // 2. User takes dose on Day 1 at 14:00
      await repo.recordDoseAction(
        medicineId: medId,
        scheduledDate: day1Str,
        scheduledTime: '14:00',
        status: DoseStatus.taken,
      );

      // Day 1 doses verify taken at 14:00
      final day1DosesBefore = await repo.getDosesForDate(day1);
      expect(day1DosesBefore.length, 1);
      expect(day1DosesBefore.first.scheduledTime, '14:00');
      expect(day1DosesBefore.first.isTaken, isTrue);

      // 3. Doctor shifts Tablet X after 3 days to Night (21:00)
      nativeCalls.clear();
      await cubit.saveMedicine(
        medicine: MedicinesCompanion(
          id: const Value(medId),
          name: const Value('Tablet X'),
          medicineType: const Value('tablet'),
          dosage: const Value('500 mg'),
          instructions: const Value('after_food'),
          startDate: Value(day1Str),
          reminderMode: const Value('alarm'),
          createdAt: Value(day1.toIso8601String()),
          updatedAt: Value(now.toIso8601String()),
        ),
        schedules: [
          MedicineSchedulesCompanion.insert(
            id: 'sched-night',
            medicineId: medId,
            doseTime: '21:00',
            createdAt: now.toIso8601String(),
          ),
        ],
      );

      // Verify old alarms were cancelled and new 21:00 alarm registered
      final cancelCalls =
          nativeCalls.where((c) => c.method == 'cancelMedicineAlarms').toList();
      expect(cancelCalls.isNotEmpty, isTrue);

      final updatedAlarms =
          nativeCalls.where((c) => c.method == 'scheduleAlarm').toList();
      expect(updatedAlarms.length, 1);
      expect(updatedAlarms.first.arguments['doseTime'], '21:00');

      // 4. Critical check: Day 1 dose log at 14:00 is STILL PRESERVED!
      final day1DosesAfter = await repo.getDosesForDate(day1);
      expect(day1DosesAfter.any((d) => d.scheduledTime == '14:00' && d.isTaken),
          isTrue,
          reason:
              'Past taken dose at 14:00 must not be destroyed when schedule is shifted to 21:00');

      // 5. Today's schedule now reflects the new 21:00 timing
      final todayDoses = await repo.getDosesForDate(day3);
      expect(todayDoses.any((d) => d.scheduledTime == '21:00'), isTrue);
    });

    test(
        'Deleting medicine cancels all alarms and retains historical adherence in getAllDoseHistory',
        () async {
      const medId = 'med-delete-test';
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Save medicine
      await cubit.saveMedicine(
        medicine: MedicinesCompanion.insert(
          id: medId,
          name: 'Amoxicillin',
          medicineType: 'capsule',
          dosage: '250 mg',
          instructions: 'before_food',
          startDate: dateStr,
          reminderMode: const Value('alarm'),
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        ),
        schedules: [
          MedicineSchedulesCompanion.insert(
            id: 'sched-amox',
            medicineId: medId,
            doseTime: '08:00',
            createdAt: now.toIso8601String(),
          ),
        ],
      );

      // Record dose as taken
      await repo.recordDoseAction(
        medicineId: medId,
        scheduledDate: dateStr,
        scheduledTime: '08:00',
        status: DoseStatus.taken,
      );

      // Delete the medicine
      nativeCalls.clear();
      fakeNotif.cancelledIds.clear();
      await cubit.deleteMedicine(medId);

      // Check alarms and notifications were cancelled
      expect(
          nativeCalls.any((c) => c.method == 'cancelMedicineAlarms'), isTrue);
      expect(fakeNotif.cancelledIds.isNotEmpty, isTrue);

      // Medicine is no longer in active list
      final activeMeds = await repo.getAllMedicines();
      expect(activeMeds.any((m) => m.id == medId), isFalse);

      // BUT historical adherence dose log is preserved in getAllDoseHistory!
      final history = await repo.getAllDoseHistory();
      expect(history.any((d) => d.medicine.id == medId && d.isTaken), isTrue,
          reason:
              'Deleted medicine historical logs must be preserved for medical adherence tracking');
    });
  });
}
