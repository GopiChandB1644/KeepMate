import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/backup/archive_service.dart';
import 'core/backup/backup_export_service.dart';
import 'core/backup/backup_import_service.dart';
import 'core/backup/backup_validation_service.dart';
import 'core/backup/encryption_service.dart';
import 'core/database/app_database.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/reminder_recovery_service.dart';
import 'core/notifications/reminder_scheduler.dart';
import 'core/storage/document_integrity_service.dart';
import 'core/storage/local_file_storage.dart';
import 'features/backup_restore/cubit/backup_cubit.dart';
import 'features/document_scanner/cubit/scanner_cubit.dart';
import 'features/document_scanner/services/ocr_parser_service.dart';
import 'features/document_vault/cubit/vault_cubit.dart';
import 'features/settings/cubit/settings_cubit.dart';
import 'features/tracked_items/cubit/items_cubit.dart';
import 'features/tracked_items/data/repositories/item_repository_impl.dart';
import 'features/tracked_items/domain/repositories/item_repository.dart';

class AppStateInjector {
  AppStateInjector._();

  static List<RepositoryProvider> repositoryProviders({
    required AppDatabase database,
    required NotificationService notificationService,
  }) {
    final integrityService = const DocumentIntegrityService();
    final fileStorage = LocalFileStorage(integrityService: integrityService);
    final reminderScheduler = ReminderScheduler(notificationService: notificationService);
    final reminderRecovery = ReminderRecoveryService(database: database, scheduler: reminderScheduler);

    final encryptionService = const EncryptionService();
    final archiveService = const ArchiveService();
    final validationService = const BackupValidationService();

    final exportService = BackupExportService(
      database: database,
      encryptionService: encryptionService,
      archiveService: archiveService,
      integrityService: integrityService,
    );

    final importService = BackupImportService(
      database: database,
      recoveryService: reminderRecovery,
      encryptionService: encryptionService,
      archiveService: archiveService,
      validationService: validationService,
    );

    final itemRepo = ItemRepositoryImpl(
      db: database,
      reminderScheduler: reminderScheduler,
    );

    return [
      RepositoryProvider<AppDatabase>.value(value: database),
      RepositoryProvider<NotificationService>.value(value: notificationService),
      RepositoryProvider<LocalFileStorage>.value(value: fileStorage),
      RepositoryProvider<ReminderScheduler>.value(value: reminderScheduler),
      RepositoryProvider<ReminderRecoveryService>.value(value: reminderRecovery),
      RepositoryProvider<BackupExportService>.value(value: exportService),
      RepositoryProvider<BackupImportService>.value(value: importService),
      RepositoryProvider<ItemRepository>.value(value: itemRepo),
    ];
  }

  static List<BlocProvider> get blocProviders => [
        BlocProvider<ItemsCubit>(
          create: (context) => ItemsCubit(
            repository: context.read<ItemRepository>(),
          ),
        ),
        BlocProvider<VaultCubit>(
          create: (context) => VaultCubit(
            database: context.read<AppDatabase>(),
            fileStorage: context.read<LocalFileStorage>(),
          ),
        ),
        BlocProvider<BackupCubit>(
          create: (context) => BackupCubit(
            exportService: context.read<BackupExportService>(),
            importService: context.read<BackupImportService>(),
            database: context.read<AppDatabase>(),
          ),
        ),
        BlocProvider<SettingsCubit>(
          create: (context) => SettingsCubit(
            database: context.read<AppDatabase>(),
            fileStorage: context.read<LocalFileStorage>(),
          ),
        ),
        BlocProvider<ScannerCubit>(
          create: (context) => ScannerCubit(
            parserService: const OcrParserService(),
          ),
        ),
      ];
}

