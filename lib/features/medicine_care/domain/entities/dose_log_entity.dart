import '../../../../core/database/app_database.dart';
import 'medicine_entity.dart';

enum DoseStatus {
  taken('taken', 'Taken', 0xFF16A95A),
  skipped('skipped', 'Skipped', 0xFF6C7382),
  snoozed('snoozed', 'Snoozed', 0xFFE08600),
  missed('missed', 'Missed', 0xFFE5484D),
  pending('pending', 'Pending', 0xFF3B82F6),
  unconfirmed('unconfirmed', 'Unconfirmed', 0xFFF59E0B);

  final String code;
  final String label;
  final int colorValue;
  const DoseStatus(this.code, this.label, this.colorValue);

  static DoseStatus fromCode(String code) {
    return DoseStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => DoseStatus.pending,
    );
  }
}

class DoseLogEntity {
  final MedicineDoseLog? log;
  final MedicineEntity medicine;
  final MedicineScheduleEntity? schedule;
  final String scheduledDate; // YYYY-MM-DD
  final String scheduledTime; // HH:mm
  final DoseStatus status;
  final String? actionTime;
  final String? skipReason;
  final String? snoozeUntil;

  const DoseLogEntity({
    this.log,
    required this.medicine,
    this.schedule,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.status,
    this.actionTime,
    this.skipReason,
    this.snoozeUntil,
  });

  String get id => log?.id ?? '${medicine.id}_${scheduledDate}_$scheduledTime';
  bool get isTaken => status == DoseStatus.taken;
  bool get isSkipped => status == DoseStatus.skipped;
  bool get isPending => status == DoseStatus.pending || status == DoseStatus.snoozed;
  bool get isMissed => status == DoseStatus.missed || status == DoseStatus.unconfirmed;
}
