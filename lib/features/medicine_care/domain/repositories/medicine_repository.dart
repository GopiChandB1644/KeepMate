import '../../../../core/database/app_database.dart';
import '../entities/caregiver_entity.dart';
import '../entities/dose_log_entity.dart';
import '../entities/medicine_entity.dart';

abstract class MedicineRepository {
  Stream<List<MedicineEntity>> watchAllMedicines();
  Future<List<MedicineEntity>> getAllMedicines();
  Future<MedicineEntity?> getMedicineById(String id);
  Future<void> saveMedicine({
    required MedicinesCompanion medicine,
    required List<MedicineSchedulesCompanion> schedules,
  });
  Future<void> deleteMedicine(String id);

  Stream<List<DoseLogEntity>> watchDosesForDate(DateTime date);
  Future<List<DoseLogEntity>> getDosesForDate(DateTime date);
  Future<void> recordDoseAction({
    required String medicineId,
    String? scheduleId,
    required String scheduledDate,
    required String scheduledTime,
    required DoseStatus status,
    String? skipReason,
    String? snoozeUntil,
  });

  Stream<List<CaregiverEntity>> watchCaregivers();
  Future<List<CaregiverEntity>> getCaregivers();
  Future<void> saveCaregiver(CaregiverContactsCompanion contact);
  Future<void> deleteCaregiver(String id);

  Future<List<DoseLogEntity>> getUnconfirmedDoses();
  Future<List<DoseLogEntity>> getAllDoseHistory();
}
