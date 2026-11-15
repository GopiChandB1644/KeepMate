import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/caregiver_entity.dart';
import '../../domain/entities/dose_log_entity.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/repositories/medicine_repository.dart';

class MedicineRepositoryImpl implements MedicineRepository {
  final AppDatabase db;
  final Uuid _uuid = const Uuid();

  MedicineRepositoryImpl({required this.db});

  @override
  Stream<List<MedicineEntity>> watchAllMedicines() {
    return (db.select(db.medicines)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)]))
        .watch()
        .asyncMap((medicinesList) async {
      final List<MedicineEntity> result = [];
      for (final med in medicinesList) {
        final schedules = await (db.select(db.medicineSchedules)
              ..where((s) => s.medicineId.equals(med.id))
              ..orderBy([(s) => OrderingTerm(expression: s.doseTime, mode: OrderingMode.asc)]))
            .get();
        result.add(
          MedicineEntity(
            medicine: med,
            schedules: schedules.map((s) => MedicineScheduleEntity(schedule: s)).toList(),
          ),
        );
      }
      return result;
    });
  }

  @override
  Future<List<MedicineEntity>> getAllMedicines() async {
    final list = await (db.select(db.medicines)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)]))
        .get();

    final List<MedicineEntity> result = [];
    for (final med in list) {
      final schedules = await (db.select(db.medicineSchedules)
            ..where((s) => s.medicineId.equals(med.id))
            ..orderBy([(s) => OrderingTerm(expression: s.doseTime, mode: OrderingMode.asc)]))
          .get();
      result.add(
        MedicineEntity(
          medicine: med,
          schedules: schedules.map((s) => MedicineScheduleEntity(schedule: s)).toList(),
        ),
      );
    }
    return result;
  }

  @override
  Future<MedicineEntity?> getMedicineById(String id) async {
    final med = await (db.select(db.medicines)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (med == null) return null;

    final schedules = await (db.select(db.medicineSchedules)
          ..where((s) => s.medicineId.equals(med.id))
          ..orderBy([(s) => OrderingTerm(expression: s.doseTime, mode: OrderingMode.asc)]))
        .get();

    return MedicineEntity(
      medicine: med,
      schedules: schedules.map((s) => MedicineScheduleEntity(schedule: s)).toList(),
    );
  }

  @override
  Future<void> saveMedicine({
    required MedicinesCompanion medicine,
    required List<MedicineSchedulesCompanion> schedules,
  }) async {
    await db.transaction(() async {
      await db.into(db.medicines).insertOnConflictUpdate(medicine);
      final medId = medicine.id.value;
      await (db.delete(db.medicineSchedules)..where((s) => s.medicineId.equals(medId))).go();
      for (final sched in schedules) {
        await db.into(db.medicineSchedules).insert(sched);
      }
    });
  }

  @override
  Future<void> deleteMedicine(String id) async {
    final now = DateTime.now().toIso8601String();
    await (db.update(db.medicines)..where((t) => t.id.equals(id))).write(
      MedicinesCompanion(
        isActive: const Value(false),
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Stream<List<DoseLogEntity>> watchDosesForDate(DateTime date) {
    // Watch changes on medicineDoseLogs and medicines
    return db.select(db.medicineDoseLogs).watch().asyncMap((_) async {
      return getDosesForDate(date);
    });
  }

  @override
  Future<List<DoseLogEntity>> getDosesForDate(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final weekday = date.weekday; // 1 = Monday, 7 = Sunday

    // Fetch active medicines
    final medicinesList = await getAllMedicines();

    // Fetch dose logs recorded for this date
    final existingLogs = await (db.select(db.medicineDoseLogs)
          ..where((t) => t.scheduledDate.equals(dateStr)))
        .get();

    final List<DoseLogEntity> doses = [];

    for (final med in medicinesList) {
      if (!med.isActive) continue;

      // Check date bounds
      final startDate = DateTime.tryParse(med.startDate);
      if (startDate != null) {
        final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
        final checkOnly = DateTime(date.year, date.month, date.day);
        if (checkOnly.isBefore(startOnly)) continue;
      }
      if (med.endDate != null) {
        final endDate = DateTime.tryParse(med.endDate!);
        if (endDate != null) {
          final endOnly = DateTime(endDate.year, endDate.month, endDate.day);
          final checkOnly = DateTime(date.year, date.month, date.day);
          if (checkOnly.isAfter(endOnly)) continue;
        }
      }

      for (final sched in med.schedules) {
        if (!sched.daysOfWeek.contains(weekday)) continue;

        // Match log by medicineId and scheduledTime
        final matchedLog = existingLogs.where((l) {
          return l.medicineId == med.id && l.scheduledTime == sched.doseTime;
        }).firstOrNull;

        DoseStatus status = DoseStatus.pending;
        if (matchedLog != null) {
          status = DoseStatus.fromCode(matchedLog.status);
        } else {
          // If in the past for today, check whether it is past grace period
          final now = DateTime.now();
          final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
          if (isToday) {
            final timeParts = sched.doseTime.split(':');
            if (timeParts.length == 2) {
              final doseHour = int.tryParse(timeParts[0]) ?? 0;
              final doseMinute = int.tryParse(timeParts[1]) ?? 0;
              final doseDateTime = DateTime(now.year, now.month, now.day, doseHour, doseMinute);
              // If more than 30 mins past dose time and not logged, it is unconfirmed/missed
              if (now.difference(doseDateTime).inMinutes > 30) {
                status = DoseStatus.unconfirmed;
              }
            }
          } else if (date.isBefore(DateTime(now.year, now.month, now.day))) {
            status = DoseStatus.missed;
          }
        }

        doses.add(
          DoseLogEntity(
            log: matchedLog,
            medicine: med,
            schedule: sched,
            scheduledDate: dateStr,
            scheduledTime: sched.doseTime,
            status: status,
            actionTime: matchedLog?.actionTime,
            skipReason: matchedLog?.skipReason,
            snoozeUntil: matchedLog?.snoozeUntil,
          ),
        );
      }
    }

    // Sort by scheduledTime ascending
    doses.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return doses;
  }

  @override
  Future<void> recordDoseAction({
    required String medicineId,
    String? scheduleId,
    required String scheduledDate,
    required String scheduledTime,
    required DoseStatus status,
    String? skipReason,
    String? snoozeUntil,
  }) async {
    final existing = await (db.select(db.medicineDoseLogs)
          ..where((t) =>
              t.medicineId.equals(medicineId) &
              t.scheduledDate.equals(scheduledDate) &
              t.scheduledTime.equals(scheduledTime)))
        .getSingleOrNull();

    final nowIso = DateTime.now().toIso8601String();

    if (existing != null) {
      await (db.update(db.medicineDoseLogs)..where((t) => t.id.equals(existing.id))).write(
        MedicineDoseLogsCompanion(
          status: Value(status.code),
          actionTime: Value(nowIso),
          skipReason: Value(skipReason),
          snoozeUntil: Value(snoozeUntil),
        ),
      );
    } else {
      await db.into(db.medicineDoseLogs).insert(
            MedicineDoseLogsCompanion(
              id: Value(_uuid.v4()),
              medicineId: Value(medicineId),
              scheduleId: Value(scheduleId),
              scheduledDate: Value(scheduledDate),
              scheduledTime: Value(scheduledTime),
              status: Value(status.code),
              actionTime: Value(nowIso),
              skipReason: Value(skipReason),
              snoozeUntil: Value(snoozeUntil),
              createdAt: Value(nowIso),
            ),
          );
    }
  }

  @override
  Stream<List<CaregiverEntity>> watchCaregivers() {
    return (db.select(db.caregiverContacts)
          ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)]))
        .watch()
        .map((contacts) => contacts.map((c) => CaregiverEntity(contact: c)).toList());
  }

  @override
  Future<List<CaregiverEntity>> getCaregivers() async {
    final contacts = await (db.select(db.caregiverContacts)
          ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)]))
        .get();
    return contacts.map((c) => CaregiverEntity(contact: c)).toList();
  }

  @override
  Future<void> saveCaregiver(CaregiverContactsCompanion contact) async {
    await db.into(db.caregiverContacts).insertOnConflictUpdate(contact);
  }

  @override
  Future<void> deleteCaregiver(String id) async {
    await (db.delete(db.caregiverContacts)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<DoseLogEntity>> getUnconfirmedDoses() async {
    final now = DateTime.now();
    final todayDoses = await getDosesForDate(now);
    return todayDoses.where((d) => d.status == DoseStatus.unconfirmed).toList();
  }

  @override
  Future<List<DoseLogEntity>> getAllDoseHistory() async {
    final allLogs = await (db.select(db.medicineDoseLogs)
          ..orderBy([(t) => OrderingTerm(expression: t.scheduledDate, mode: OrderingMode.desc)]))
        .get();

    final medicines = await getAllMedicines();
    final medMap = {for (final m in medicines) m.id: m};

    final List<DoseLogEntity> result = [];
    for (final log in allLogs) {
      final med = medMap[log.medicineId];
      if (med == null) continue;
      final sched = med.schedules.where((s) => s.doseTime == log.scheduledTime).firstOrNull;
      result.add(
        DoseLogEntity(
          log: log,
          medicine: med,
          schedule: sched,
          scheduledDate: log.scheduledDate,
          scheduledTime: log.scheduledTime,
          status: DoseStatus.fromCode(log.status),
          actionTime: log.actionTime,
          skipReason: log.skipReason,
          snoozeUntil: log.snoozeUntil,
        ),
      );
    }
    return result;
  }
}
