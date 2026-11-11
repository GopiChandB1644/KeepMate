import '../../../../core/database/app_database.dart';

enum VaultStatus { initial, loading, success, failure }

class VaultState {
  final VaultStatus status;
  final List<ItemDocument> documents;
  final String searchQuery;
  final String? filterCategory;
  final String? errorMessage;

  const VaultState({
    this.status = VaultStatus.initial,
    this.documents = const [],
    this.searchQuery = '',
    this.filterCategory,
    this.errorMessage,
  });

  List<ItemDocument> get filteredDocuments {
    var list = documents.where((d) => d.deletedAt == null).toList();
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      list = list.where((d) => d.fileName.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  VaultState copyWith({
    VaultStatus? status,
    List<ItemDocument>? documents,
    String? searchQuery,
    String? filterCategory,
    String? errorMessage,
  }) {
    return VaultState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      searchQuery: searchQuery ?? this.searchQuery,
      filterCategory: filterCategory ?? this.filterCategory,
      errorMessage: errorMessage,
    );
  }
}

