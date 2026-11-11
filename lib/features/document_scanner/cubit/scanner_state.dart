import 'dart:io';
import '../services/ocr_parser_service.dart';

enum ScannerStatus { idle, picking, processing, success, failure }

class ScannerState {
  final ScannerStatus status;
  final File? imageFile;
  final ParsedOcrResult? result;
  final String? errorMessage;

  const ScannerState({
    this.status = ScannerStatus.idle,
    this.imageFile,
    this.result,
    this.errorMessage,
  });

  ScannerState copyWith({
    ScannerStatus? status,
    File? imageFile,
    ParsedOcrResult? result,
    String? errorMessage,
    bool clearFile = false,
  }) {
    return ScannerState(
      status: status ?? this.status,
      imageFile: clearFile ? null : (imageFile ?? this.imageFile),
      result: clearFile ? null : (result ?? this.result),
      errorMessage: errorMessage,
    );
  }
}

