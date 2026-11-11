import '../../../../core/enums/item_enums.dart';
import '../domain/entities/tracked_item_entity.dart';

enum ItemsStatus { initial, loading, success, failure }

class ItemsState {
  final ItemsStatus status;
  final List<TrackedItemEntity> items;
  final String searchQuery;
  final ItemCategory? selectedCategory;
  final ItemSubcategory? selectedSubcategory;
  final String? errorMessage;

  const ItemsState({
    this.status = ItemsStatus.initial,
    this.items = const [],
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedSubcategory,
    this.errorMessage,
  });

  List<TrackedItemEntity> get displayedItems {
    var result = List<TrackedItemEntity>.from(items);

    if (selectedCategory != null) {
      result = result.where((e) => e.category == selectedCategory).toList();
    }
    if (selectedSubcategory != null) {
      result = result.where((e) => e.subcategory == selectedSubcategory).toList();
    }
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      result = result.where((e) {
        return e.title.toLowerCase().contains(q) ||
            (e.description?.toLowerCase().contains(q) ?? false) ||
            e.subcategory.displayName.toLowerCase().contains(q);
      }).toList();
    }
    return result;
  }

  // Urgent counts
  int get dueTodayCount => items.where((e) => e.status == ItemStatus.dueToday).length;
  int get upcomingCount => items.where((e) => e.status == ItemStatus.upcoming).length;
  int get expiredCount => items.where((e) => e.status == ItemStatus.expired).length;
  int get activeCount => items.where((e) => e.status == ItemStatus.active).length;

  List<TrackedItemEntity> get urgentItems => items
      .where((e) => e.status == ItemStatus.dueToday || e.status == ItemStatus.upcoming || e.status == ItemStatus.expired)
      .toList();

  List<TrackedItemEntity> get recentItems => items.take(5).toList();

  ItemsState copyWith({
    ItemsStatus? status,
    List<TrackedItemEntity>? items,
    String? searchQuery,
    ItemCategory? selectedCategory,
    ItemSubcategory? selectedSubcategory,
    String? errorMessage,
    bool clearCategory = false,
    bool clearSubcategory = false,
  }) {
    return ItemsState(
      status: status ?? this.status,
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedSubcategory: clearSubcategory ? null : (selectedSubcategory ?? this.selectedSubcategory),
      errorMessage: errorMessage,
    );
  }
}

