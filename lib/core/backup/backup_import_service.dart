import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../errors/app_exceptions.dart';
import '../notifications/reminder_recovery_service.dart';
import '../storage/file_path_resolver.dart';
import 'archive_service.dart';
import 'backup_constants.dart';
import 'backup_manifest.dart';
import 'backup_validation_service.dart';
import 'encryption_service.dart';

class BackupRestorePreview {
  final BackupManifest manifest;
  final Map<String, dynamic> dbData;
  final Map<String, dynamic> files;

  const BackupRestorePreview({
    required this.manifest,
    required this.dbData,
    required this.files,
  });
}

class BackupImportService {
  final AppDatabase database;
  final EncryptionService encryptionService;
  final ArchiveService archiveService;
  final BackupValidationService validationService;
  final ReminderRecoveryService recoveryService;

  BackupImportService({
    required this.database,
    required this.recoveryService,
    this.encryptionService = const EncryptionService(),
    this.archiveService = const ArchiveService(),
    this.validationService = const BackupValidationService(),
  });

  /// Decrypt, unpack and inspect a .kmb backup file, returning preview for user confirmation
  Future<BackupRestorePreview> inspectBackup({
    required File backupFile,
    required String password,
  }) async {
    if (!await backupFile.exists()) {
      throw const BackupException('Selected backup file does not exist');
    }

    final containerBytes = await backupFile.readAsBytes();

    // 1. Decrypt (authenticates tag, throws if wrong password)
    final zipBytes = encryptionService.decrypt(
      container: containerBytes,
      password: password,
    );

    // 2. Unzip files
    final extractedFiles = archiveService.extractArchive(zipBytes);

    // 3. Parse manifest
    final manifestBytes = extractedFiles[BackupConstants.manifestFileName];
    if (manifestBytes == null) {
      throw const BackupException('Missing manifest in backup archive');
    }
    final manifestString = utf8.decode(manifestBytes);
    final manifest = BackupManifest.decode(manifestString);

    // 4. Validate manifest & documents
    validationService.validateManifest(manifest);
    validationService.validateDocumentIntegrity(
      manifest: manifest,
      files: extractedFiles,
    );

    // 5. Parse DB Data
    final dbBytes = extractedFiles[BackupConstants.databaseFileName] ??
        extractedFiles[BackupConstants.legacyDatabaseFileName];
    if (dbBytes == null) {
      throw const BackupException('Missing database snapshot in backup');
    }
    final dbData = jsonDecode(utf8.decode(dbBytes)) as Map<String, dynamic>;

    return BackupRestorePreview(
      manifest: manifest,
      dbData: dbData,
      files: extractedFiles,
    );
  }

