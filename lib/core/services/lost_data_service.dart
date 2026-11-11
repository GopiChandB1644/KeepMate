import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/image_compressor.dart';

/// Global service to retrieve photos/media that Android OS preserved
/// when an external camera activity finished after killing the background process.
class LostDataService {
  LostDataService._();

  static final LostDataService instance = LostDataService._();

  final ValueNotifier<File?> recoveredFileNotifier = ValueNotifier<File?>(null);

  /// Checks if any lost camera/gallery response exists from a previous process.
  Future<File?> checkAndRecoverLostData() async {
    try {
      final picker = ImagePicker();
      final response = await picker.retrieveLostData();
      if (response.isEmpty) return null;

      final file = response.file;
      if (file != null) {
        final compressed = await ImageCompressor.compress(
          file.path,
          purpose: ImagePurpose.document,
        );
        final recoveredFile = File(compressed);
        recoveredFileNotifier.value = recoveredFile;
        debugPrint('LostDataService: Successfully recovered lost camera file at ${recoveredFile.path}');
        return recoveredFile;
      }
    } catch (e) {
      debugPrint('LostDataService error: $e');
    }
    return null;
  }

  void clearRecoveredFile() {
    recoveredFileNotifier.value = null;
  }
}

