import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../errors/app_exceptions.dart';

class ArchiveService {
  const ArchiveService();

  /// Create a ZIP archive from a map of relative file path -> bytes
  Uint8List createArchive(Map<String, Uint8List> files) {
    final archive = Archive();
    for (final entry in files.entries) {
      final normalizedPath = entry.key.replaceAll('\\', '/');
      archive.addFile(ArchiveFile(normalizedPath, entry.value.length, entry.value));
    }
    final zipData = ZipEncoder().encode(archive);
    return Uint8List.fromList(zipData);
  }

  /// Extract a ZIP archive bytes into a map of relative path -> bytes with security checks
  Map<String, Uint8List> extractArchive(Uint8List zipData) {
    final archive = ZipDecoder().decodeBytes(zipData);
    final extracted = <String, Uint8List>{};

    for (final file in archive) {
      if (file.isFile) {
        final path = file.name.replaceAll('\\', '/');

        // Security check: reject path traversal attempts
        if (path.contains('..') || path.startsWith('/') || path.startsWith('\\')) {
          throw BackupException('Dangerous path traversal detected in archive: $path');
        }

        extracted[path] = Uint8List.fromList(file.content as List<int>);
      }
    }
    return extracted;
  }
}
