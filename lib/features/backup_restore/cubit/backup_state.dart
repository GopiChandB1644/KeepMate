import 'dart:io';
import '../../../../core/backup/backup_import_service.dart';
import '../../../../core/database/app_database.dart';

enum BackupOperationStatus {
  idle,
  exporting,
  exportSuccess,
  inspecting,
  inspectSuccess,
  restoring,
  restoreSuccess,
  failure,
}

class BackupState {
  final BackupOperationStatus status;
  final File? exportedFile;
  final BackupRestorePreview? preview;
  final List<BackupHistoryData> history;
  final String? errorMessage;
  final String? successMessage;

  const BackupState({
    this.status = BackupOperationStatus.idle,
    this.exportedFile,
    this.preview,
    this.history = const [],
    this.errorMessage,
    this.successMessage,
  });

  BackupState copyWith({
    BackupOperationStatus? status,
    File? exportedFile,
    BackupRestorePreview? preview,
    List<BackupHistoryData>? history,
    String? errorMessage,
    String? successMessage,
    bool clearPreview = false,
  }) {
    return BackupState(
      status: status ?? this.status,
      exportedFile: exportedFile ?? this.exportedFile,
      preview: clearPreview ? null : (preview ?? this.preview),
      history: history ?? this.history,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

