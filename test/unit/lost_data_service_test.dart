import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepremind/core/services/lost_data_service.dart';

void main() {
  group('LostDataService Tests', () {
    test('Initial recovered file notifier is null', () {
      final service = LostDataService.instance;
      expect(service.recoveredFileNotifier.value, isNull);
    });

    test('clearRecoveredFile resets notifier to null', () {
      final service = LostDataService.instance;
      service.recoveredFileNotifier.value = File('test_path.jpg');
      expect(service.recoveredFileNotifier.value, isNotNull);

      service.clearRecoveredFile();
      expect(service.recoveredFileNotifier.value, isNull);
    });
  });
}

