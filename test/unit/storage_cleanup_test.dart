import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepremind/core/storage/document_integrity_service.dart';
import 'package:keepremind/core/storage/file_path_resolver.dart';
import 'package:keepremind/core/storage/local_file_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempBaseDir;

  setUpAll(() {
    tempBaseDir = Directory.systemTemp.createTempSync('keepremind_test_docs_');
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return tempBaseDir.path;
      }
      return null;
    });
  });

  tearDownAll(() {
    if (tempBaseDir.existsSync()) {
      tempBaseDir.deleteSync(recursive: true);
    }
  });

  group('Storage Cleanup & File Deletion Tests', () {
    final storage = LocalFileStorage(integrityService: const DocumentIntegrityService());

    test('LocalFileStorage saves file and deletes file by relative path', () async {
      final tempSource = File('test_source_file.txt');
      await tempSource.writeAsString('KeepRemind test document content');

      try {
        final metadata = await storage.saveFile(sourceFile: tempSource);
        expect(metadata.fileName, equals('test_source_file.txt'));
        expect(metadata.fileSize, greaterThan(0));

        final diskFile = await FilePathResolver.resolveRelativePath(metadata.relativePath);
        expect(await diskFile.exists(), isTrue);

        final deleted = await storage.deleteFile(metadata.relativePath);
        expect(deleted, isTrue);
        expect(await diskFile.exists(), isFalse);
      } finally {
        if (tempSource.existsSync()) tempSource.deleteSync();
      }
    });

    test('purgeOrphanedFiles deletes unreferenced files and keeps active ones', () async {
      final file1 = File('test_active.txt');
      final file2 = File('test_orphan.txt');
      await file1.writeAsString('Active file');
      await file2.writeAsString('Orphan file');

      try {
        final meta1 = await storage.saveFile(sourceFile: file1);
        final meta2 = await storage.saveFile(sourceFile: file2);

        final activePaths = {meta1.relativePath};
        final freedBytes = await storage.purgeOrphanedFiles(activePaths);

        expect(freedBytes, greaterThan(0));

        final disk1 = await FilePathResolver.resolveRelativePath(meta1.relativePath);
        final disk2 = await FilePathResolver.resolveRelativePath(meta2.relativePath);

        expect(await disk1.exists(), isTrue);
        expect(await disk2.exists(), isFalse);

        // Cleanup disk1
        await storage.deleteFile(meta1.relativePath);
      } finally {
        if (file1.existsSync()) file1.deleteSync();
        if (file2.existsSync()) file2.deleteSync();
      }
    });
  });
}
