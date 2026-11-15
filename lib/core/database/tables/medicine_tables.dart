import 'package:drift/drift.dart';

class Medicines extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get medicineType =>
      text()(); // tablet, capsule, syrup, drops, injection, ointment
  TextColumn get dosage => text()(); // e.g. '500 mg', '1 tablet', '5 ml'
  TextColumn get instructions =>
      text()(); // before_food, after_food, with_food, empty_stomach
  TextColumn get doctorName => text().nullable()();
  TextColumn get prescriptionPath => text().nullable()();
  TextColumn get startDate => text()();
  TextColumn get endDate => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get reminderMode => text()
      .withDefault(const Constant('notification'))(); // notification or alarm
  TextColumn get alarmSound => text().nullable()();
  BoolColumn get vibrationEnabled =>
      boolean().withDefault(const Constant(true))();
  IntColumn get snoozeDurationMinutes =>
      integer().withDefault(const Constant(5))();
  IntColumn get maximumRingingDurationMinutes =>
      integer().withDefault(const Constant(10))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class MedicineSchedules extends Table {
  TextColumn get id => text()();
  TextColumn get medicineId => text()();
  TextColumn get doseTime => text()(); // '08:00', '14:00', '20:00'
  TextColumn get doseLabel =>
      text().nullable()(); // 'Morning', 'Afternoon', 'Evening', 'Night'
  TextColumn get daysOfWeek =>
      text().withDefault(const Constant('1,2,3,4,5,6,7'))();
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(true))();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class MedicineDoseLogs extends Table {
  TextColumn get id => text()();
  TextColumn get medicineId => text()();
  TextColumn get scheduleId => text().nullable()();
  TextColumn get scheduledDate => text()(); // YYYY-MM-DD
  TextColumn get scheduledTime => text()(); // HH:mm
  TextColumn get status =>
      text()(); // taken, skipped, snoozed, missed, unconfirmed
  TextColumn get actionTime => text().nullable()(); // ISO-8601 timestamp
  TextColumn get skipReason => text().nullable()();
  TextColumn get snoozeUntil => text().nullable()();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class CaregiverContacts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get relationship =>
      text()(); // Son, Daughter, Caregiver, Doctor, etc.
  TextColumn get phoneOrEmail => text()();
  IntColumn get gracePeriodMinutes =>
      integer().withDefault(const Constant(30))();
  BoolColumn get notifyUnconfirmed =>
      boolean().withDefault(const Constant(true))();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}
