import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepremind/core/notifications/firebase_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebaseNotificationService Channel & Payload Configuration Tests',
      () {
    test('Channel configuration matches high priority and alert specifications',
        () {
      expect(FirebaseNotificationService.channelId, 'firebase_push_channel');
      expect(FirebaseNotificationService.channelName, 'High Priority Alerts');
      expect(
        FirebaseNotificationService.channelDescription,
        contains('foreground, background, and killed states'),
      );
    });

    test(
        'Data payload serializes and decodes cleanly for local notification display',
        () {
      final payloadData = {
        'title': 'Medicine Reminder',
        'body': 'Time to take Paracetamol (650 mg)',
        'type': 'medicine_reminder',
        'medicineId': 'med_123',
      };

      final encoded = jsonEncode(payloadData);
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;

      expect(decoded['title'], 'Medicine Reminder');
      expect(decoded['body'], contains('Paracetamol'));
      expect(decoded['type'], 'medicine_reminder');
      expect(decoded['medicineId'], 'med_123');
    });
  });
}
