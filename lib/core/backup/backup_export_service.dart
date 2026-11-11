import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../storage/document_integrity_service.dart';
import '../storage/file_path_resolver.dart';
import 'archive_service.dart';
import 'backup_constants.dart';
import 'backup_manifest.dart';
import 'encryption_service.dart';

class BackupExportService {
  final AppDatabase database;
  final EncryptionService encryptionService;
  final ArchiveService archiveService;
  final DocumentIntegrityService integrityService;

  BackupExportService({
    required this.database,
    this.encryptionService = const EncryptionService(),
    this.archiveService = const ArchiveService(),
    this.integrityService = const DocumentIntegrityService(),
  });

  /// Create password-protected encrypted .kmb backup file
  Future<File> createBackup({required String password}) async {
    final backupId = const Uuid().v4();
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final fileMap = <String, Uint8List>{};

    // 1. Export database snapshot to JSON
    final items = await database.select(database.trackedItems).get();
    final bills = await database.select(database.billDetails).get();
    final warranties = await database.select(database.warrantyDetails).get();
    final insurances = await database.select(database.insuranceDetails).get();
    final subs = await database.select(database.subscriptionDetails).get();
    final purchases = await database.select(database.purchaseDetails).get();
    final groceries = await database.select(database.groceryDetails).get();
    final docs = await database.select(database.documentDetails).get();
    final itemDocs = await database.select(database.itemDocuments).get();
    final rules = await database.select(database.reminderRules).get();
    final scheduled = await database.select(database.scheduledReminders).get();
    final history = await database.select(database.itemHistory).get();
    final settings = await database.select(database.appSettings).get();

    final dbData = {
      'trackedItems': items.map((e) => e.toJson()).toList(),
      'billDetails': bills.map((e) => e.toJson()).toList(),
      'warrantyDetails': warranties.map((e) => e.toJson()).toList(),
      'insuranceDetails': insurances.map((e) => e.toJson()).toList(),
      'subscriptionDetails': subs.map((e) => e.toJson()).toList(),
      'purchaseDetails': purchases.map((e) => e.toJson()).toList(),
      'groceryDetails': groceries.map((e) => e.toJson()).toList(),
      'documentDetails': docs.map((e) => e.toJson()).toList(),
      'itemDocuments': itemDocs.map((e) => e.toJson()).toList(),
      'reminderRules': rules.map((e) => e.toJson()).toList(),
      'scheduledReminders': scheduled.map((e) => e.toJson()).toList(),
      'itemHistory': history.map((e) => e.toJson()).toList(),
      'appSettings': settings.map((e) => e.toJson()).toList(),
    };

    fileMap[BackupConstants.databaseFileName] = Uint8List.fromList(utf8.encode(jsonEncode(dbData)));

    // 2. Gather all associated document files
    final documentEntries = <BackupDocumentEntry>[];
    for (final doc in itemDocs) {
      if (doc.deletedAt != null) continue;
      try {
        final diskFile = await FilePathResolver.resolveRelativePath(doc.relativePath);
        if (await diskFile.exists()) {
          final bytes = await diskFile.readAsBytes();
          final checksum = integrityService.calculateBytesChecksum(bytes);
          final archivePath = 'documents/${doc.relativePath}'.replaceAll('\\', '/');
          fileMap[archivePath] = bytes;

          documentEntries.add(BackupDocumentEntry(
            id: doc.id,
            fileName: doc.fileName,
            relativePath: doc.relativePath,
            checksumSha256: checksum,
            fileSize: bytes.length,
          ));
        }
      } catch (_) {}
    }

    // 3. Create manifest
    final manifest = BackupManifest(
      backupId: backupId,
      createdAt: nowIso,
      documentCount: documentEntries.length,
      itemCount: items.length,
      documents: documentEntries,
    );
    fileMap[BackupConstants.manifestFileName] = Uint8List.fromList(utf8.encode(manifest.encode()));

    // 4. Compress to ZIP archive
    final zipBytes = archiveService.createArchive(fileMap);

    // 5. Encrypt with password
    final encryptedBytes = encryptionService.encrypt(
      plaintext: zipBytes,
      password: password,
    );

    // 6. Write .kmb file to backups directory
    final backupsDir = await FilePathResolver.backupsDirectory;
    final dateStr = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
    final backupFile = File(p.join(backupsDir.path, 'KeepMate_Backup_$dateStr.kmb'));
    await backupFile.writeAsBytes(encryptedBytes);

    // 7. Record in backup_history table
    final checksum = integrityService.calculateBytesChecksum(encryptedBytes);
    await database.into(database.backupHistory).insert(BackupHistoryCompanion.insert(
          id: const Uuid().v4(),
          backupId: backupId,
          backupType: 'manual_encrypted',
          formatVersion: BackupConstants.currentFormatVersion,
          schemaVersion: BackupConstants.currentSchemaVersion,
          createdAt: nowIso,
          fileSize: encryptedBytes.length,
          checksum: checksum,
          destinationType: 'local_file',
          status: 'success',
          completedAt: drift.Value(DateTime.now().toUtc().toIso8601String()),
        ));

    return backupFile;
  }
}
