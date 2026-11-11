import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/enums/item_enums.dart';
import '../../../../core/notifications/reminder_scheduler.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/tracked_item_entity.dart';
import '../../domain/repositories/item_repository.dart';

class ItemRepositoryImpl implements ItemRepository {
  final AppDatabase db;
  final ReminderScheduler reminderScheduler;
  final Uuid _uuid = const Uuid();

  ItemRepositoryImpl({
    required this.db,
    required this.reminderScheduler,
  });

  Future<TrackedItemEntity> _populateEntity(TrackedItem base) async {
    final bill = await (db.select(db.billDetails)..where((t) => t.itemId.equals(base.id))).getSingleOrNull();
    final warranty = await (db.select(db.warrantyDetails)..where((t) => t.itemId.equals(base.id))).getSingleOrNull();
    final insurance = await (db.select(db.insuranceDetails)..where((t) => t.itemId.equals(base.id))).getSingleOrNull();
    final subscription = await (db.select(db.subscriptionDetails)..where((t) => t.itemId.equals(base.id))).getSingleOrNull();
    final purchase = await (db.select(db.purchaseDetails)..where((t) => t.itemId.equals(base.id))).getSingleOrNull();
    final grocery = await (db.select(db.groceryDetails)..where((t) => t.itemId.equals(base.id))).getSingleOrNull();
    final doc = await (db.select(db.documentDetails)..where((t) => t.itemId.equals(base.id))).getSingleOrNull();

    final docs = await (db.select(db.itemDocuments)
          ..where((t) => t.itemId.equals(base.id) & t.deletedAt.isNull()))
        .get();

    final rules = await (db.select(db.reminderRules)..where((t) => t.itemId.equals(base.id))).get();

    return TrackedItemEntity(
      baseItem: base,
      billDetails: bill,
      warrantyDetails: warranty,
      insuranceDetails: insurance,
      subscriptionDetails: subscription,
      purchaseDetails: purchase,
      groceryDetails: grocery,
      documentDetails: doc,
      documents: docs,
      reminderRules: rules,
    );
  }

