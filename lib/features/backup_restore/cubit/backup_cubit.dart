import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/backup/backup_export_service.dart';
import '../../../../core/backup/backup_import_service.dart';
import '../../../../core/database/app_database.dart';
import 'backup_state.dart';

class BackupCubit extends Cubit<BackupState> {
  final BackupExportService exportService;
  final BackupImportService importService;
  final AppDatabase database;

  BackupCubit({
    required this.exportService,
    required this.importService,
    required this.database,
  }) : super(const BackupState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final records = await (database.select(database.backupHistory)
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
          .get();
      emit(state.copyWith(history: records));
    } catch (_) {}
  }

  Future<void> createBackup({required String password}) async {
    emit(state.copyWith(status: BackupOperationStatus.exporting, errorMessage: null));
    try {
      final file = await exportService.createBackup(password: password);
      await loadHistory();
      emit(state.copyWith(
        status: BackupOperationStatus.exportSuccess,
        exportedFile: file,
        successMessage: 'Backup created successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BackupOperationStatus.failure,
        errorMessage: 'Backup failed: $e',
      ));
    }
  }

  Future<void> inspectBackupFile({
    required File file,
    required String password,
  }) async {
    emit(state.copyWith(status: BackupOperationStatus.inspecting, errorMessage: null));
    try {
      final preview = await importService.inspectBackup(
        backupFile: file,
        password: password,
      );
      emit(state.copyWith(
        status: BackupOperationStatus.inspectSuccess,
        preview: preview,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BackupOperationStatus.failure,
        errorMessage: 'Cannot open backup: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  Future<void> confirmRestore() async {
    final preview = state.preview;
    if (preview == null) return;

    emit(state.copyWith(status: BackupOperationStatus.restoring, errorMessage: null));
    try {
      await importService.executeRestore(preview);
      await loadHistory();
      emit(state.copyWith(
        status: BackupOperationStatus.restoreSuccess,
        clearPreview: true,
        successMessage: 'All records and documents restored successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BackupOperationStatus.failure,
        errorMessage: 'Restore failed: $e',
      ));
    }
  }

  Future<void> shareBackup(File file) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'KeepRemind Backup (.kmb)',
          text: 'KeepRemind password-protected backup file.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Could not open share menu: $e'));
    }
  }

  void resetStatus() {
    emit(state.copyWith(status: BackupOperationStatus.idle, errorMessage: null, successMessage: null));
  }
}
