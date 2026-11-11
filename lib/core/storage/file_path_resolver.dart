import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

class FilePathResolver {
  static Directory? _appDocDir;

  static Future<Directory> get baseDirectory async {
    if (_appDocDir != null) return _appDocDir!;
    _appDocDir = await getApplicationDocumentsDirectory();
    final oldDir = Directory(p.join(_appDocDir!.path, 'KeepMate'));
    final newDir = Directory(p.join(_appDocDir!.path, 'KeepRemind'));
    if (await oldDir.exists() && !await newDir.exists()) {
      try {
        await oldDir.rename(newDir.path);
      } catch (_) {
        return oldDir;
      }
    }
    if (!await newDir.exists()) {
      await newDir.create(recursive: true);
    }
    return newDir;
  }

  static Future<Directory> get documentsDirectory async {
    final base = await baseDirectory;
    final docDir = Directory(p.join(base.path, AppConstants.documentsDirName));
    if (!await docDir.exists()) {
      await docDir.create(recursive: true);
    }
    return docDir;
  }

  static Future<Directory> get backupsDirectory async {
    final base = await baseDirectory;
    final bDir = Directory(p.join(base.path, AppConstants.backupsDirName));
    if (!await bDir.exists()) {
      await bDir.create(recursive: true);
    }
    return bDir;
  }

  static Future<Directory> get stagingDirectory async {
    final base = await baseDirectory;
    final sDir = Directory(p.join(base.path, AppConstants.stagingDirName));
    if (!await sDir.exists()) {
      await sDir.create(recursive: true);
    }
    return sDir;
  }

  /// Resolve a stored relative path (e.g. "documents/bills/123.pdf") to an absolute File
  static Future<File> resolveRelativePath(String relativePath) async {
    final base = await baseDirectory;
    final normalized = relativePath.replaceAll('\\', '/');
    return File(p.join(base.path, normalized));
  }

  /// Convert an absolute path to a relative path starting from KeepRemind root
  static Future<String> toRelativePath(String absolutePath) async {
    final base = await baseDirectory;
    final rel = p.relative(absolutePath, from: base.path);
    return rel.replaceAll('\\', '/');
  }
}

