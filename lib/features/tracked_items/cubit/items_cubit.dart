import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/enums/item_enums.dart';
import '../domain/repositories/item_repository.dart';
import 'items_state.dart';

class ItemsCubit extends Cubit<ItemsState> {
  final ItemRepository repository;
  StreamSubscription? _subscription;

  ItemsCubit({required this.repository}) : super(const ItemsState()) {
    init();
  }

  void init() {
    emit(state.copyWith(status: ItemsStatus.loading));
    _subscription?.cancel();
    _subscription = repository.watchAllItems().listen(
      (items) {
        emit(state.copyWith(status: ItemsStatus.success, items: items));
      },
      onError: (err) {
        emit(state.copyWith(status: ItemsStatus.failure, errorMessage: err.toString()));
      },
    );
  }

  void search(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setCategoryFilter(ItemCategory? category) {
    if (category == null) {
      emit(state.copyWith(clearCategory: true, clearSubcategory: true));
    } else {
      emit(state.copyWith(selectedCategory: category, clearSubcategory: true));
    }
  }

  void setSubcategoryFilter(ItemSubcategory? subcategory) {
    if (subcategory == null) {
      emit(state.copyWith(clearSubcategory: true));
    } else {
      emit(state.copyWith(selectedSubcategory: subcategory));
    }
  }

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
    try {
      await repository.addItem(
        item: item,
        bill: bill,
        warranty: warranty,
        insurance: insurance,
        subscription: subscription,
        purchase: purchase,
        grocery: grocery,
        document: document,
        documents: documents,
        reminderOffsets: reminderOffsets,
        reminderTime: reminderTime,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to add item: $e'));
    }
  }

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
    try {
      await repository.updateItem(
        item: item,
        bill: bill,
        warranty: warranty,
        insurance: insurance,
        subscription: subscription,
        purchase: purchase,
        grocery: grocery,
        document: document,
        newDocuments: newDocuments,
        reminderOffsets: reminderOffsets,
        reminderTime: reminderTime,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update item: $e'));
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await repository.deleteItem(id);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete: $e'));
    }
  }

  Future<void> markPaid(String id) async {
    await repository.updateItemStatus(id, ItemStatus.completed);
  }

  Future<void> markConsumed(String id) async {
    await repository.updateItemStatus(id, ItemStatus.consumed);
  }

  Future<void> markDiscarded(String id) async {
    await repository.updateItemStatus(id, ItemStatus.discarded);
  }

  Future<String?> renewItem({
    required String oldItemId,
    required DateTime newExpiryDate,
    DateTime? newStartDate,
    String? newDocumentNumber,
    double? newAmount,
  }) async {
    try {
      final newId = await repository.renewItem(
        oldItemId: oldItemId,
        newExpiryDate: newExpiryDate,
        newStartDate: newStartDate,
        newDocumentNumber: newDocumentNumber,
        newAmount: newAmount,
      );
      return newId;
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to renew: $e'));
      return null;
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

