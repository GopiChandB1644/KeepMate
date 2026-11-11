import 'package:drift/drift.dart';

class TrackedItems extends Table {
  TextColumn get id => text()();
  TextColumn get category => text()(); // life_pocket, fresh_check, doc_alert
  TextColumn get subcategory => text()(); // bill, warranty, grocery, insurance, subscription, purchase, document
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get purchaseDate => text().nullable()();
  TextColumn get issueDate => text().nullable()();
  TextColumn get startDate => text().nullable()();
  TextColumn get dueDate => text().nullable()();
  TextColumn get expiryDate => text().nullable()();
  TextColumn get status => text()(); // active, upcoming, due_today, expired, completed, consumed, discarded, archived
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  TextColumn get previousItemId => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

