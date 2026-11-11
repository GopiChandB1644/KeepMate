import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// What the image is for: decides how much detail must survive.
enum ImagePurpose {
  /// Bills, licences, warranties, IDs — text must stay sharp and readable.
  document(minSide: 1600, maxKb: 800),

  /// General photos and item attachments.
  photo(minSide: 1280, maxKb: 500);

  const ImagePurpose({required this.minSide, required this.maxKb});

  /// The shorter side is scaled down to about this many pixels (never up).
  final int minSide;

  /// Quality is lowered step by step until the file fits under this.
  final int maxKb;
}

/// Shrinks camera / gallery images before storage: resizes, re-encodes as
/// JPEG, fixes orientation and strips heavy metadata.
///
/// Never fails an upload: if compression isn't possible the original file
/// is returned unchanged.
class ImageCompressor {
  ImageCompressor._();

  static const int _startQuality = 85;
  static const int _minQuality = 35;

  /// Compressed copy of [path] for [purpose], or [path] itself when it is
  /// already small enough or cannot be compressed.
  static Future<String> compress(String path, {ImagePurpose purpose = ImagePurpose.document}) async {
    if (kIsWeb) return path;
    try {
      final source = File(path);
      if (!await source.exists()) return path;

      final originalKb = await source.length() ~/ 1024;
      if (originalKb <= purpose.maxKb && _isJpeg(path)) return path;

      final target = '${source.parent.path}/${_baseName(path)}_${DateTime.now().microsecondsSinceEpoch}_c.jpg';
      var quality = _startQuality;
      XFile? out;
      var outKb = 0;
      do {
        out = await FlutterImageCompress.compressAndGetFile(
          source.absolute.path,
          target,
          quality: quality,
          minWidth: purpose.minSide,
          minHeight: purpose.minSide,
          format: CompressFormat.jpeg,
        );
        if (out == null) return path;
        outKb = await out.length() ~/ 1024;
        quality -= 10;
      } while (outKb > purpose.maxKb && quality >= _minQuality);

      debugPrint('ImageCompressor(${purpose.name}): ${originalKb}KB -> ${outKb}KB at q${quality + 10}');
      return outKb < originalKb ? out.path : path;
    } catch (e) {
      debugPrint('ImageCompressor: kept original ($e)');
      return path;
    }
  }

  static bool _isJpeg(String path) {
    final p = path.toLowerCase();
    return p.endsWith('.jpg') || p.endsWith('.jpeg');
  }

  static String _baseName(String path) {
    final name = path.split(RegExp(r'[\\/]')).last;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }
}
