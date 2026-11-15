import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepremind/core/database/app_database.dart';
import 'package:keepremind/features/medicine_care/cubit/medicine_cubit.dart';
import 'package:keepremind/features/medicine_care/data/repositories/medicine_repository_impl.dart';
import 'package:keepremind/features/medicine_care/domain/entities/dose_log_entity.dart';
import 'package:keepremind/features/medicine_care/domain/entities/medicine_entity.dart';

void main() {
  late AppDatabase db;
  late MedicineRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = MedicineRepositoryImpl(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 1: MedicineCare Repository Tests', () {
    test('Save and retrieve medicine with multiple schedules', () async {
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await repo.saveMedicine(
        medicine: MedicinesCompanion(
          id: const drift.Value('med_1'),
          name: const drift.Value('Paracetamol'),
          medicineType: const drift.Value('tablet'),
          dosage: const drift.Value('650 mg'),
          instructions: const drift.Value('after_food'),
          doctorName: const drift.Value('Dr. Sharma'),
          startDate: drift.Value(todayStr),
          createdAt: drift.Value(now.toIso8601String()),
          updatedAt: drift.Value(now.toIso8601String()),
        ),
        schedules: [
          MedicineSchedulesCompanion(
            id: const drift.Value('sched_1'),
            medicineId: const drift.Value('med_1'),
            doseTime: const drift.Value('08:00'),
            doseLabel: const drift.Value('Morning'),
            createdAt: drift.Value(now.toIso8601String()),
          ),
          MedicineSchedulesCompanion(
            id: const drift.Value('sched_2'),
            medicineId: const drift.Value('med_1'),
            doseTime: const drift.Value('20:00'),
            doseLabel: const drift.Value('Night'),
            createdAt: drift.Value(now.toIso8601String()),
          ),
        ],
      );

      final meds = await repo.getAllMedicines();
      expect(meds.length, 1);
      expect(meds.first.name, 'Paracetamol');
      expect(meds.first.medicineType, MedicineType.tablet);
      expect(meds.first.instructions, MealInstruction.afterFood);
      expect(meds.first.doctorName, 'Dr. Sharma');
      expect(meds.first.schedules.length, 2);
      expect(meds.first.schedules[0].doseTime, '08:00');
      expect(meds.first.schedules[1].doseTime, '20:00');
    });

    test('getDosesForDate derives pending doses and allows recording taken and skipped', () async {
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await repo.saveMedicine(
        medicine: MedicinesCompanion(
          id: const drift.Value('med_2'),
          name: const drift.Value('Amoxicillin'),
          medicineType: const drift.Value('capsule'),
          dosage: const drift.Value('500 mg'),
          instructions: const drift.Value('before_food'),
          startDate: drift.Value(todayStr),
          createdAt: drift.Value(now.toIso8601String()),
          updatedAt: drift.Value(now.toIso8601String()),
        ),
        schedules: [
          MedicineSchedulesCompanion(
            id: const drift.Value('sched_3'),
            medicineId: const drift.Value('med_2'),
            doseTime: const drift.Value('09:00'),
            doseLabel: const drift.Value('Morning'),
            createdAt: drift.Value(now.toIso8601String()),
          ),
          MedicineSchedulesCompanion(
            id: const drift.Value('sched_4'),
            medicineId: const drift.Value('med_2'),
            doseTime: const drift.Value('21:00'),
            doseLabel: const drift.Value('Night'),
            createdAt: drift.Value(now.toIso8601String()),
          ),
        ],
      );

      final initialDoses = await repo.getDosesForDate(now);
      expect(initialDoses.length, 2);

      // Record first dose as taken
      await repo.recordDoseAction(
        medicineId: 'med_2',
        scheduleId: 'sched_3',
        scheduledDate: todayStr,
        scheduledTime: '09:00',
        status: DoseStatus.taken,
      );

      // Record second dose as skipped with reason
      await repo.recordDoseAction(
        medicineId: 'med_2',
        scheduleId: 'sched_4',
        scheduledDate: todayStr,
        scheduledTime: '21:00',
        status: DoseStatus.skipped,
        skipReason: 'Felt nauseous, consulted doctor',
      );

      final updatedDoses = await repo.getDosesForDate(now);
      expect(updatedDoses[0].status, DoseStatus.taken);
      expect(updatedDoses[0].isTaken, isTrue);
      expect(updatedDoses[1].status, DoseStatus.skipped);
      expect(updatedDoses[1].isSkipped, isTrue);
      expect(updatedDoses[1].skipReason, 'Felt nauseous, consulted doctor');
    });

    test('Caregiver CRUD operations work correctly', () async {
      await repo.saveCaregiver(
        CaregiverContactsCompanion(
          id: const drift.Value('cg_1'),
          name: const drift.Value('Anita (Daughter)'),
          relationship: const drift.Value('Daughter'),
          phoneOrEmail: const drift.Value('+91 9876543210'),
          gracePeriodMinutes: const drift.Value(30),
          createdAt: drift.Value(DateTime.now().toIso8601String()),
        ),
      );

      final caregivers = await repo.getCaregivers();
      expect(caregivers.length, 1);
      expect(caregivers.first.name, 'Anita (Daughter)');
      expect(caregivers.first.gracePeriodMinutes, 30);
      expect(caregivers.first.notifyUnconfirmed, isTrue);

      await repo.deleteCaregiver('cg_1');
      final afterDelete = await repo.getCaregivers();
      expect(afterDelete.isEmpty, isTrue);
    });
  });

  group('Phase 1: MedicineCubit Tests', () {
    test('MedicineCubit initializes, loads doses, and updates adherence metrics', () async {
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await repo.saveMedicine(
        medicine: MedicinesCompanion(
          id: const drift.Value('med_cubit'),
          name: const drift.Value('Metformin'),
          medicineType: const drift.Value('tablet'),
          dosage: const drift.Value('500 mg'),
          instructions: const drift.Value('after_food'),
          startDate: drift.Value(todayStr),
          createdAt: drift.Value(now.toIso8601String()),
          updatedAt: drift.Value(now.toIso8601String()),
        ),
        schedules: [
          MedicineSchedulesCompanion(
            id: const drift.Value('sched_c1'),
            medicineId: const drift.Value('med_cubit'),
            doseTime: const drift.Value('08:00'),
            createdAt: drift.Value(now.toIso8601String()),
          ),
          MedicineSchedulesCompanion(
            id: const drift.Value('sched_c2'),
            medicineId: const drift.Value('med_cubit'),
            doseTime: const drift.Value('20:00'),
            createdAt: drift.Value(now.toIso8601String()),
          ),
        ],
      );

      final cubit = MedicineCubit(repository: repo);
      // Wait for initial stream events to settle
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.medicines.length, 1);
      expect(cubit.state.todayDoses.length, 2);

      // Mark morning dose as taken
      final dose1 = cubit.state.todayDoses.first;
      await cubit.markDoseTaken(dose1);

      expect(cubit.state.takenCount, 1);
      expect(cubit.state.todayDoses[0].status, DoseStatus.taken);

      // Snooze evening dose
      final dose2 = cubit.state.todayDoses[1];
      await cubit.snoozeDose(dose2, minutes: 15);
      expect(cubit.state.todayDoses[1].status, DoseStatus.snoozed);

      await cubit.close();
    });
  });
}
