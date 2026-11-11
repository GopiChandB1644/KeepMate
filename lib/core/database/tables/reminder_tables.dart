import 'package:drift/drift.dart';

class ReminderRules extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  IntColumn get offsetDays => integer()();
  TextColumn get reminderTime => text().withDefault(const Constant('09:00'))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class ScheduledReminders extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get reminderRuleId => text()();
  IntColumn get notificationId => integer()();
  TextColumn get scheduledAt => text()();
  TextColumn get status => text()(); // pending, delivered, cancelled
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

