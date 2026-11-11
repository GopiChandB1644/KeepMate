import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../../core/enums/item_enums.dart';

class ParsedOcrResult {
  final String rawText;
  final String? title;
  final String? providerOrSeller;
  final String? documentOrPolicyNumber;
  final String? vehicleNumber;
  final DateTime? startDate;
  final DateTime? expiryDate;
  final double? amount;
  final ItemSubcategory? detectedSubcategory;
  final double confidence; // 0.0 to 1.0
  final List<String> detectedFields;

  const ParsedOcrResult({
    required this.rawText,
    this.title,
    this.providerOrSeller,
    this.documentOrPolicyNumber,
    this.vehicleNumber,
    this.startDate,
    this.expiryDate,
    this.amount,
    this.detectedSubcategory,
    this.confidence = 0.8,
    this.detectedFields = const [],
  });
}

class OcrParserService {
  const OcrParserService();

  /// Extracts full text from any supported file (PDF or Image).
  static Future<String> extractText(File file) async {
    final path = file.path.toLowerCase();
    if (path.endsWith('.pdf')) {
      return extractTextFromPdf(file);
    } else {
      return extractTextFromImage(file);
    }
  }

  /// Pure Dart PDF text extraction via syncfusion_flutter_pdf.
  /// Works across Android, iOS, Desktop, and Web completely offline.
  static Future<String> extractTextFromPdf(File file) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return '';

