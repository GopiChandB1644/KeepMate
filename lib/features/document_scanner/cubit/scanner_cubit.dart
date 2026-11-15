import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/enums/item_enums.dart';
import '../../../../core/utils/image_compressor.dart';
import '../services/ocr_parser_service.dart';
import 'scanner_state.dart';

class ScannerCubit extends Cubit<ScannerState> {
  final OcrParserService parserService;
  final ImagePicker _picker = ImagePicker();

  ScannerCubit({
    this.parserService = const OcrParserService(),
  }) : super(const ScannerState());

  Future<void> pickFromCamera({ItemSubcategory? expectedSubcategory}) async {
    try {
      emit(state.copyWith(status: ScannerStatus.picking));
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 85,
      );
      if (picked == null) {
        emit(state.copyWith(status: ScannerStatus.idle));
        return;
      }
      final compressed = await ImageCompressor.compress(picked.path, purpose: ImagePurpose.document);
      await processImage(File(compressed), expectedSubcategory: expectedSubcategory);
    } catch (e) {
      emit(state.copyWith(status: ScannerStatus.failure, errorMessage: 'Camera error: $e'));
    }
  }

  Future<void> pickFromGallery({ItemSubcategory? expectedSubcategory}) async {
    try {
      emit(state.copyWith(status: ScannerStatus.picking));
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 85,
      );
      if (picked == null) {
        emit(state.copyWith(status: ScannerStatus.idle));
        return;
      }
      final compressed = await ImageCompressor.compress(picked.path, purpose: ImagePurpose.document);
      await processImage(File(compressed), expectedSubcategory: expectedSubcategory);
    } catch (e) {
      emit(state.copyWith(status: ScannerStatus.failure, errorMessage: 'Gallery error: $e'));
    }
  }

  Future<void> processImage(File imageFile, {ItemSubcategory? expectedSubcategory}) async {
    emit(state.copyWith(status: ScannerStatus.processing, imageFile: imageFile));
    try {
      final text = await OcrParserService.extractText(imageFile);
      final trimmed = text.trim();

      if (trimmed.isEmpty) {
        emit(state.copyWith(
          status: ScannerStatus.success,
          imageFile: imageFile,
          result: const ParsedOcrResult(
            rawText: '',
            confidence: 0.0,
            detectedFields: [],
          ),
        ));
        return;
      }

      final result = parserService.parse(
        text: trimmed,
        expectedSubcategory: expectedSubcategory,
      );

      emit(state.copyWith(
        status: ScannerStatus.success,
        imageFile: imageFile,
        result: result,
      ));
    } catch (e) {
      emit(state.copyWith(status: ScannerStatus.failure, errorMessage: 'Text recognition failed: $e'));
    }
  }

  void reset() {
    emit(const ScannerState());
  }
}