  /// Execute actual restore into SQLite database and write documents to disk
  Future<void> executeRestore(BackupRestorePreview preview) async {
    // 1. Restore documents to application-private disk storage
    for (final doc in preview.manifest.documents) {
      final archivePath = 'documents/${doc.relativePath}'.replaceAll('\\', '/');
      final bytes = preview.files[archivePath];
      if (bytes != null) {
        final diskFile = await FilePathResolver.resolveRelativePath(doc.relativePath);
        if (!await diskFile.parent.exists()) {
          await diskFile.parent.create(recursive: true);
        }
        await diskFile.writeAsBytes(bytes);
      }
    }

    // 2. Perform database transaction to replace existing records
    await database.transaction(() async {
      // Clear current data
      await database.delete(database.trackedItems).go();
      await database.delete(database.billDetails).go();
      await database.delete(database.warrantyDetails).go();
      await database.delete(database.insuranceDetails).go();
      await database.delete(database.subscriptionDetails).go();
      await database.delete(database.purchaseDetails).go();
      await database.delete(database.groceryDetails).go();
      await database.delete(database.documentDetails).go();
      await database.delete(database.itemDocuments).go();
      await database.delete(database.reminderRules).go();
      await database.delete(database.scheduledReminders).go();
      await database.delete(database.itemHistory).go();

      // Populate items
      final rawItems = preview.dbData['trackedItems'] as List<dynamic>? ?? [];
      for (final itemJson in rawItems) {
        final map = itemJson as Map<String, dynamic>;
        await database.into(database.trackedItems).insert(
              TrackedItemsCompanion.insert(
                id: map['id'] as String,
                category: map['category'] as String,
                subcategory: map['subcategory'] as String,
                title: map['title'] as String,
                description: Value(map['description'] as String?),
                purchaseDate: Value(map['purchaseDate'] as String?),
                issueDate: Value(map['issueDate'] as String?),
                startDate: Value(map['startDate'] as String?),
                dueDate: Value(map['dueDate'] as String?),
                expiryDate: Value(map['expiryDate'] as String?),
                status: map['status'] as String,
                metadataJson: Value(map['metadataJson'] as String? ?? '{}'),
                previousItemId: Value(map['previousItemId'] as String?),
                createdAt: map['createdAt'] as String,
                updatedAt: map['updatedAt'] as String,
                deletedAt: Value(map['deletedAt'] as String?),
              ),
            );
      }

      // Populate category details
      for (final json in (preview.dbData['billDetails'] as List<dynamic>? ?? [])) {
        final map = json as Map<String, dynamic>;
        await database.into(database.billDetails).insert(BillDetailsCompanion.insert(
              itemId: map['itemId'] as String,
              providerName: map['providerName'] as String,
              accountNumber: Value(map['accountNumber'] as String?),
              amount: Value((map['amount'] as num?)?.toDouble()),
              currencyCode: Value(map['currencyCode'] as String? ?? 'INR'),
              billingPeriod: Value(map['billingPeriod'] as String?),
              paymentStatus: Value(map['paymentStatus'] as String? ?? 'pending'),
            ));
      }

      for (final json in (preview.dbData['warrantyDetails'] as List<dynamic>? ?? [])) {
        final map = json as Map<String, dynamic>;
        await database.into(database.warrantyDetails).insert(WarrantyDetailsCompanion.insert(
              itemId: map['itemId'] as String,
              productName: map['productName'] as String,
              seller: Value(map['seller'] as String?),
              purchaseAmount: Value((map['purchaseAmount'] as num?)?.toDouble()),
              warrantyDurationMonths: Value(map['warrantyDurationMonths'] as int?),
              warrantyProvider: Value(map['warrantyProvider'] as String?),
            ));
      }

      for (final json in (preview.dbData['insuranceDetails'] as List<dynamic>? ?? [])) {
        final map = json as Map<String, dynamic>;
        await database.into(database.insuranceDetails).insert(InsuranceDetailsCompanion.insert(
              itemId: map['itemId'] as String,
              provider: map['provider'] as String,
              policyNumber: Value(map['policyNumber'] as String?),
              vehicleNumber: Value(map['vehicleNumber'] as String?),
              coverageType: Value(map['coverageType'] as String?),
              premiumAmount: Value((map['premiumAmount'] as num?)?.toDouble()),
            ));
      }

      for (final json in (preview.dbData['subscriptionDetails'] as List<dynamic>? ?? [])) {
        final map = json as Map<String, dynamic>;
        await database.into(database.subscriptionDetails).insert(SubscriptionDetailsCompanion.insert(
              itemId: map['itemId'] as String,
              serviceName: map['serviceName'] as String,
              billingCycle: map['billingCycle'] as String,
              amount: Value((map['amount'] as num?)?.toDouble()),
              autoRenew: Value(map['autoRenew'] as bool? ?? true),
            ));
      }

      for (final json in (preview.dbData['purchaseDetails'] as List<dynamic>? ?? [])) {
        final map = json as Map<String, dynamic>;
        await database.into(database.purchaseDetails).insert(PurchaseDetailsCompanion.insert(
              itemId: map['itemId'] as String,
              productName: map['productName'] as String,
              seller: Value(map['seller'] as String?),
              purchaseAmount: Value((map['purchaseAmount'] as num?)?.toDouble()),
              returnDeadline: Value(map['returnDeadline'] as String?),
            ));
      }

      for (final json in (preview.dbData['groceryDetails'] as List<dynamic>? ?? [])) {
        final map = json as Map<String, dynamic>;
        await database.into(database.groceryDetails).insert(GroceryDetailsCompanion.insert(
              itemId: map['itemId'] as String,
              productName: map['productName'] as String,
              batchNumber: Value(map['batchNumber'] as String?),
              storageLocation: Value(map['storageLocation'] as String? ?? 'pantry'),
              quantityRemaining: Value((map['quantityRemaining'] as num?)?.toDouble() ?? 1.0),
              quantityUnit: Value(map['quantityUnit'] as String? ?? 'units'),
            ));
      }

      for (final json in (preview.dbData['documentDetails'] as List<dynamic>? ?? [])) {
        final map = json as Map<String, dynamic>;
        await database.into(database.documentDetails).insert(DocumentDetailsCompanion.insert(
              itemId: map['itemId'] as String,
              documentNumber: Value(map['documentNumber'] as String?),
              issuingAuthority: Value(map['issuingAuthority'] as String?),
              documentType: map['documentType'] as String,
            ));
      }

      // Populate item documents
      for (final json in (preview.dbData['itemDocuments'] as List<dynamic>? ?? [])) {
        final map = json as Map<String, dynamic>;
        await database.into(database.itemDocuments).insert(ItemDocumentsCompanion.insert(
              id: map['id'] as String,
              itemId: Value(map['itemId'] as String?),
              fileName: map['fileName'] as String,
              relativePath: map['relativePath'] as String,
              mimeType: map['mimeType'] as String,
              fileSize: map['fileSize'] as int,
              checksumSha256: map['checksumSha256'] as String,
              source: map['source'] as String,
              createdAt: map['createdAt'] as String,
              deletedAt: Value(map['deletedAt'] as String?),
            ));
      }

      // Populate reminder rules
      for (final json in (preview.dbData['reminderRules'] as List<dynamic>? ?? [])) {
        final map = json as Map<String, dynamic>;
        await database.into(database.reminderRules).insert(ReminderRulesCompanion.insert(
              id: map['id'] as String,
              itemId: map['itemId'] as String,
              offsetDays: map['offsetDays'] as int,
              reminderTime: Value(map['reminderTime'] as String? ?? '09:00'),
              isEnabled: Value(map['isEnabled'] as bool? ?? true),
              createdAt: map['createdAt'] as String,
            ));
      }

      // Populate item history
      for (final json in (preview.dbData['itemHistory'] as List<dynamic>? ?? [])) {
        final map = json as Map<String, dynamic>;
        await database.into(database.itemHistory).insert(ItemHistoryCompanion.insert(
              id: map['id'] as String,
              itemId: map['itemId'] as String,
              eventType: map['eventType'] as String,
              eventDataJson: Value(map['eventDataJson'] as String? ?? '{}'),
              eventAt: map['eventAt'] as String,
            ));
      }
    });

    // 3. Reconcile and replenish local notifications from restored SQLite data
    await recoveryService.reconcileAll();
  }
}

