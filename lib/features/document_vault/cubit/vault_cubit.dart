import 'dart:async';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/storage/local_file_storage.dart';
import 'vault_state.dart';

class VaultCubit extends Cubit<VaultState> {
  final AppDatabase database;
  final LocalFileStorage fileStorage;
  StreamSubscription? _subscription;
  final Uuid _uuid = const Uuid();

  VaultCubit({
    required this.database,
    required this.fileStorage,
  }) : super(const VaultState()) {
    init();
  }

  void init() {
    emit(state.copyWith(status: VaultStatus.loading));
    _subscription?.cancel();
    _subscription = (database.select(database.itemDocuments)
          ..where((tbl) => tbl.deletedAt.isNull())
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc)]))
        .watch()
        .listen(
      (docs) {
        emit(state.copyWith(status: VaultStatus.success, documents: docs));
      },
      onError: (err) {
        emit(state.copyWith(status: VaultStatus.failure, errorMessage: err.toString()));
      },
    );
  }

  void search(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<ItemDocument?> uploadDocument({
    required File file,
    String? associatedItemId,
    String source = 'upload',
  }) async {
    try {
      final stored = await fileStorage.saveFile(sourceFile: file);
      final id = _uuid.v4();
      final now = DateTime.now().toUtc().toIso8601String();

      await database.into(database.itemDocuments).insert(
            ItemDocumentsCompanion.insert(
              id: id,
              itemId: Value(associatedItemId),
              fileName: stored.fileName,
              relativePath: stored.relativePath,
              mimeType: stored.fileName.toLowerCase().endsWith('.pdf') ? 'application/pdf' : 'image/jpeg',
              fileSize: stored.fileSize,
              checksumSha256: stored.checksum,
              source: source,
              createdAt: now,
            ),
          );

      return (database.select(database.itemDocuments)..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to upload document: $e'));
      return null;
    }
  }

  Future<void> deleteDocument(ItemDocument doc) async {
    try {
      // Soft-delete in database
      await (database.update(database.itemDocuments)..where((tbl) => tbl.id.equals(doc.id))).write(
        ItemDocumentsCompanion(deletedAt: Value(DateTime.now().toUtc().toIso8601String())),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete: $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

