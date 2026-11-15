import '../../../../core/database/app_database.dart';

enum MedicineType {
  tablet('tablet', 'Tablet', '💊'),
  capsule('capsule', 'Capsule', '💊'),
  syrup('syrup', 'Syrup', '🥄'),
  drops('drops', 'Drops', '💧'),
  injection('injection', 'Injection', '💉'),
  ointment('ointment', 'Ointment / Gel', '🧴'),
  inhaler('inhaler', 'Inhaler', '💨'),
  other('other', 'Other', '🩹');

  final String code;
  final String label;
  final String icon;
  const MedicineType(this.code, this.label, this.icon);

  static MedicineType fromCode(String code) {
    return MedicineType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => MedicineType.tablet,
    );
  }
}

enum MealInstruction {
  beforeFood('before_food', 'Before Food', '🍽️'),
  afterFood('after_food', 'After Food', '🍲'),
  withFood('with_food', 'With Food', '🥪'),
  emptyStomach('empty_stomach', 'Empty Stomach', '☕'),
  anytime('anytime', 'Anytime', '⏰');

  final String code;
  final String label;
  final String icon;
  const MealInstruction(this.code, this.label, this.icon);

  static MealInstruction fromCode(String code) {
    return MealInstruction.values.firstWhere(
      (e) => e.code == code,
      orElse: () => MealInstruction.afterFood,
    );
  }
}

enum MedicineReminderMode {
  notification('notification', 'Notification', '🔔'),
  alarm('alarm', 'Alarm Mode', '⏰');

  final String code;
  final String label;
  final String icon;
  const MedicineReminderMode(this.code, this.label, this.icon);

  static MedicineReminderMode fromCode(String? code) {
    if (code == 'alarm') return MedicineReminderMode.alarm;
    return MedicineReminderMode.notification;
  }
}

class MedicineScheduleEntity {
  final MedicineSchedule schedule;

  const MedicineScheduleEntity({required this.schedule});

  String get id => schedule.id;
  String get medicineId => schedule.medicineId;
  String get doseTime => schedule.doseTime; // HH:mm (e.g. "08:00")
  String? get doseLabel => schedule.doseLabel;
  List<int> get daysOfWeek => schedule.daysOfWeek
      .split(',')
      .where((s) => s.trim().isNotEmpty)
      .map(int.parse)
      .toList();
  bool get reminderEnabled => schedule.reminderEnabled;
}

class MedicineEntity {
  final Medicine medicine;
  final List<MedicineScheduleEntity> schedules;

  const MedicineEntity({
    required this.medicine,
    this.schedules = const [],
  });

  String get id => medicine.id;
  String get name => medicine.name;
  MedicineType get medicineType => MedicineType.fromCode(medicine.medicineType);
  String get dosage => medicine.dosage;
  MealInstruction get instructions =>
      MealInstruction.fromCode(medicine.instructions);
  String? get doctorName => medicine.doctorName;
  String? get prescriptionPath => medicine.prescriptionPath;
  String get startDate => medicine.startDate;
  String? get endDate => medicine.endDate;
  String? get notes => medicine.notes;
  bool get isActive => medicine.isActive;
  MedicineReminderMode get reminderMode =>
      MedicineReminderMode.fromCode(medicine.reminderMode);
  String? get alarmSound => medicine.alarmSound;
  bool get vibrationEnabled => medicine.vibrationEnabled;
  int get snoozeDurationMinutes => medicine.snoozeDurationMinutes;
  int get maximumRingingDurationMinutes =>
      medicine.maximumRingingDurationMinutes;
  String get createdAt => medicine.createdAt;
  String get updatedAt => medicine.updatedAt;

  MedicineEntity copyWith({
    Medicine? medicine,
    List<MedicineScheduleEntity>? schedules,
  }) {
    return MedicineEntity(
      medicine: medicine ?? this.medicine,
      schedules: schedules ?? this.schedules,
    );
  }
}
