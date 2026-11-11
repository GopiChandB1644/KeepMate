import 'package:drift/drift.dart';

class ItemDocuments extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text().nullable()();
  TextColumn get fileName => text()();
  TextColumn get relativePath => text()();
  TextColumn get mimeType => text()();
  IntColumn get fileSize => integer()();
  TextColumn get checksumSha256 => text()();
  TextColumn get source => text()(); // camera, gallery, upload
  TextColumn get createdAt => text()();
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

