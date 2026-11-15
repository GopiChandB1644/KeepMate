import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/tracked_items_table.dart';
import 'tables/category_details_tables.dart';
import 'tables/item_documents_table.dart';
import 'tables/reminder_tables.dart';
import 'tables/app_meta_tables.dart';
import 'tables/medicine_tables.dart';

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
  Medicines,
  MedicineSchedules,
  MedicineDoseLogs,
  CaregiverContacts,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e])
      : super(e ?? driftDatabase(name: 'keepremind'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(medicines);
          await m.createTable(medicineSchedules);
          await m.createTable(medicineDoseLogs);
          await m.createTable(caregiverContacts);
        }
        if (from < 3) {
          await m.addColumn(medicines, medicines.reminderMode);
          await m.addColumn(medicines, medicines.alarmSound);
          await m.addColumn(medicines, medicines.vibrationEnabled);
          await m.addColumn(medicines, medicines.snoozeDurationMinutes);
          await m.addColumn(medicines, medicines.maximumRingingDurationMinutes);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON;');
      },
    );
  }
}
