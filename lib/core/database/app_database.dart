import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/tracked_items_table.dart';
import 'tables/category_details_tables.dart';
import 'tables/item_documents_table.dart';
import 'tables/reminder_tables.dart';
import 'tables/app_meta_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  TrackedItems,
  BillDetails,
  WarrantyDetails,
  InsuranceDetails,
  SubscriptionDetails,
  PurchaseDetails,
  GroceryDetails,
  DocumentDetails,
  ItemDocuments,
  ReminderRules,
  ScheduledReminders,
  ItemHistory,
  AppSettings,
  BackupHistory,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? driftDatabase(name: 'keepmate'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        // Sequential migrations strategy
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON;');
      },
    );
  }
}

