class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code, super.details});
}

class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.details});
}

class BackupException extends AppException {
  const BackupException(super.message, {super.code, super.details});
}

class OcrException extends AppException {
  const OcrException(super.message, {super.code, super.details});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.details});
}

