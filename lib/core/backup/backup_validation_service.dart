import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import '../errors/app_exceptions.dart';
import 'backup_constants.dart';
import 'backup_manifest.dart';

class BackupValidationService {
  const BackupValidationService();

  void validateManifest(BackupManifest manifest) {
    if (manifest.formatVersion > BackupConstants.currentFormatVersion) {
      throw BackupException('Unsupported backup format version: ${manifest.formatVersion}');
    }
    if (manifest.schemaVersion > BackupConstants.currentSchemaVersion) {
      throw BackupException('Unsupported SQLite schema version: ${manifest.schemaVersion}');
    }
  }

  void validateDocumentIntegrity({
    required BackupManifest manifest,
    required Map<String, Uint8List> files,
  }) {
    for (final doc in manifest.documents) {
      final docPath = 'documents/${doc.relativePath}'.replaceAll('\\', '/');
      final bytes = files[docPath];
      if (bytes == null) {
        throw BackupException('Missing document in backup: ${doc.fileName}');
      }

      final actualChecksum = sha256.convert(bytes).toString();
      if (actualChecksum.toLowerCase() != doc.checksumSha256.toLowerCase()) {
        throw BackupException('Checksum mismatch for document: ${doc.fileName}');
      }
    }
  }
}

