import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../errors/app_exceptions.dart';
import 'document_integrity_service.dart';
import 'file_path_resolver.dart';

class LocalFileStorage {
  final DocumentIntegrityService integrityService;
  final Uuid _uuid = const Uuid();

  LocalFileStorage({this.integrityService = const DocumentIntegrityService()});

  /// Save an external file into KeepMate private documents folder
  /// Returns a record with relativePath, fileName, fileSize, and sha256 checksum
  Future<StoredFileMetadata> saveFile({
    required File sourceFile,
    String? preferredSubfolder,
  }) async {
    if (!await sourceFile.exists()) {
      throw const StorageException('Source file does not exist');
    }

    final ext = p.extension(sourceFile.path);
    final uniqueName = '${_uuid.v4()}$ext';
    final docsDir = await FilePathResolver.documentsDirectory;

    Directory targetDir = docsDir;
    if (preferredSubfolder != null && preferredSubfolder.isNotEmpty) {
      targetDir = Directory(p.join(docsDir.path, preferredSubfolder));
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }
    }

    final destinationFile = File(p.join(targetDir.path, uniqueName));
    await sourceFile.copy(destinationFile.path);

    final fileSize = await destinationFile.length();
    final checksum = await integrityService.calculateFileChecksum(destinationFile);
    final relativePath = await FilePathResolver.toRelativePath(destinationFile.path);

    return StoredFileMetadata(
      fileName: p.basename(sourceFile.path),
      relativePath: relativePath,
      fileSize: fileSize,
      checksum: checksum,
      absolutePath: destinationFile.path,
    );
  }

  /// Delete a file by relative path
  Future<bool> deleteFile(String relativePath) async {
    try {
      final file = await FilePathResolver.resolveRelativePath(relativePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Calculate total bytes used by app documents
  Future<int> calculateDocumentsStorageUsed() async {
    try {
      final docsDir = await FilePathResolver.documentsDirectory;
      int total = 0;
      await for (final file in docsDir.list(recursive: true, followLinks: false)) {
        if (file is File) {
          total += await file.length();
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }
}

class StoredFileMetadata {
  final String fileName;
  final String relativePath;
  final int fileSize;
  final String checksum;
  final String absolutePath;

  const StoredFileMetadata({
    required this.fileName,
    required this.relativePath,
    required this.fileSize,
    required this.checksum,
    required this.absolutePath,
  });
}