      final document = PdfDocument(inputBytes: bytes);
      final text = PdfTextExtractor(document).extractText();
      document.dispose();
      return text;
    } catch (e) {
      debugPrint('OcrParserService: PDF text extraction error: $e');
      return '';
    }
  }

  /// On-device machine learning OCR via Google ML Kit for photos & images.
  static Future<String> extractTextFromImage(File file) async {
    try {
      final inputImage = InputImage.fromFile(file);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();
      return recognizedText.text;
    } catch (e) {
      debugPrint('OcrParserService: Image OCR error: $e');
      return '';
    }
  }

  // Regex for invoice amounts, bill totals, premiums, fees, currency symbols
  static final RegExp _amountRegex = RegExp(
    r'(?:total\s+(?:amount\s+due|payable|amount|due|premium)|net\s+(?:payable|amount)|amount\s+due|bill\s+amount|invoice\s+total|grand\s+total|total|amount|premium|fee|inr|rs\.?|₹)\s*[:\-]?\s*(?:inr|rs\.?|₹)?\s*([0-9]+(?:,[0-9]{2,3})*(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );

  // Numeric date regex: dd/MM/yyyy, dd-MM-yyyy, dd.MM.yyyy, yyyy-MM-dd
  static final RegExp _numericDateRegex = RegExp(
    r'\b(\d{1,2}[/\-\.]\d{1,2}[/\-\.]\d{2,4})\b',
  );

  // Text month date regex: 20 Dec 2026, 20-Dec-2026, 20 December 2026
  static final RegExp _textMonthDateRegex = RegExp(
    r'\b(\d{1,2}[\s\-\/](?:Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)[\s\-\/,]\s*\d{2,4})\b',
    caseSensitive: false,
  );

  // Policy number, account number, consumer number, invoice number
  static final RegExp _policyOrDocRegex = RegExp(
    r'(?:policy|certificate|document|account|consumer|customer|ca|connection|bill|invoice|dl|licence)\s*(?:no|num|number|id)?\s*[:\-]?\s*([A-Za-z0-9\-\/]{5,25})',
    caseSensitive: false,
  );

  // Indian vehicle registration format: KA01AB1234, DL01C1234, MH12DE5678
  static final RegExp _vehicleRegex = RegExp(
    r'\b[A-Z]{2}[0-9]{1,2}[A-Z]{1,2}[0-9]{4}\b',
    caseSensitive: false,
  );

  ParsedOcrResult parse({
    required String text,
    ItemSubcategory? expectedSubcategory,
  }) {
    if (text.trim().isEmpty) {
      return const ParsedOcrResult(rawText: '');
    }

    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final detected = <String>[];

    String? detectedTitle;
    String? detectedProvider;
    String? detectedNumber;
    String? detectedVehicle;
    DateTime? detectedStart;
    DateTime? detectedExpiry;
    double? detectedAmount;
    ItemSubcategory? detectedSubcategory;

    final lowerFullText = text.toLowerCase();

    // 1. Detect subcategory & smart title from text contents
    if (lowerFullText.contains('electricity') ||
        lowerFullText.contains('bescom') ||
        lowerFullText.contains('tata power') ||
        lowerFullText.contains('power distribution') ||
        lowerFullText.contains('uppcl') ||
        lowerFullText.contains('tsspdcl') ||
        lowerFullText.contains('kseb') ||
        lowerFullText.contains('tneb')) {
      detectedSubcategory = ItemSubcategory.bill;
      detectedTitle = 'Electricity Bill';
      detectedProvider ??= _findProviderName(lines, ['bescom', 'tata power', 'uppcl', 'tsspdcl', 'kseb', 'tneb', 'electricity']);
    } else if (lowerFullText.contains('broadband') ||
        lowerFullText.contains('airtel') ||
        lowerFullText.contains('jio') ||
        lowerFullText.contains('fibernet') ||
        lowerFullText.contains('act fiber') ||
        lowerFullText.contains('bsnl')) {
      detectedSubcategory = ItemSubcategory.bill;
      detectedTitle = 'Broadband Bill';
      detectedProvider ??= _findProviderName(lines, ['airtel', 'jio', 'act fibernet', 'bsnl', 'broadband']);
    } else if (lowerFullText.contains('gas') ||
        lowerFullText.contains('indane') ||
        lowerFullText.contains('hp gas') ||
        lowerFullText.contains('bharat gas') ||
        lowerFullText.contains('igl') ||
        lowerFullText.contains('mgl')) {
      detectedSubcategory = ItemSubcategory.bill;
      detectedTitle = 'LPG / Gas Bill';
      detectedProvider ??= _findProviderName(lines, ['indane', 'hp gas', 'bharat gas', 'igl', 'mgl']);
    } else if (lowerFullText.contains('water bill') || lowerFullText.contains('bwssb') || lowerFullText.contains('jal board')) {
      detectedSubcategory = ItemSubcategory.bill;
      detectedTitle = 'Water Bill';
    } else if (lowerFullText.contains('insurance') ||
        lowerFullText.contains('policy') ||
        lowerFullText.contains('hdfc ergo') ||
        lowerFullText.contains('star health') ||
        lowerFullText.contains('lic') ||
        lowerFullText.contains('icici lombard') ||
        lowerFullText.contains('bajaj allianz') ||
        lowerFullText.contains('care health') ||
        lowerFullText.contains('acko')) {
      detectedSubcategory = ItemSubcategory.insurance;
      detectedTitle = 'Insurance Policy';
      detectedProvider ??= _findProviderName(lines, ['hdfc ergo', 'star health', 'lic', 'icici lombard', 'bajaj allianz', 'care health', 'acko']);
    } else if (lowerFullText.contains('warranty') || lowerFullText.contains('guarantee')) {
      detectedSubcategory = ItemSubcategory.warranty;
      detectedTitle = 'Warranty Card';
    } else if (lowerFullText.contains('driving licence') ||
        lowerFullText.contains('driving license') ||
        lowerFullText.contains('transport department') ||
        lowerFullText.contains('sarathi')) {
      detectedSubcategory = ItemSubcategory.document;
      detectedTitle = 'Driving Licence';
    } else if (lowerFullText.contains('tax invoice') ||
        lowerFullText.contains('invoice') ||
        lowerFullText.contains('amazon') ||
        lowerFullText.contains('flipkart')) {
      detectedSubcategory = ItemSubcategory.purchase;
      detectedTitle = 'Purchase Invoice';
      detectedProvider ??= _findProviderName(lines, ['amazon', 'flipkart', 'retail']);
    } else if (lowerFullText.contains('best before') || lowerFullText.contains('expiry date') && lowerFullText.contains('batch')) {
      detectedSubcategory = ItemSubcategory.grocery;
      detectedTitle = lines.isNotEmpty ? lines.first : 'Grocery Item';
    }

    // 2. Detect Amounts (skipping pure date lines)
    for (final line in lines) {
      final lineLower = line.toLowerCase();
      if (lineLower.contains('date') && !lineLower.contains('amount') && !lineLower.contains('due')) {
        continue;
      }

      final match = _amountRegex.firstMatch(line);
      if (match != null) {
        final clean = match.group(1)?.replaceAll(',', '');
        if (clean != null) {
          final val = double.tryParse(clean);
          if (val != null && val > 0) {
            detectedAmount = val;
            detected.add('Amount: ₹${val.toStringAsFixed(val % 1 == 0 ? 0 : 2)}');
            break;
          }
        }
      }
    }

    // 3. Detect Document / Policy / Account Number
    final docMatch = _policyOrDocRegex.firstMatch(text);
    if (docMatch != null) {
      final num = docMatch.group(1)?.trim();
      if (num != null && num.length >= 4) {
        detectedNumber = num;
        detected.add('Doc/Policy No: $detectedNumber');
      }
    }

    // 4. Detect Vehicle Number
    final vehicleMatch = _vehicleRegex.firstMatch(text);
    if (vehicleMatch != null) {
      detectedVehicle = vehicleMatch.group(0)?.toUpperCase();
      detected.add('Vehicle: $detectedVehicle');
    }

    // 5. Detect Dates with contextual expiry / due date prioritization
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineLower = line.toLowerCase();

      // Look for both numeric and text-month dates
      final match = _textMonthDateRegex.firstMatch(line) ?? _numericDateRegex.firstMatch(line);
      if (match != null) {
        final parsedDate = _parseAnyDate(match.group(1)!);
        if (parsedDate != null) {
          final isExpiryKeyword = lineLower.contains('exp') ||
              lineLower.contains('valid to') ||
              lineLower.contains('valid until') ||
              lineLower.contains('valid till') ||
              lineLower.contains('valid upto') ||
              lineLower.contains('due') ||
              lineLower.contains('pay by') ||
              lineLower.contains('best before') ||
              lineLower.contains('use by');

          final isStartKeyword = lineLower.contains('issue') ||
              lineLower.contains('start') ||
              lineLower.contains('from') ||
              lineLower.contains('bill date') ||
              lineLower.contains('invoice date');

          if (isExpiryKeyword) {
            detectedExpiry = parsedDate;
            detected.add('Due / Expiry: ${DateFormat('dd/MM/yyyy').format(parsedDate)}');
          } else if (isStartKeyword) {
            detectedStart = parsedDate;
            detected.add('Start Date: ${DateFormat('dd/MM/yyyy').format(parsedDate)}');
          } else if (detectedExpiry == null) {
            // If date is in the future, likely expiry/due date
            if (parsedDate.isAfter(DateTime.now())) {
              detectedExpiry = parsedDate;
              detected.add('Target Date: ${DateFormat('dd/MM/yyyy').format(parsedDate)}');
            } else if (detectedStart == null) {
              detectedStart = parsedDate;
              detected.add('Date: ${DateFormat('dd/MM/yyyy').format(parsedDate)}');
            }
          }
        }
      }
    }

    // Fallback title from clean first lines if not yet identified
    if (detectedTitle == null && lines.isNotEmpty) {
      for (final line in lines) {
        if (line.length >= 3 && line.length <= 40 && !line.contains(':') && !RegExp(r'^\d+$').hasMatch(line)) {
          detectedTitle = line;
          break;
        }
      }
    }

    if (detectedProvider == null && lines.length > 1) {
      if (lines[0] != detectedTitle && lines[0].length <= 35) {
        detectedProvider = lines[0];
      } else if (lines.length > 1 && lines[1] != detectedTitle && lines[1].length <= 35) {
        detectedProvider = lines[1];
      }
    }

    final confidence = detected.isNotEmpty
        ? (detected.length >= 3 ? 0.95 : 0.75)
        : 0.2;

    return ParsedOcrResult(
      rawText: text,
      title: detectedTitle,
      providerOrSeller: detectedProvider,
      documentOrPolicyNumber: detectedNumber,
      vehicleNumber: detectedVehicle,
      startDate: detectedStart,
      expiryDate: detectedExpiry,
      amount: detectedAmount,
      detectedSubcategory: detectedSubcategory,
      confidence: confidence,
      detectedFields: detected,
    );
  }

  static String? _findProviderName(List<String> lines, List<String> keywords) {
    for (final line in lines) {
      final lineLower = line.toLowerCase();
      for (final kw in keywords) {
        if (lineLower.contains(kw) && line.length <= 45) {
          return line.trim();
        }
      }
    }
    return null;
  }

  static DateTime? _parseAnyDate(String str) {
    final clean = str.trim().replaceAll(',', ' ').replaceAll(RegExp(r'\s+'), ' ');
    final formats = [
      'dd/MM/yyyy',
      'dd-MM-yyyy',
      'yyyy-MM-dd',
      'MM/dd/yyyy',
      'dd.MM.yyyy',
      'd/M/yyyy',
      'd-M-yyyy',
      'd.M.yyyy',
      'dd/MM/yy',
      'dd-MM-yy',
      'dd MMM yyyy',
      'dd-MMM-yyyy',
      'dd MMMM yyyy',
      'd MMM yyyy',
      'd MMMM yyyy',
      'MMM d yyyy',
      'MMMM d yyyy',
    ];

    for (final fmt in formats) {
      try {
        return DateFormat(fmt, 'en_US').parseStrict(clean);
      } catch (_) {}
    }
    return null;
  }
}