  @override
  Stream<List<TrackedItemEntity>> watchAllItems() {
    return (db.select(db.trackedItems)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
        .watch()
        .asyncMap((items) async {
      return Future.wait(items.map(_populateEntity));
    });
  }

  @override
  Future<List<TrackedItemEntity>> getAllItems() async {
    final items = await (db.select(db.trackedItems)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
        .get();
    return Future.wait(items.map(_populateEntity));
  }

  @override
  Stream<List<TrackedItemEntity>> watchItemsByCategory(ItemCategory category) {
    return (db.select(db.trackedItems)
          ..where((t) => t.category.equals(category.code) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
        .watch()
        .asyncMap((items) async {
      return Future.wait(items.map(_populateEntity));
    });
  }

  @override
  Future<List<TrackedItemEntity>> getItemsByCategory(ItemCategory category) async {
    final items = await (db.select(db.trackedItems)
          ..where((t) => t.category.equals(category.code) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
        .get();
    return Future.wait(items.map(_populateEntity));
  }

  @override
  Future<TrackedItemEntity?> getItemById(String id) async {
    final item = await (db.select(db.trackedItems)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (item == null) return null;
    return _populateEntity(item);
  }

  @override
  Future<void> addItem({
    required TrackedItemsCompanion item,
    BillDetailsCompanion? bill,
    WarrantyDetailsCompanion? warranty,
    InsuranceDetailsCompanion? insurance,
    SubscriptionDetailsCompanion? subscription,
    PurchaseDetailsCompanion? purchase,
    GroceryDetailsCompanion? grocery,
    DocumentDetailsCompanion? document,
    List<ItemDocumentsCompanion> documents = const [],
    List<int> reminderOffsets = const [],
    String reminderTime = '09:00',
  }) async {
    await db.transaction(() async {
      final itemId = item.id.value;
      await db.into(db.trackedItems).insert(item);

      if (bill != null) await db.into(db.billDetails).insert(bill);
      if (warranty != null) await db.into(db.warrantyDetails).insert(warranty);
      if (insurance != null) await db.into(db.insuranceDetails).insert(insurance);
      if (subscription != null) await db.into(db.subscriptionDetails).insert(subscription);
      if (purchase != null) await db.into(db.purchaseDetails).insert(purchase);
      if (grocery != null) await db.into(db.groceryDetails).insert(grocery);
      if (document != null) await db.into(db.documentDetails).insert(document);

      for (final doc in documents) {
        await db.into(db.itemDocuments).insert(doc);
      }

      for (final offset in reminderOffsets) {
        await db.into(db.reminderRules).insert(ReminderRulesCompanion.insert(
              id: _uuid.v4(),
              itemId: itemId,
              offsetDays: offset,
              reminderTime: Value(reminderTime),
              isEnabled: const Value(true),
              createdAt: DateTime.now().toUtc().toIso8601String(),
            ));
      }

      await db.into(db.itemHistory).insert(ItemHistoryCompanion.insert(
            id: _uuid.v4(),
            itemId: itemId,
            eventType: 'created',
            eventDataJson: const Value('{"action": "Item created"}'),
            eventAt: DateTime.now().toUtc().toIso8601String(),
          ));
    });

    final inserted = await (db.select(db.trackedItems)..where((t) => t.id.equals(item.id.value))).getSingle();
    await reminderScheduler.scheduleForItem(
      item: inserted,
      offsetDaysList: reminderOffsets,
      reminderTime: reminderTime,
    );
  }

  @override
  Future<void> updateItem({
    required TrackedItemsCompanion item,
    BillDetailsCompanion? bill,
    WarrantyDetailsCompanion? warranty,
    InsuranceDetailsCompanion? insurance,
    SubscriptionDetailsCompanion? subscription,
    PurchaseDetailsCompanion? purchase,
    GroceryDetailsCompanion? grocery,
    DocumentDetailsCompanion? document,
    List<ItemDocumentsCompanion>? newDocuments,
    List<int>? reminderOffsets,
    String? reminderTime,
  }) async {
    final itemId = item.id.value;

    await db.transaction(() async {
      await (db.update(db.trackedItems)..where((t) => t.id.equals(itemId))).write(item);

      if (bill != null) {
        await db.into(db.billDetails).insertOnConflictUpdate(bill);
      }
      if (warranty != null) {
        await db.into(db.warrantyDetails).insertOnConflictUpdate(warranty);
      }
      if (insurance != null) {
        await db.into(db.insuranceDetails).insertOnConflictUpdate(insurance);
      }
      if (subscription != null) {
        await db.into(db.subscriptionDetails).insertOnConflictUpdate(subscription);
      }
      if (purchase != null) {
        await db.into(db.purchaseDetails).insertOnConflictUpdate(purchase);
      }
      if (grocery != null) {
        await db.into(db.groceryDetails).insertOnConflictUpdate(grocery);
      }
      if (document != null) {
        await db.into(db.documentDetails).insertOnConflictUpdate(document);
      }

      if (newDocuments != null) {
        for (final doc in newDocuments) {
          await db.into(db.itemDocuments).insert(doc);
        }
      }

      if (reminderOffsets != null) {
        await (db.delete(db.reminderRules)..where((t) => t.itemId.equals(itemId))).go();
        for (final offset in reminderOffsets) {
          await db.into(db.reminderRules).insert(ReminderRulesCompanion.insert(
                id: _uuid.v4(),
                itemId: itemId,
                offsetDays: offset,
                reminderTime: Value(reminderTime ?? '09:00'),
                isEnabled: const Value(true),
                createdAt: DateTime.now().toUtc().toIso8601String(),
              ));
        }
      }

      await db.into(db.itemHistory).insert(ItemHistoryCompanion.insert(
            id: _uuid.v4(),
            itemId: itemId,
            eventType: 'edited',
            eventDataJson: const Value('{"action": "Item details updated"}'),
            eventAt: DateTime.now().toUtc().toIso8601String(),
          ));
    });

    final updated = await (db.select(db.trackedItems)..where((t) => t.id.equals(itemId))).getSingle();
    if (reminderOffsets != null) {
      await reminderScheduler.cancelForItem(itemId: itemId, offsetDaysList: [30, 7, 3, 2, 1, 0]);
      await reminderScheduler.scheduleForItem(
        item: updated,
        offsetDaysList: reminderOffsets,
        reminderTime: reminderTime ?? '09:00',
      );
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    await (db.update(db.trackedItems)..where((t) => t.id.equals(id))).write(
      TrackedItemsCompanion(
        deletedAt: Value(DateTime.now().toUtc().toIso8601String()),
        updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );

    await db.into(db.itemHistory).insert(ItemHistoryCompanion.insert(
          id: _uuid.v4(),
          itemId: id,
          eventType: 'archived',
          eventDataJson: const Value('{"action": "Item deleted / archived"}'),
          eventAt: DateTime.now().toUtc().toIso8601String(),
        ));

    await reminderScheduler.cancelForItem(itemId: id, offsetDaysList: [30, 7, 3, 2, 1, 0]);
  }

  @override
  Future<void> updateItemStatus(String id, ItemStatus status) async {
    await (db.update(db.trackedItems)..where((t) => t.id.equals(id))).write(
      TrackedItemsCompanion(
        status: Value(status.code),
        updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );

    await db.into(db.itemHistory).insert(ItemHistoryCompanion.insert(
          id: _uuid.v4(),
          itemId: id,
          eventType: status.code,
          eventDataJson: Value('{"status": "${status.label}"}'),
          eventAt: DateTime.now().toUtc().toIso8601String(),
        ));
  }

  @override
  Future<String> renewItem({
    required String oldItemId,
    required DateTime newExpiryDate,
    DateTime? newStartDate,
    String? newDocumentNumber,
    double? newAmount,
    List<ItemDocumentsCompanion>? newDocuments,
  }) async {
    final old = await getItemById(oldItemId);
    if (old == null) throw Exception('Cannot renew: original item not found');

    final newItemId = _uuid.v4();
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final newExpiryStr = AppDateUtils.formatDateOnly(newExpiryDate);
    final newStartStr = newStartDate != null ? AppDateUtils.formatDateOnly(newStartDate) : null;

    await db.transaction(() async {
      // 1. Mark old item as archived / renewed
      await (db.update(db.trackedItems)..where((t) => t.id.equals(oldItemId))).write(
        TrackedItemsCompanion(
          status: const Value('archived'),
          updatedAt: Value(nowIso),
        ),
      );

      // 2. Insert new item linked to old item
      await db.into(db.trackedItems).insert(TrackedItemsCompanion.insert(
            id: newItemId,
            category: old.baseItem.category,
            subcategory: old.baseItem.subcategory,
            title: old.baseItem.title,
            description: Value(old.baseItem.description),
            purchaseDate: Value(old.baseItem.purchaseDate),
            issueDate: Value(newStartStr ?? old.baseItem.issueDate),
            startDate: Value(newStartStr),
            dueDate: Value(newExpiryStr),
            expiryDate: Value(newExpiryStr),
            status: 'active',
            previousItemId: Value(oldItemId),
            createdAt: nowIso,
            updatedAt: nowIso,
          ));

      // 3. Duplicate and update specific category details
      if (old.insuranceDetails != null) {
        await db.into(db.insuranceDetails).insert(InsuranceDetailsCompanion.insert(
              itemId: newItemId,
              provider: old.insuranceDetails!.provider,
              policyNumber: Value(newDocumentNumber ?? old.insuranceDetails!.policyNumber),
              vehicleNumber: Value(old.insuranceDetails!.vehicleNumber),
              coverageType: Value(old.insuranceDetails!.coverageType),
              premiumAmount: Value(newAmount ?? old.insuranceDetails!.premiumAmount),
            ));
      } else if (old.billDetails != null) {
        await db.into(db.billDetails).insert(BillDetailsCompanion.insert(
              itemId: newItemId,
              providerName: old.billDetails!.providerName,
              accountNumber: Value(old.billDetails!.accountNumber),
              amount: Value(newAmount ?? old.billDetails!.amount),
              currencyCode: Value(old.billDetails!.currencyCode),
              paymentStatus: const Value('pending'),
            ));
      } else if (old.documentDetails != null) {
        await db.into(db.documentDetails).insert(DocumentDetailsCompanion.insert(
              itemId: newItemId,
              documentNumber: Value(newDocumentNumber ?? old.documentDetails!.documentNumber),
              issuingAuthority: Value(old.documentDetails!.issuingAuthority),
              documentType: old.documentDetails!.documentType,
            ));
      }

      // 4. Attach new documents if supplied
      if (newDocuments != null) {
        for (final doc in newDocuments) {
          await db.into(db.itemDocuments).insert(doc.copyWith(itemId: Value(newItemId)));
        }
      }

      // 5. Default reminder rules for renewed item
      final defaultOffsets = ReminderScheduler.getDefaultOffsets(old.subcategory);
      for (final offset in defaultOffsets) {
        await db.into(db.reminderRules).insert(ReminderRulesCompanion.insert(
              id: _uuid.v4(),
              itemId: newItemId,
              offsetDays: offset,
              reminderTime: const Value('09:00'),
              isEnabled: const Value(true),
              createdAt: nowIso,
            ));
      }

      // 6. Log history
      await db.into(db.itemHistory).insert(ItemHistoryCompanion.insert(
            id: _uuid.v4(),
            itemId: newItemId,
            eventType: 'renewed',
            eventDataJson: Value('{"renewedFrom": "$oldItemId", "newExpiry": "$newExpiryStr"}'),
            eventAt: nowIso,
          ));
    });

    // Cancel old reminders and schedule new reminders
    await reminderScheduler.cancelForItem(itemId: oldItemId, offsetDaysList: [30, 7, 3, 2, 1, 0]);
    final newItem = await (db.select(db.trackedItems)..where((t) => t.id.equals(newItemId))).getSingle();
    await reminderScheduler.scheduleForItem(
      item: newItem,
      offsetDaysList: ReminderScheduler.getDefaultOffsets(old.subcategory),
    );

    return newItemId;
  }

  @override
  Future<List<TrackedItemEntity>> searchItems(String query) async {
    final lower = '%${query.toLowerCase().trim()}%';
    final items = await (db.select(db.trackedItems)
          ..where((t) => (t.title.lower().like(lower) | t.description.lower().like(lower)) & t.deletedAt.isNull()))
        .get();
    return Future.wait(items.map(_populateEntity));
  }

  @override
  Future<List<ItemHistoryData>> getItemHistory(String itemId) {
    return (db.select(db.itemHistory)
          ..where((t) => t.itemId.equals(itemId))
          ..orderBy([(t) => OrderingTerm(expression: t.eventAt, mode: OrderingMode.desc)]))
        .get();
  }
}

