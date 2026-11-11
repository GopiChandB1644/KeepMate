import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepmate/core/backup/encryption_service.dart';
import 'package:keepmate/core/errors/app_exceptions.dart';

void main() {
  group('Encrypted Backup Security Tests', () {
    const encryption = EncryptionService();
    const testPassword = 'StrongSecretPassword!@#123';
    final samplePlaintext = Uint8List.fromList(utf8.encode('{"app": "KeepMate", "items": [1,2,3]}'));

    test('Encrypt and decrypt returns original plaintext', () {
      final encrypted = encryption.encrypt(plaintext: samplePlaintext, password: testPassword);
      expect(encrypted.length, greaterThan(samplePlaintext.length));

      final decrypted = encryption.decrypt(container: encrypted, password: testPassword);
      expect(utf8.decode(decrypted), equals(utf8.decode(samplePlaintext)));
    });

    test('Wrong password throws BackupException', () {
      final encrypted = encryption.encrypt(plaintext: samplePlaintext, password: testPassword);

      expect(
        () => encryption.decrypt(container: encrypted, password: 'WrongPassword'),
        throwsA(isA<BackupException>()),
      );
    });

    test('Tampered ciphertext tag throws BackupException', () {
      final encrypted = encryption.encrypt(plaintext: samplePlaintext, password: testPassword);
      final tampered = Uint8List.fromList(encrypted);
      tampered[45] ^= 0xFF; // Modify a byte in the authentication tag / ciphertext

      expect(
        () => encryption.decrypt(container: tampered, password: testPassword),
        throwsA(isA<BackupException>()),
      );
    });
  });
}

