import 'package:drift/drift.dart';

class BillDetails extends Table {
  TextColumn get itemId => text()();
  TextColumn get providerName => text()();
  TextColumn get accountNumber => text().nullable()();
  RealColumn get amount => real().nullable()();
  TextColumn get currencyCode => text().withDefault(const Constant('INR'))();
  TextColumn get billingPeriod => text().nullable()();
  TextColumn get paymentStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {itemId};
}

class WarrantyDetails extends Table {
  TextColumn get itemId => text()();
  TextColumn get productName => text()();
  TextColumn get seller => text().nullable()();
  RealColumn get purchaseAmount => real().nullable()();
  IntColumn get warrantyDurationMonths => integer().nullable()();
  TextColumn get warrantyProvider => text().nullable()();

  @override
  Set<Column> get primaryKey => {itemId};
}

class InsuranceDetails extends Table {
  TextColumn get itemId => text()();
  TextColumn get provider => text()();
  TextColumn get policyNumber => text().nullable()();
  TextColumn get vehicleNumber => text().nullable()();
  TextColumn get coverageType => text().nullable()();
  RealColumn get premiumAmount => real().nullable()();

  @override
  Set<Column> get primaryKey => {itemId};
}

class SubscriptionDetails extends Table {
  TextColumn get itemId => text()();
  TextColumn get serviceName => text()();
  TextColumn get billingCycle => text()(); // monthly, yearly
  RealColumn get amount => real().nullable()();
  BoolColumn get autoRenew => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {itemId};
}

class PurchaseDetails extends Table {
  TextColumn get itemId => text()();
  TextColumn get productName => text()();
  TextColumn get seller => text().nullable()();
  RealColumn get purchaseAmount => real().nullable()();
  TextColumn get returnDeadline => text().nullable()();

  @override
  Set<Column> get primaryKey => {itemId};
}

class GroceryDetails extends Table {
  TextColumn get itemId => text()();
  TextColumn get productName => text()();
  TextColumn get batchNumber => text().nullable()();
  TextColumn get storageLocation => text().withDefault(const Constant('pantry'))();
  RealColumn get quantityRemaining => real().withDefault(const Constant(1.0))();
  TextColumn get quantityUnit => text().withDefault(const Constant('units'))();

  @override
  Set<Column> get primaryKey => {itemId};
}

class DocumentDetails extends Table {
  TextColumn get itemId => text()();
  TextColumn get documentNumber => text().nullable()();
  TextColumn get issuingAuthority => text().nullable()();
  TextColumn get documentType => text()();

  @override
  Set<Column> get primaryKey => {itemId};
}
