import 'package:drift/drift.dart';

class ItemHistory extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get eventType => text()(); // created, edited, renewed, paid, consumed, discarded, archived
  TextColumn get eventDataJson => text().withDefault(const Constant('{}'))();
  TextColumn get eventAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get id => text()();
  TextColumn get settingKey => text().unique()();
  TextColumn get settingValue => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class BackupHistory extends Table {
  TextColumn get id => text()();
  TextColumn get backupId => text()();
  TextColumn get backupType => text()();
  IntColumn get formatVersion => integer()();
  IntColumn get schemaVersion => integer()();
  TextColumn get createdAt => text()();
  IntColumn get fileSize => integer()();
  TextColumn get checksum => text()();
  TextColumn get destinationType => text()();
  TextColumn get status => text()();
  TextColumn get completedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

