import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepremind/features/document_scanner/cubit/scanner_cubit.dart';
import 'package:keepremind/features/document_scanner/cubit/scanner_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScannerCubit Tests', () {
    test('Initial state is idle with no result', () {
      final cubit = ScannerCubit();
      expect(cubit.state.status, equals(ScannerStatus.idle));
      expect(cubit.state.result, isNull);
      expect(cubit.state.imageFile, isNull);
    });

    test('Processing empty text file emits clean empty result without mock injection', () async {
      final cubit = ScannerCubit();
      final tempFile = File('test_empty_scan.png');
      await tempFile.writeAsString('');

      try {
        await cubit.processImage(tempFile);
        expect(cubit.state.status, equals(ScannerStatus.success));
        expect(cubit.state.result, isNotNull);
        expect(cubit.state.result!.rawText, isEmpty);
        expect(cubit.state.result!.detectedFields, isEmpty);
        expect(cubit.state.result!.title, isNull);
        expect(cubit.state.result!.providerOrSeller, isNull);
      } finally {
        if (tempFile.existsSync()) tempFile.deleteSync();
      }
    });

    test('Reset returns cubit to initial idle state', () {
      final cubit = ScannerCubit();
      cubit.reset();
      expect(cubit.state.status, equals(ScannerStatus.idle));
      expect(cubit.state.result, isNull);
    });
  });
}
