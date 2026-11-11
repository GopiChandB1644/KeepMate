import 'dart:io';
import 'package:crypto/crypto.dart';

class DocumentIntegrityService {
  const DocumentIntegrityService();

  /// Calculate SHA-256 checksum for a file on disk
  Future<String> calculateFileChecksum(File file) async {
    if (!await file.exists()) {
      throw FileSystemException('File does not exist for checksum calculation', file.path);
    }
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  /// Calculate SHA-256 checksum for raw bytes
  String calculateBytesChecksum(List<int> bytes) {
    return sha256.convert(bytes).toString();
  }

  /// Verify that a file matches its expected SHA-256 checksum
  Future<bool> verifyFile(File file, String expectedChecksum) async {
    if (!await file.exists()) return false;
    final actual = await calculateFileChecksum(file);
    return actual.toLowerCase() == expectedChecksum.toLowerCase();
  }
}

