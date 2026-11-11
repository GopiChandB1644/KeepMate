import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import '../errors/app_exceptions.dart';
import 'backup_constants.dart';

class EncryptionService {
  const EncryptionService();

  /// Generate cryptographically secure random bytes
  Uint8List generateRandomBytes(int length) {
    final random = Random.secure();
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return bytes;
  }

  /// PBKDF2-HMAC-SHA256 Key Derivation Function
  Uint8List deriveKey({
    required String password,
    required Uint8List salt,
    int iterations = BackupConstants.pbkdf2Iterations,
    int derivedKeyLength = 64, // 32 bytes Encryption Key + 32 bytes MAC Key
  }) {
    final passwordBytes = utf8.encode(password);
    final hmac = Hmac(sha256, passwordBytes);

    final blocksNeeded = (derivedKeyLength + 31) ~/ 32;
    final derived = BytesBuilder();

    for (var i = 1; i <= blocksNeeded; i++) {
      // U_1 = PRF(P, S || INT_32_BE(i))
      final saltPlusI = BytesBuilder();
      saltPlusI.add(salt);
      saltPlusI.add([
        (i >> 24) & 0xFF,
        (i >> 16) & 0xFF,
        (i >> 8) & 0xFF,
        i & 0xFF,
      ]);

      var u = hmac.convert(saltPlusI.toBytes()).bytes;
      var f = List<int>.from(u);

      for (var iter = 1; iter < iterations; iter++) {
        u = hmac.convert(u).bytes;
        for (var k = 0; k < f.length; k++) {
          f[k] ^= u[k];
        }
      }

      derived.add(f);
    }

    return Uint8List.fromList(derived.toBytes().sublist(0, derivedKeyLength));
  }

  /// Encrypt payload with user password using authenticated PBKDF2 + Stream Keystream + HMAC-SHA256
  Uint8List encrypt({required Uint8List plaintext, required String password}) {
    final salt = generateRandomBytes(BackupConstants.saltLength);
    final iv = generateRandomBytes(BackupConstants.ivLength);

    final derived = deriveKey(password: password, salt: salt);
    final encKey = derived.sublist(0, 32);
    final macKey = derived.sublist(32, 64);

    // Keystream encryption (CTR mode with SHA-256 block generation)
    final ciphertext = _applyKeystream(plaintext, encKey, iv);

    // Compute HMAC-SHA256 authentication tag over magic + version + salt + iv + ciphertext
    final headerBytes = utf8.encode(BackupConstants.magic);
    final authBuilder = BytesBuilder();
    authBuilder.add(headerBytes);
    authBuilder.addByte(BackupConstants.currentFormatVersion);
    authBuilder.add(salt);
    authBuilder.add(iv);
    authBuilder.add(ciphertext);

    final hmac = Hmac(sha256, macKey);
    final tag = hmac.convert(authBuilder.toBytes()).bytes;

    // Output container: [Magic: 4B] [Version: 1B] [Salt: 16B] [IV: 16B] [Tag: 32B] [Ciphertext]
    final result = BytesBuilder();
    result.add(headerBytes);
    result.addByte(BackupConstants.currentFormatVersion);
    result.add(salt);
    result.add(iv);
    result.add(tag);
    result.add(ciphertext);

    return result.toBytes();
  }

  /// Decrypt container with user password, validating authentication tag
  Uint8List decrypt({required Uint8List container, required String password}) {
    if (container.length < 4 + 1 + 16 + 16 + 32) {
      throw const BackupException('Invalid or corrupted backup file format');
    }

    // Check magic bytes
    final magic = utf8.decode(container.sublist(0, 4));
    if (magic != BackupConstants.magic) {
      throw const BackupException('Not a valid KeepMate (.kmb) backup file');
    }

    final version = container[4];
    if (version > BackupConstants.currentFormatVersion) {
      throw BackupException('Unsupported backup format version: $version');
    }

    final salt = container.sublist(5, 21);
    final iv = container.sublist(21, 37);
    final expectedTag = container.sublist(37, 69);
    final ciphertext = container.sublist(69);

    // Derive keys
    final derived = deriveKey(password: password, salt: salt);
    final encKey = derived.sublist(0, 32);
    final macKey = derived.sublist(32, 64);

    // Verify MAC
    final headerBytes = utf8.encode(BackupConstants.magic);
    final authBuilder = BytesBuilder();
    authBuilder.add(headerBytes);
    authBuilder.addByte(version);
    authBuilder.add(salt);
    authBuilder.add(iv);
    authBuilder.add(ciphertext);

    final hmac = Hmac(sha256, macKey);
    final actualTag = hmac.convert(authBuilder.toBytes()).bytes;

    // Constant-time tag comparison
    var diff = 0;
    for (var i = 0; i < 32; i++) {
      diff |= expectedTag[i] ^ actualTag[i];
    }

    if (diff != 0) {
      throw const BackupException('Incorrect password or corrupted backup file');
    }

    // Decrypt
    return _applyKeystream(ciphertext, encKey, iv);
  }

  Uint8List _applyKeystream(Uint8List input, Uint8List key, Uint8List iv) {
    final output = Uint8List(input.length);
    final hmac = Hmac(sha256, key);

    var blockIndex = 0;
    var byteOffset = 0;

    while (byteOffset < input.length) {
      final counterBytes = [
        (blockIndex >> 24) & 0xFF,
        (blockIndex >> 16) & 0xFF,
        (blockIndex >> 8) & 0xFF,
        blockIndex & 0xFF,
      ];
      final blockKey = hmac.convert([...iv, ...counterBytes]).bytes;

      final chunkLength = min(32, input.length - byteOffset);
      for (var i = 0; i < chunkLength; i++) {
        output[byteOffset + i] = input[byteOffset + i] ^ blockKey[i];
      }

      byteOffset += chunkLength;
      blockIndex++;
    }

    return output;
  }
}

