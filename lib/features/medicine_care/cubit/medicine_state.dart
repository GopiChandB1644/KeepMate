import 'package:intl/intl.dart';
import '../domain/entities/caregiver_entity.dart';
import '../domain/entities/dose_log_entity.dart';
import '../domain/entities/medicine_entity.dart';

class MedicineState {
  final List<MedicineEntity> medicines;
  final List<DoseLogEntity> todayDoses;
  final List<CaregiverEntity> caregivers;
  final DateTime selectedDate;
  final bool isLoading;
  final String? errorMessage;

  const MedicineState({
    this.medicines = const [],
    this.todayDoses = const [],
    this.caregivers = const [],
    required this.selectedDate,
    this.isLoading = false,
    this.errorMessage,
  });

  factory MedicineState.initial() {
    return MedicineState(
      selectedDate: DateTime.now(),
      isLoading: true,
    );
  }

  MedicineState copyWith({
    List<MedicineEntity>? medicines,
    List<DoseLogEntity>? todayDoses,
    List<CaregiverEntity>? caregivers,
    DateTime? selectedDate,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MedicineState(
      medicines: medicines ?? this.medicines,
      todayDoses: todayDoses ?? this.todayDoses,
      caregivers: caregivers ?? this.caregivers,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  // Statistics & helpers
  int get takenCount =>
      todayDoses.where((d) => d.status == DoseStatus.taken).length;
  int get pendingCount => todayDoses
      .where((d) =>
          d.status == DoseStatus.pending || d.status == DoseStatus.snoozed)
      .length;
  int get skippedCount =>
      todayDoses.where((d) => d.status == DoseStatus.skipped).length;
  int get unconfirmedCount => todayDoses
      .where((d) =>
          d.status == DoseStatus.unconfirmed || d.status == DoseStatus.missed)
      .length;
  int get totalDosesCount => todayDoses.length;

  double get adherenceRate {
    if (todayDoses.isEmpty) return 1.0;
    final actionable = todayDoses
        .where((d) =>
            d.status != DoseStatus.pending && d.status != DoseStatus.snoozed)
        .toList();
    if (actionable.isEmpty) return 1.0;
    return takenCount / actionable.length;
  }

  DoseLogEntity? get nextDose {
    if (todayDoses.isEmpty) return null;
    final nowTime = DateFormat('HH:mm').format(DateTime.now());
    // Find first pending or snoozed dose at or after nowTime
    final upcoming = todayDoses.where((d) {
      return (d.status == DoseStatus.pending ||
              d.status == DoseStatus.snoozed) &&
          d.scheduledTime.compareTo(nowTime) >= 0;
    }).toList();
    if (upcoming.isNotEmpty) return upcoming.first;

    // Otherwise find any pending dose from earlier today
    final remaining = todayDoses
        .where((d) =>
            d.status == DoseStatus.pending || d.status == DoseStatus.snoozed)
        .toList();
    if (remaining.isNotEmpty) return remaining.first;

    return null;
  }
}
