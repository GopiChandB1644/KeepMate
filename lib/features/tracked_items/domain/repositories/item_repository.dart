import '../../../../core/database/app_database.dart';
import '../../../../core/enums/item_enums.dart';
import '../entities/tracked_item_entity.dart';

abstract class ItemRepository {
  /// Stream or fetch all active items
  Stream<List<TrackedItemEntity>> watchAllItems();
  Future<List<TrackedItemEntity>> getAllItems();

  /// Watch or fetch items for a specific category
  Stream<List<TrackedItemEntity>> watchItemsByCategory(ItemCategory category);
  Future<List<TrackedItemEntity>> getItemsByCategory(ItemCategory category);

  /// Get single item by ID with full details
  Future<TrackedItemEntity?> getItemById(String id);

  /// Create new tracked item with all category details, documents, and reminders
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
  });

  /// Update item and category details
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
  });

  /// Soft-delete an item
  Future<void> deleteItem(String id);

  /// Update lifecycle status (e.g. marked as paid, consumed, discarded, archived)
  Future<void> updateItemStatus(String id, ItemStatus status);

  /// Renew an existing expired or renewing item (preserves old item in history & links new item)
  Future<String> renewItem({
    required String oldItemId,
    required DateTime newExpiryDate,
    DateTime? newStartDate,
    String? newDocumentNumber,
    double? newAmount,
    List<ItemDocumentsCompanion>? newDocuments,
  });

  /// Search items by title, provider, notes, etc.
  Future<List<TrackedItemEntity>> searchItems(String query);

  /// Get item lifecycle history events
  Future<List<ItemHistoryData>> getItemHistory(String itemId);
}

