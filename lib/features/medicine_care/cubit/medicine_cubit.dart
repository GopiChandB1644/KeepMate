import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/app_database.dart';
import '../domain/entities/caregiver_entity.dart';
import '../domain/entities/dose_log_entity.dart';
import '../domain/entities/medicine_entity.dart';
import '../domain/repositories/medicine_repository.dart';
import '../services/medicine_notification_service.dart';
import '../services/native_alarm_bridge.dart';
import 'medicine_state.dart';

class MedicineCubit extends Cubit<MedicineState> {
  final MedicineRepository repository;
  final MedicineNotificationService? notificationService;

  StreamSubscription<List<MedicineEntity>>? _medicinesSubscription;
  StreamSubscription<List<DoseLogEntity>>? _dosesSubscription;
  StreamSubscription<List<CaregiverEntity>>? _caregiversSubscription;

  MedicineCubit({
    required this.repository,
    this.notificationService,
  }) : super(MedicineState.initial()) {
    init();
  }

  void init() {
    emit(state.copyWith(isLoading: true));

    _medicinesSubscription?.cancel();
    _medicinesSubscription = repository.watchAllMedicines().listen((meds) {
      if (!isClosed) {
        emit(state.copyWith(medicines: meds, isLoading: false));
        _refreshDoses();
      }
    }, onError: (err) {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, errorMessage: err.toString()));
      }
    });

    _subscribeDosesForDate(state.selectedDate);

    _caregiversSubscription?.cancel();
    _caregiversSubscription = repository.watchCaregivers().listen((caregivers) {
      if (!isClosed) {
        emit(state.copyWith(caregivers: caregivers));
      }
    }, onError: (err) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: err.toString()));
      }
    });

    // Synchronize any pending alarm actions recorded while app was closed
    syncPendingNativeActions();
  }

  bool _isSyncingPendingActions = false;

  Future<void> syncPendingNativeActions() async {
    if (_isSyncingPendingActions) return;
    _isSyncingPendingActions = true;
    try {
      final actions = await NativeAlarmBridge().getPendingAlarmActions();
      for (final item in actions) {
        final actionId = item['actionId'] as String?;
        final action = item['action'] as String?;
        final medicineId = item['medicineId'] as String?;
        final doseTime = item['doseTime'] as String?;
        final scheduledDate = item['scheduledDate'] as String?;

        if (action == 'taken' &&
            medicineId != null &&
            doseTime != null &&
            scheduledDate != null) {
          await repository.recordDoseAction(
            medicineId: medicineId,
            scheduledDate: scheduledDate,
            scheduledTime: doseTime,
            status: DoseStatus.taken,
          );
        }
        if (actionId != null) {
          await NativeAlarmBridge().removePendingAlarmAction(actionId);
        }
      }
      if (actions.isNotEmpty) {
        await _refreshDoses();
      }
    } catch (e) {
      debugPrint('[MedicineCubit] syncPendingNativeActions error: $e');
    } finally {
      _isSyncingPendingActions = false;
    }
  }

  void _subscribeDosesForDate(DateTime date) {
    _dosesSubscription?.cancel();
    _dosesSubscription = repository.watchDosesForDate(date).listen((doses) {
      if (!isClosed) {
        emit(state.copyWith(todayDoses: doses, selectedDate: date));
      }
    });
  }

  Future<void> changeSelectedDate(DateTime date) async {
    if (!isClosed) emit(state.copyWith(selectedDate: date));
    _subscribeDosesForDate(date);
    final doses = await repository.getDosesForDate(date);
    if (!isClosed) emit(state.copyWith(todayDoses: doses));
  }

  Future<void> _refreshDoses() async {
    final doses = await repository.getDosesForDate(state.selectedDate);
    if (!isClosed) emit(state.copyWith(todayDoses: doses));
  }

  Future<void> markDoseTaken(DoseLogEntity dose) async {
    await repository.recordDoseAction(
      medicineId: dose.medicine.id,
      scheduleId: dose.schedule?.id,
      scheduledDate: dose.scheduledDate,
      scheduledTime: dose.scheduledTime,
      status: DoseStatus.taken,
    );
    await _refreshDoses();
  }

  Future<void> markDoseSkipped(DoseLogEntity dose, {String? reason}) async {
    await repository.recordDoseAction(
      medicineId: dose.medicine.id,
      scheduleId: dose.schedule?.id,
      scheduledDate: dose.scheduledDate,
      scheduledTime: dose.scheduledTime,
      status: DoseStatus.skipped,
      skipReason: reason,
    );
    await _refreshDoses();
  }

  Future<void> snoozeDose(DoseLogEntity dose, {int minutes = 15}) async {
    final snoozeUntil =
        DateTime.now().add(Duration(minutes: minutes)).toIso8601String();
    await repository.recordDoseAction(
      medicineId: dose.medicine.id,
      scheduleId: dose.schedule?.id,
      scheduledDate: dose.scheduledDate,
      scheduledTime: dose.scheduledTime,
      status: DoseStatus.snoozed,
      snoozeUntil: snoozeUntil,
    );
    if (notificationService != null) {
      await notificationService!.scheduleSnoozeNotification(
        medicineId: dose.medicine.id,
        medicineName: dose.medicine.name,
        dosage: dose.medicine.dosage,
        mealInstruction: dose.medicine.instructions.label,
        minutes: minutes,
      );
    }
    await _refreshDoses();
  }

  Future<void> saveMedicine({
    required MedicinesCompanion medicine,
    required List<MedicineSchedulesCompanion> schedules,
  }) async {
    // If medicine already exists (editing), cancel previous notification schedules first
    if (notificationService != null) {
      final existingMed = await repository.getMedicineById(medicine.id.value);
      if (existingMed != null) {
        await notificationService!
            .cancelMedicineSchedules(existingMed.id, existingMed.schedules);
      }
    }

    await repository.saveMedicine(medicine: medicine, schedules: schedules);
    if (notificationService != null) {
      final savedMed = await repository.getMedicineById(medicine.id.value);
      if (savedMed != null) {
        await notificationService!.scheduleMedicineSchedules(savedMed);
      }
    }
    await _refreshDoses();
  }

  Future<void> deleteMedicine(String id) async {
    if (notificationService != null) {
      final med = await repository.getMedicineById(id);
      if (med != null) {
        await notificationService!
            .cancelMedicineSchedules(med.id, med.schedules);
      }
    }
    await repository.deleteMedicine(id);
    await _refreshDoses();
  }

  Future<void> saveCaregiver(CaregiverContactsCompanion contact) async {
    await repository.saveCaregiver(contact);
  }

  Future<void> deleteCaregiver(String id) async {
    await repository.deleteCaregiver(id);
  }

  @override
  Future<void> close() {
    _medicinesSubscription?.cancel();
    _dosesSubscription?.cancel();
    _caregiversSubscription?.cancel();
    return super.close();
  }
}
