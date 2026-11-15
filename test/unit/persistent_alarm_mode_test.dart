import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show PendingNotificationRequest;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:keepremind/core/database/app_database.dart';
import 'package:keepremind/core/notifications/notification_service.dart';
import 'package:keepremind/features/medicine_care/cubit/medicine_cubit.dart';
import 'package:keepremind/features/medicine_care/data/repositories/medicine_repository_impl.dart';
import 'package:keepremind/features/medicine_care/domain/entities/dose_log_entity.dart';
import 'package:keepremind/features/medicine_care/domain/entities/medicine_entity.dart';
import 'package:keepremind/features/medicine_care/services/medicine_notification_service.dart';
import 'package:keepremind/features/medicine_care/services/native_alarm_bridge.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class FakeNotificationService extends NotificationService {
  final List<int> scheduledNotificationIds = [];
  final List<int> cancelledNotificationIds = [];

  @override
  Future<void> init() async {}

  @override
  Future<bool> scheduleZonedNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required dynamic notificationDetails,
    dynamic matchDateTimeComponents,
    String? payload,
  }) async {
    scheduledNotificationIds.add(id);
    return true;
  }

  @override
  Future<void> cancel(int id) async {
    cancelledNotificationIds.add(id);
  }

  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async =>
      [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late MedicineRepositoryImpl repo;
  late FakeNotificationService fakeNotifService;
  late MedicineNotificationService medicineNotifService;

  final List<MethodCall> nativeMethodCalls = [];

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Calcutta'));
  });

  setUp(() {
    nativeMethodCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('com.keepremind.app/alarm_manager'),
            (call) async {
      nativeMethodCalls.add(call);
      switch (call.method) {
        case 'scheduleAlarm':
        case 'cancelAlarm':
        case 'cancelMedicineAlarms':
        case 'cancelAllAlarms':
        case 'stopActiveAlarm':
          return true;
        case 'canScheduleExactAlarms':
        case 'canUseFullScreenIntent':
          return true;
        case 'getPendingAlarmActions':
          return <Map<String, dynamic>>[];
        default:
          return null;
      }
    });

    db = AppDatabase(NativeDatabase.memory());
    repo = MedicineRepositoryImpl(db: db);
    fakeNotifService = FakeNotificationService();
    medicineNotifService = MedicineNotificationService(
      notificationService: fakeNotifService,
      nativeAlarmBridge: NativeAlarmBridge(),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Persistent Alarm Mode & Notification Mode Tests', () {
    test('MedicineReminderMode enum parses correctly and defaults safely', () {
      expect(
          MedicineReminderMode.fromCode('alarm'), MedicineReminderMode.alarm);
      expect(MedicineReminderMode.fromCode('notification'),
          MedicineReminderMode.notification);
      expect(MedicineReminderMode.fromCode('unknown'),
          MedicineReminderMode.notification);
      expect(MedicineReminderMode.fromCode(null),
          MedicineReminderMode.notification);
    });

    test('Drift database persists Alarm Mode settings with schema version 3',
        () async {
      const medId = 'med-alarm-001';
      final now = DateTime.now().toIso8601String();

      await repo.saveMedicine(
        medicine: MedicinesCompanion.insert(
          id: medId,
          name: 'Metformin',
          medicineType: 'tablet',
          dosage: '500 mg',
          instructions: 'after_food',
          startDate: '2026-11-15',
          reminderMode: const Value('alarm'),
          vibrationEnabled: const Value(true),
          snoozeDurationMinutes: const Value(5),
          maximumRingingDurationMinutes: const Value(10),
          createdAt: now,
          updatedAt: now,
        ),
        schedules: [
          MedicineSchedulesCompanion.insert(
            id: 'sched-001',
            medicineId: medId,
            doseTime: '08:00',
            createdAt: now,
          ),
        ],
      );

      final fetched = await repo.getMedicineById(medId);
      expect(fetched, isNotNull);
      expect(fetched!.reminderMode, MedicineReminderMode.alarm);
      expect(fetched.vibrationEnabled, isTrue);
      expect(fetched.snoozeDurationMinutes, 5);
      expect(fetched.maximumRingingDurationMinutes, 10);
    });

    test('Alarm Mode routes to NativeAlarmBridge and NOT local notifications',
        () async {
      const medId = 'med-alarm-002';
      final now = DateTime.now().toIso8601String();

      await repo.saveMedicine(
        medicine: MedicinesCompanion.insert(
          id: medId,
          name: 'Atorvastatin',
          medicineType: 'tablet',
          dosage: '10 mg',
          instructions: 'after_food',
          startDate: '2026-11-15',
          reminderMode: const Value('alarm'),
          snoozeDurationMinutes: const Value(5),
          maximumRingingDurationMinutes: const Value(10),
          createdAt: now,
          updatedAt: now,
        ),
        schedules: [
          MedicineSchedulesCompanion.insert(
            id: 'sched-002',
            medicineId: medId,
            doseTime: '21:00',
            createdAt: now,
          ),
        ],
      );

      final med = (await repo.getMedicineById(medId))!;
      final ids = await medicineNotifService.scheduleMedicineSchedules(med);

      expect(ids.isNotEmpty, isTrue);
      // Native Alarm Bridge must have received scheduleAlarm call
      final scheduleCalls =
          nativeMethodCalls.where((c) => c.method == 'scheduleAlarm').toList();
      expect(scheduleCalls.length, 1);
      expect(scheduleCalls.first.arguments['medicineId'], medId);
      expect(scheduleCalls.first.arguments['medicineName'], 'Atorvastatin');
      expect(scheduleCalls.first.arguments['snoozeMinutes'], 5);
      expect(scheduleCalls.first.arguments['maxDurationMinutes'], 10);

      // Local notification must NOT have scheduled zoned notification for Alarm Mode!
      expect(fakeNotifService.scheduledNotificationIds.isEmpty, isTrue);
    });

    test(
        'Notification Mode routes to local notifications and clears any native alarm',
        () async {
      const medId = 'med-notif-001';
      final now = DateTime.now().toIso8601String();

      await repo.saveMedicine(
        medicine: MedicinesCompanion.insert(
          id: medId,
          name: 'Paracetamol',
          medicineType: 'tablet',
          dosage: '650 mg',
          instructions: 'after_food',
          startDate: '2026-11-15',
          reminderMode: const Value('notification'),
          createdAt: now,
          updatedAt: now,
        ),
        schedules: [
          MedicineSchedulesCompanion.insert(
            id: 'sched-003',
            medicineId: medId,
            doseTime: '14:00',
            createdAt: now,
          ),
        ],
      );

      final med = (await repo.getMedicineById(medId))!;
      final ids = await medicineNotifService.scheduleMedicineSchedules(med);

      expect(ids.isNotEmpty, isTrue);
      // Local notification scheduled
      expect(fakeNotifService.scheduledNotificationIds.length, 1);

      // Native bridge was asked to cancel any native alarm for that ID
      final cancelCalls =
          nativeMethodCalls.where((c) => c.method == 'cancelAlarm').toList();
      expect(cancelCalls.isNotEmpty, isTrue);
    });

    test(
        'cancelMedicineSchedules clears both notification service and native alarms',
        () async {
      const medId = 'med-cancel-001';
      final now = DateTime.now().toIso8601String();

      await repo.saveMedicine(
        medicine: MedicinesCompanion.insert(
          id: medId,
          name: 'Amoxicillin',
          medicineType: 'capsule',
          dosage: '500 mg',
          instructions: 'after_food',
          startDate: '2026-11-15',
          reminderMode: const Value('alarm'),
          createdAt: now,
          updatedAt: now,
        ),
        schedules: [
          MedicineSchedulesCompanion.insert(
            id: 'sched-004',
            medicineId: medId,
            doseTime: '09:00',
            createdAt: now,
          ),
        ],
      );

      final med = (await repo.getMedicineById(medId))!;
      await medicineNotifService.cancelMedicineSchedules(med.id, med.schedules);

      // NotificationService cancel called
      expect(fakeNotifService.cancelledNotificationIds.length, 1);

      // NativeAlarmBridge cancelMedicineAlarms called
      final cancelMedCalls = nativeMethodCalls
          .where((c) => c.method == 'cancelMedicineAlarms')
          .toList();
      expect(cancelMedCalls.length, 1);
      expect(cancelMedCalls.first.arguments['medicineId'], medId);
    });

    test('MedicineCubit synchronizes offline pending native alarm actions',
        () async {
      const medId = 'med-sync-001';
      final now = DateTime.now().toIso8601String();

      await repo.saveMedicine(
        medicine: MedicinesCompanion.insert(
          id: medId,
          name: 'Thyroxine',
          medicineType: 'tablet',
          dosage: '50 mcg',
          instructions: 'empty_stomach',
          startDate: '2026-11-15',
          reminderMode: const Value('alarm'),
          createdAt: now,
          updatedAt: now,
        ),
        schedules: [
          MedicineSchedulesCompanion.insert(
            id: 'sched-005',
            medicineId: medId,
            doseTime: '06:30',
            createdAt: now,
          ),
        ],
      );

      // Mock pending action from native Kotlin AlarmActivity
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('com.keepremind.app/alarm_manager'),
              (call) async {
        if (call.method == 'getPendingAlarmActions') {
          return [
            {
              'actionId': 'act-12345',
              'action': 'taken',
              'medicineId': medId,
              'doseTime': '06:30',
              'scheduledDate': '2026-11-15',
            }
          ];
        }
        return true;
      });

      final cubit = MedicineCubit(
        repository: repo,
        notificationService: medicineNotifService,
      );

      await cubit.syncPendingNativeActions();

      final doses = await repo.getDosesForDate(DateTime(2026, 11, 15));
      final takenDose = doses.firstWhere((d) => d.medicine.id == medId);
      expect(takenDose.status, DoseStatus.taken);

      await cubit.close();
    });

    test(
        'Completed medicine (past end date) cancels alerts and skips scheduling',
        () async {
      const medId = 'med-completed-001';
      final now = DateTime.now().toIso8601String();

      await repo.saveMedicine(
        medicine: MedicinesCompanion.insert(
          id: medId,
          name: 'Antibiotic Course Completed',
          medicineType: 'capsule',
          dosage: '250 mg',
          instructions: 'after_food',
          startDate: '2026-11-01',
          endDate: const Value('2026-11-10'), // Ended in the past
          reminderMode: const Value('alarm'),
          createdAt: now,
          updatedAt: now,
        ),
        schedules: [
          MedicineSchedulesCompanion.insert(
            id: 'sched-completed-001',
            medicineId: medId,
            doseTime: '08:00',
            createdAt: now,
          ),
        ],
      );

      final med = (await repo.getMedicineById(medId))!;
      final ids = await medicineNotifService.scheduleMedicineSchedules(med);

      // Should skip scheduling any future alarms
      expect(ids.isEmpty, isTrue);
    });

    test('Disabled schedule does not register alarm or notification', () async {
      const medId = 'med-disabled-001';
      final now = DateTime.now().toIso8601String();

      await repo.saveMedicine(
        medicine: MedicinesCompanion.insert(
          id: medId,
          name: 'Vitamin D',
          medicineType: 'tablet',
          dosage: '1000 IU',
          instructions: 'with_food',
          startDate: '2026-11-15',
          reminderMode: const Value('alarm'),
          createdAt: now,
          updatedAt: now,
        ),
        schedules: [
          MedicineSchedulesCompanion.insert(
            id: 'sched-disabled-001',
            medicineId: medId,
            doseTime: '10:00',
            reminderEnabled: const Value(false), // Disabled
            createdAt: now,
          ),
        ],
      );

      final med = (await repo.getMedicineById(medId))!;
      final ids = await medicineNotifService.scheduleMedicineSchedules(med);

      expect(ids.isEmpty, isTrue);
    });

    test(
        'Duplicate dose recordings update in place and never insert duplicate rows',
        () async {
      const medId = 'med-dup-check';
      const scheduledDate = '2026-11-15';
      const doseTime = '08:00';

      // Record first taken
      await repo.recordDoseAction(
        medicineId: medId,
        scheduledDate: scheduledDate,
        scheduledTime: doseTime,
        status: DoseStatus.taken,
      );

      // Record second taken for same dose
      await repo.recordDoseAction(
        medicineId: medId,
        scheduledDate: scheduledDate,
        scheduledTime: doseTime,
        status: DoseStatus.taken,
      );

      final count = await (db.select(db.medicineDoseLogs)
            ..where((t) =>
                t.medicineId.equals(medId) &
                t.scheduledDate.equals(scheduledDate) &
                t.scheduledTime.equals(doseTime)))
          .get();

      expect(count.length, 1);
    });
  });
}
