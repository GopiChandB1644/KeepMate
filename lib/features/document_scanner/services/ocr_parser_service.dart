import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' hide TextLine;
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

  static const MethodChannel _pdfChannel = MethodChannel('com.keepremind.app/pdf_renderer');
  static const MethodChannel _legacyPdfChannel = MethodChannel('com.keepmate.app/pdf_renderer');

  /// Extracts full text from any supported file (PDF or Image).
  static Future<String> extractText(File file) async {
    final path = file.path.toLowerCase();
    if (path.endsWith('.pdf')) {
      return extractTextFromPdf(file);
    } else {
      return extractTextFromImage(file);
    }
  }

  /// Extracts text from PDF documents.
  /// 1. Tries digital text extraction with spatial row sorting.
  /// 2. If the PDF is scanned (image-based with empty text stream),
  ///    renders the first page to an image and runs on-device ML Kit OCR.
  static Future<String> extractTextFromPdf(File file) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return '';

      String extractedText = '';

      try {
        final document = PdfDocument(inputBytes: bytes);
        final lines = PdfTextExtractor(document).extractTextLines();
        document.dispose();

        if (lines.isNotEmpty) {
          extractedText = _reconstructPdfSpatialRows(lines);
        }

        if (extractedText.trim().length < 25) {
          final fallbackDoc = PdfDocument(inputBytes: bytes);
          final raw = PdfTextExtractor(fallbackDoc).extractText();
          fallbackDoc.dispose();
          if (raw.trim().length > extractedText.trim().length) {
            extractedText = raw;
          }
        }
      } catch (e) {
        debugPrint('OcrParserService: Syncfusion PDF extract note: $e');
      }

      // Check if digital text has meaningful content (>= 40 alphanumeric characters
      // AND contains words/digits typical of bills/documents)
      final letterCount = RegExp(r'[a-zA-Z0-9]').allMatches(extractedText).length;
      final hasMeaningfulContent = letterCount >= 40 &&
          (RegExp(r'\d{2}').hasMatch(extractedText) ||
              extractedText.toLowerCase().contains('bill') ||
              extractedText.toLowerCase().contains('invoice') ||
              extractedText.toLowerCase().contains('date') ||
              extractedText.toLowerCase().contains('policy') ||
              extractedText.toLowerCase().contains('certificate'));

      if (hasMeaningfulContent) {
        debugPrint('OcrParserService: Digital PDF text extracted successfully (${extractedText.length} chars)');
        return extractedText;
      }

      // Otherwise, the PDF is a scanned document (e.g. photos/scans of RC front & back)!
      // Render pages via native PdfRenderer and run Google ML Kit OCR on each page.
      debugPrint('OcrParserService: Scanned image PDF detected, rendering pages for ML Kit OCR...');
      final renderedImagePaths = await _renderPdfPagesViaNative(file.path, maxPages: 4);

      if (renderedImagePaths.isNotEmpty) {
        final pageTexts = <String>[];
        for (var i = 0; i < renderedImagePaths.length; i++) {
          final pagePath = renderedImagePaths[i];
          final pageFile = File(pagePath);
          if (pageFile.existsSync()) {
            final pageText = await extractTextFromImage(pageFile);
            try {
              pageFile.deleteSync();
            } catch (_) {}
            if (pageText.trim().isNotEmpty) {
              pageTexts.add('--- PAGE ${i + 1} ---\n$pageText');
            }
          }
        }
        if (pageTexts.isNotEmpty) {
          final combined = pageTexts.join('\n\n');
          debugPrint('OcrParserService: Extracted OCR text from ${pageTexts.length} rendered pages (${combined.length} chars)');
          return combined;
        }
      }

      return extractedText;
    } catch (e) {
      debugPrint('OcrParserService: PDF text extraction error: $e');
      return '';
    }
  }

  static Future<List<String>> _renderPdfPagesViaNative(String pdfPath, {int maxPages = 4}) async {
    for (final channel in [_pdfChannel, _legacyPdfChannel]) {
      try {
        final result = await channel.invokeMethod<List<dynamic>>('renderPages', {
          'path': pdfPath,
          'maxPages': maxPages,
        });
        if (result != null && result.isNotEmpty) {
          return result.map((e) => e.toString()).toList();
        }
      } catch (_) {}
      try {
        final single = await channel.invokeMethod<String>('renderFirstPage', {'path': pdfPath});
        if (single != null) return [single];
      } catch (_) {}
    }
    return [];
  }

  /// On-device machine learning OCR via Google ML Kit for photos & images.
  /// Reconstructs 2D spatial rows so column-based tables (labels on left, values on right)
  /// are joined onto the same line for accurate parsing.
  static Future<String> extractTextFromImage(File file) async {
    try {
      final inputImage = InputImage.fromFile(file);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      final allLines = <TextLine>[];
      for (final block in recognizedText.blocks) {
        allLines.addAll(block.lines);
      }

      if (allLines.isEmpty) {
        return recognizedText.text;
      }

      // Reconstruct horizontal spatial rows
      final spatialText = _reconstructSpatialRows(allLines);
      // Combine spatially reconstructed text with original block text
      return '$spatialText\n\n--- RAW BLOCKS ---\n${recognizedText.text}';
    } catch (e) {
      debugPrint('OcrParserService: Image OCR error: $e');
      return '';
    }
  }

  /// Groups recognized ML Kit lines that are on the same vertical level into a single row,
  /// ordered left-to-right.
  static String _reconstructSpatialRows(List<TextLine> lines) {
    if (lines.isEmpty) return '';

    // Sort all lines top-to-bottom by vertical center
    final sorted = List<TextLine>.from(lines)
      ..sort((a, b) {
        final aCenter = (a.boundingBox.top + a.boundingBox.bottom) / 2;
        final bCenter = (b.boundingBox.top + b.boundingBox.bottom) / 2;
        return aCenter.compareTo(bCenter);
      });

    final rows = <List<TextLine>>[];
    for (final line in sorted) {
      final lineCenter = (line.boundingBox.top + line.boundingBox.bottom) / 2;
      final lineHeight = max(10.0, line.boundingBox.height);

      bool placed = false;
      for (final row in rows) {
        final rowCenter = (row.first.boundingBox.top + row.first.boundingBox.bottom) / 2;
        final rowHeight = max(10.0, row.first.boundingBox.height);
        final tolerance = max(lineHeight, rowHeight) * 0.65;

        if ((lineCenter - rowCenter).abs() <= tolerance) {
          row.add(line);
          placed = true;
          break;
        }
      }

      if (!placed) {
        rows.add([line]);
      }
    }

    final buffer = StringBuffer();
    for (final row in rows) {
      // Sort elements in each row from left to right
      row.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));
      final lineText = row.map((l) => l.text.trim()).where((t) => t.isNotEmpty).join('   ');
      if (lineText.isNotEmpty) {
        buffer.writeln(lineText);
      }
    }

    return buffer.toString();
  }

  /// Groups Syncfusion PDF TextLines into spatial rows
  static String _reconstructPdfSpatialRows(List<dynamic> lines) {
    if (lines.isEmpty) return '';

    final sorted = List<dynamic>.from(lines)
      ..sort((a, b) {
        final aTop = a.bounds.top as double;
        final bTop = b.bounds.top as double;
        return aTop.compareTo(bTop);
      });

    final rows = <List<dynamic>>[];
    for (final line in sorted) {
      final top = line.bounds.top as double;
      final height = max(8.0, line.bounds.height as double);

      bool placed = false;
      for (final row in rows) {
        final rTop = row.first.bounds.top as double;
        final rHeight = max(8.0, row.first.bounds.height as double);
        final tol = max(height, rHeight) * 0.6;
        if ((top - rTop).abs() <= tol) {
          row.add(line);
          placed = true;
          break;
        }
      }

      if (!placed) {
        rows.add([line]);
      }
    }

    final buffer = StringBuffer();
    for (final row in rows) {
      row.sort((a, b) => (a.bounds.left as double).compareTo(b.bounds.left as double));
      final lineText = row.map((l) => l.text.toString().trim()).where((t) => t.isNotEmpty).join('   ');
      if (lineText.isNotEmpty) {
        buffer.writeln(lineText);
      }
    }
    return buffer.toString();
  }

  // Regex for amounts, due totals, bills, premiums, demand
  static final RegExp _amountRegex = RegExp(
    r'(?:bill\s+amount|current\s+demand|total\s+(?:amount\s+due|payable|amount|due|premium)|net\s+(?:payable|amount)|amount\s+due|grand\s+total|total\s+due|recharge\s+amount|premium\s+amount|total|amount|premium|fee|inr|rs\.?|₹)\s*[:\-]?\s*(?:inr|rs\.?|₹)?\s*([0-9]+(?:,[0-9]{2,3})*(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );

  // Standalone amount regex (e.g. ₹ 256.00 or 1,450.00)
  static final RegExp _currencyRegex = RegExp(
    r'(?:₹|rs\.?|inr)\s*([0-9]+(?:,[0-9]{2,3})*(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );

  // Numeric date regex: dd/MM/yyyy, dd-MM-yyyy, dd.MM.yyyy, yyyy-MM-dd, dd/MM/yy, dd-MM-yy
  static final RegExp _numericDateRegex = RegExp(
    r'\b(\d{1,2}[/\-\.]\d{1,2}[/\-\.]\d{2,4})\b',
  );

  // Text month date regex: 20 Dec 2026, 20-Dec-2026, 20 December 2026, 25 Nov 26
  static final RegExp _textMonthDateRegex = RegExp(
    r'\b(\d{1,2}[\s\-\/](?:Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)[\s\-\/,]\s*\d{2,4})\b',
    caseSensitive: false,
  );

  // Month-Year date regex: 11/26, 12/2026, Nov 2026 (common on cards, food packs, medicine)
  static final RegExp _monthYearDateRegex = RegExp(
    r'\b((?:0[1-9]|1[0-2])[/\-\.](?:20)?\d{2})\b',
  );

  // Service / Consumer / Account / Policy / Document / Bill / Order Number
  static final RegExp _docNumberRegex = RegExp(
    r'(?:unique\s+service(?:\s+(?:no|num|number|id))?|service\s+(?:no|num|number|id)|consumer\s+(?:no|num|number|id)|account\s+(?:no|num|number|id)|ca\s+(?:no|num|number|id)|customer\s+(?:no|num|number|id)|connection\s+(?:no|num|number|id)|policy\s+(?:no|num|number|id)|certificate\s+(?:no|num|number|id)|invoice\s+(?:no|num|number|id)|bill\s+(?:no|num|number|id)|dl\s+(?:no|num|number|id)|licen[cs]e\s+(?:no|num|number|id)|reg(?:istration)?\s+(?:no|num|number|id)|order\s+(?:no|num|number|id|#)|reference\s+(?:no|num|number|id)?|ref\s+(?:no|num|number|id)?|serial\s+(?:no|num|number|id)?|s/n|k\s*no|rr\s*no|uscno(?:\s+(?:no|num|number|id))?|meter\s*(?:no|num|number|id)?|pan(?:\s+(?:no|num|number|id))?|aadhaar(?:\s+(?:no|num|number|id))?|uid(?:\s+(?:no|num|number|id))?|passport(?:\s+(?:no|num|number|id))?)\s*[:\-#]?\s*([A-Za-z0-9\-\/]{4,30})',
    caseSensitive: false,
  );

  // Valid Indian State & UT codes
  static const Set<String> _indianStateCodes = {
    'AN', 'AP', 'AR', 'AS', 'BR', 'CH', 'CG', 'DD', 'DL', 'DN',
    'GA', 'GJ', 'HR', 'HP', 'JH', 'JK', 'KA', 'KL', 'LA', 'LD',
    'MP', 'MH', 'MN', 'ML', 'MZ', 'NL', 'OD', 'OR', 'PB', 'PY',
    'RJ', 'SK', 'TN', 'TR', 'TS', 'UK', 'UA', 'UP', 'WB', 'BH',
  };

  // Indian vehicle registration format: KA01AB1234, AP 04 TE 1234, DL-1C-A-1234, 22 BH 1234 AA
  static final RegExp _vehicleRegex = RegExp(
    r'\b([A-Z]{2}[\s\-]?[0-9]{1,2}[\s\-]?[A-Z]{1,3}[\s\-]?[0-9]{4})\b|\b([0-9]{2}[\s\-]?BH[\s\-]?[0-9]{4}[\s\-]?[A-Z]{1,2})\b',
    caseSensitive: false,
  );

  static final RegExp _labeledVehicleRegex = RegExp(
    r'(?:reg(?:n|istration)?(?:\.|\s)*(?:no|num|number)?|vehicle(?:\.|\s)*(?:no|num|number)?)\s*[:\-]?\s*([A-Z]{2}[\s\-]?[0-9]{1,2}[\s\-]?[A-Z]{1,3}[\s\-]?[0-9]{3,4}|[0-9]{2}[\s\-]?BH[\s\-]?[0-9]{4}[\s\-]?[A-Z]{1,2})\b',
    caseSensitive: false,
  );

  static final RegExp _chassisRegex = RegExp(
    r'(?:chassis|chasis)(?:\.|\s)*(?:no|num|number)?\s*[:\-]?\s*([A-Za-z0-9]{8,25})',
    caseSensitive: false,
  );

  static final RegExp _engineRegex = RegExp(
    r'engine(?:\.|\s)*(?:no|num|number)?\s*[:\-]?\s*([A-Za-z0-9]{5,25})',
    caseSensitive: false,
  );

  static String? _extractVehicleNumber(String text) {
    // Check labeled line first
    final labeled = _labeledVehicleRegex.firstMatch(text);
    if (labeled != null) {
      final raw = labeled.group(1)?.trim();
      if (raw != null) {
        final clean = raw.replaceAll(RegExp(r'[\s\-]+'), '').toUpperCase();
        if (_isValidVehicle(clean)) return clean;
      }
    }

    // Check all general vehicle regex matches
    final matches = _vehicleRegex.allMatches(text);
    for (final m in matches) {
      final raw = m.group(0)?.trim();
      if (raw != null) {
        final clean = raw.replaceAll(RegExp(r'[\s\-]+'), '').toUpperCase();
        if (_isValidVehicle(clean)) return clean;
      }
    }
    return null;
  }

  static bool _isValidVehicle(String clean) {
    if (clean.length < 7 || clean.length > 11) return false;
    if (RegExp(r'^[0-9]{2}BH[0-9]{4}[A-Z]{1,2}$').hasMatch(clean)) return true;
    final prefix = clean.substring(0, 2);
    if (!_indianStateCodes.contains(prefix)) return false;
    return RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,3}[0-9]{4}$').hasMatch(clean);
  }

  // Stop words that must NOT be mistaken for document numbers
  static final Set<String> _docNumberStopWords = {
    'payment',
    'amount',
    'details',
    'online',
    'please',
    'submit',
    'proceed',
    'number',
    'service',
    'central',
    'demand',
    'arrear',
    'reconnection',
    'circle',
    'customer',
    'prakasam',
    'guntur',
    'status',
    'pending',
    'success',
    'bill',
    'invoice',
    'policy',
    'receipt',
  };

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

    // 1. Detect Vehicle Registration Number first
    detectedVehicle = _extractVehicleNumber(text);
    if (detectedVehicle != null) {
      detected.add('Vehicle: $detectedVehicle');
    }

    // 2. Detect subcategory & smart title from text contents
    final isVehicleRc = lowerFullText.contains('registration certificate') ||
        lowerFullText.contains('certificate of registration') ||
        lowerFullText.contains('form 23') ||
        lowerFullText.contains('form-23') ||
        lowerFullText.contains('form no 23') ||
        lowerFullText.contains('form no. 23') ||
        lowerFullText.contains('motor vehicles department') ||
        lowerFullText.contains('chassis no') ||
        lowerFullText.contains('chasis no') ||
        lowerFullText.contains('engine no') ||
        (detectedVehicle != null &&
            (lowerFullText.contains('transport') ||
                lowerFullText.contains('rto') ||
                lowerFullText.contains('fitness') ||
                lowerFullText.contains('regn upto') ||
                lowerFullText.contains('reg. upto') ||
                lowerFullText.contains('regn. no') ||
                lowerFullText.contains('regn no') ||
                lowerFullText.contains('regn date')));

    if (isVehicleRc) {
      detectedSubcategory = ItemSubcategory.document;
      detectedTitle = detectedVehicle != null ? 'Vehicle RC ($detectedVehicle)' : 'Vehicle Registration Certificate';
      detectedProvider ??= _findProviderName(lines, [
        'transport department',
        'government of',
        'govt of',
        'motor vehicles',
        'rto',
      ]) ?? 'Transport Department';
    } else if (lowerFullText.contains('electricity') ||
        lowerFullText.contains('power distribution') ||
        lowerFullText.contains('central power') ||
        lowerFullText.contains('southern power') ||
        lowerFullText.contains('eastern power') ||
        lowerFullText.contains('apcpdcl') ||
        lowerFullText.contains('apspdcl') ||
        lowerFullText.contains('apepdcl') ||
        lowerFullText.contains('tsspdcl') ||
        lowerFullText.contains('tsnpdcl') ||
        lowerFullText.contains('bescom') ||
        lowerFullText.contains('tata power') ||
        lowerFullText.contains('adani electricity') ||
        lowerFullText.contains('torrent power') ||
        lowerFullText.contains('bses') ||
        lowerFullText.contains('uppcl') ||
        lowerFullText.contains('kseb') ||
        lowerFullText.contains('tneb') ||
        lowerFullText.contains('pspcl') ||
        lowerFullText.contains('dhbvn') ||
        lowerFullText.contains('wbsedcl')) {
      detectedSubcategory = ItemSubcategory.bill;
      detectedTitle = 'Electricity Bill';
      detectedProvider ??= _findProviderName(lines, [
        'central power',
        'distribution corporation',
        'apcpdcl',
        'apspdcl',
        'apepdcl',
        'tsspdcl',
        'tsnpdcl',
        'bescom',
        'tata power',
        'adani electricity',
        'bses',
        'torrent power',
        'uppcl',
        'kseb',
        'tneb',
        'pspcl',
      ]);
    } else if (lowerFullText.contains('broadband') ||
        lowerFullText.contains('airtel') ||
        lowerFullText.contains('jio') ||
        lowerFullText.contains('fibernet') ||
        lowerFullText.contains('act fiber') ||
        lowerFullText.contains('bsnl') ||
        lowerFullText.contains('tata play') ||
        lowerFullText.contains('hathway')) {
      detectedSubcategory = ItemSubcategory.bill;
      detectedTitle = 'Broadband Bill';
      detectedProvider ??= _findProviderName(lines, ['airtel', 'jio', 'act fibernet', 'act fiber', 'bsnl', 'tata play', 'hathway']);
    } else if (lowerFullText.contains('gas') ||
        lowerFullText.contains('indane') ||
        lowerFullText.contains('hp gas') ||
        lowerFullText.contains('bharat gas') ||
        lowerFullText.contains('igl') ||
        lowerFullText.contains('mgl') ||
        lowerFullText.contains('adani gas')) {
      detectedSubcategory = ItemSubcategory.bill;
      detectedTitle = 'LPG / Gas Bill';
      detectedProvider ??= _findProviderName(lines, ['indane', 'hp gas', 'bharat gas', 'igl', 'mgl', 'adani gas']);
    } else if (lowerFullText.contains('water bill') ||
        lowerFullText.contains('bwssb') ||
        lowerFullText.contains('jal board') ||
        lowerFullText.contains('hmwssb')) {
      detectedSubcategory = ItemSubcategory.bill;
      detectedTitle = 'Water Bill';
      detectedProvider ??= _findProviderName(lines, ['bwssb', 'jal board', 'hmwssb', 'water']);
    } else if (lowerFullText.contains('insurance') ||
        lowerFullText.contains('policy') ||
        lowerFullText.contains('hdfc ergo') ||
        lowerFullText.contains('star health') ||
        lowerFullText.contains('lic') ||
        lowerFullText.contains('icici lombard') ||
        lowerFullText.contains('bajaj allianz') ||
        lowerFullText.contains('care health') ||
        lowerFullText.contains('new india assurance') ||
        lowerFullText.contains('united india') ||
        lowerFullText.contains('acko')) {
      detectedSubcategory = ItemSubcategory.insurance;
      detectedTitle = 'Insurance Policy';
      detectedProvider ??= _findProviderName(lines, ['hdfc ergo', 'star health', 'lic', 'icici lombard', 'bajaj allianz', 'care health', 'acko', 'new india assurance', 'united india']);
    } else if (lowerFullText.contains('warranty') || lowerFullText.contains('guarantee')) {
      detectedSubcategory = ItemSubcategory.warranty;
      detectedTitle = 'Warranty Card';
    } else if (lowerFullText.contains('driving licence') ||
        lowerFullText.contains('driving license') ||
        lowerFullText.contains('sarathi') ||
        lowerFullText.contains('dl no')) {
      detectedSubcategory = ItemSubcategory.document;
      detectedTitle = 'Driving Licence';
      detectedProvider ??= 'Transport Department';
    } else if (lowerFullText.contains('pan card') || lowerFullText.contains('income tax department')) {
      detectedSubcategory = ItemSubcategory.document;
      detectedTitle = 'PAN Card';
      detectedProvider ??= 'Income Tax Department';
    } else if (lowerFullText.contains('aadhaar') || lowerFullText.contains('uidai')) {
      detectedSubcategory = ItemSubcategory.document;
      detectedTitle = 'Aadhaar Card';
      detectedProvider ??= 'UIDAI';
    } else if (lowerFullText.contains('passport') || lowerFullText.contains('republic of india')) {
      detectedSubcategory = ItemSubcategory.document;
      detectedTitle = 'Passport';
      detectedProvider ??= 'Passport Seva';
    } else if (lowerFullText.contains('tax invoice') ||
        lowerFullText.contains('invoice') ||
        lowerFullText.contains('amazon') ||
        lowerFullText.contains('flipkart')) {
      detectedSubcategory = ItemSubcategory.purchase;
      detectedTitle = 'Purchase Invoice';
      detectedProvider ??= _findProviderName(lines, ['amazon', 'flipkart', 'retail', 'technologies', 'private limited']);
    } else if (lowerFullText.contains('best before') || (lowerFullText.contains('expiry date') && lowerFullText.contains('batch'))) {
      detectedSubcategory = ItemSubcategory.grocery;
      detectedTitle = lines.isNotEmpty ? lines.first : 'Grocery Item';
    }

    // 2. Detect Amounts (including adjacent row support)
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineLower = line.toLowerCase();

      // Skip lines that are purely dates or account numbers
      if (lineLower.contains('date') && !lineLower.contains('amount') && !lineLower.contains('demand') && !lineLower.contains('due') && !lineLower.contains('total')) {
        continue;
      }

      final match = _amountRegex.firstMatch(line);
      if (match != null) {
        final clean = match.group(1)?.replaceAll(',', '');
        if (clean != null) {
          final val = double.tryParse(clean);
          if (val != null && val > 0) {
            detectedAmount = val;
            break;
          }
        }
      }

      // Check next line if current line is a label ending with colon or keyword
      if (i + 1 < lines.length) {
        if (lineLower.contains('bill amount') ||
            lineLower.contains('current demand') ||
            lineLower.contains('total amount') ||
            lineLower.contains('net payable') ||
            lineLower.contains('total due') ||
            lineLower.contains('grand total')) {
          final nextLine = lines[i + 1];
          final nextMatch = RegExp(r'^[:\-]?\s*(?:₹|rs\.?|inr)?\s*([0-9]+(?:,[0-9]{2,3})*(?:\.[0-9]{1,2})?)', caseSensitive: false).firstMatch(nextLine);
          if (nextMatch != null) {
            final clean = nextMatch.group(1)?.replaceAll(',', '');
            if (clean != null) {
              final val = double.tryParse(clean);
              if (val != null && val > 0) {
                detectedAmount = val;
                break;
              }
            }
          }
        }
      }
    }

    // Fallback: standalone currency symbols (₹ 256.00)
    if (detectedAmount == null) {
      for (final line in lines) {
        final cMatch = _currencyRegex.firstMatch(line);
        if (cMatch != null) {
          final clean = cMatch.group(1)?.replaceAll(',', '');
          if (clean != null) {
            final val = double.tryParse(clean);
            if (val != null && val > 0) {
              detectedAmount = val;
              break;
            }
          }
        }
      }
    }

    if (detectedAmount != null) {
      detected.add('Amount: ₹${detectedAmount.toStringAsFixed(detectedAmount % 1 == 0 ? 0 : 2)}');
    }

    // 3. Detect Document / Service / Policy Number
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final docMatch = _docNumberRegex.firstMatch(line);
      if (docMatch != null) {
        final num = docMatch.group(1)?.trim();
        if (num != null && num.length >= 4 && !_docNumberStopWords.contains(num.toLowerCase())) {
          // Reject purely alpha tokens unless formatted like PAN / DL
          if (RegExp(r'\d').hasMatch(num) || RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(num)) {
            detectedNumber = num;
            detected.add('Doc/Service No: $detectedNumber');
            break;
          }
        }
      }

      // Check next line if current line has label like "Unique Service Number:"
      if (i + 1 < lines.length) {
        final lineLower = line.toLowerCase();
        if (lineLower.contains('service number') ||
            lineLower.contains('consumer number') ||
            lineLower.contains('account number') ||
            lineLower.contains('policy number') ||
            lineLower.contains('invoice number')) {
          final nextCandidate = lines[i + 1].trim();
          final cleanCandidate = nextCandidate.replaceAll(RegExp(r'^[:\-#\s]+'), '').trim();
          if (cleanCandidate.length >= 4 &&
              cleanCandidate.length <= 25 &&
              RegExp(r'\d').hasMatch(cleanCandidate) &&
              !_docNumberStopWords.contains(cleanCandidate.toLowerCase())) {
            detectedNumber = cleanCandidate;
            detected.add('Doc/Service No: $detectedNumber');
            break;
          }
        }
      }
    }

    // Fallback: If document number wasn't found, check vehicle number or chassis number
    if (detectedNumber == null && detectedVehicle != null) {
      detectedNumber = detectedVehicle;
      detected.add('Doc/Service No: $detectedNumber');
    } else if (detectedNumber == null) {
      final chMatch = _chassisRegex.firstMatch(text);
      if (chMatch != null) {
        final chNum = chMatch.group(1)?.trim().toUpperCase();
        if (chNum != null && chNum.length >= 8 && !_docNumberStopWords.contains(chNum.toLowerCase())) {
          detectedNumber = chNum;
          detected.add('Chassis No: $detectedNumber');
        }
      } else {
        final engMatch = _engineRegex.firstMatch(text);
        if (engMatch != null) {
          final engNum = engMatch.group(1)?.trim().toUpperCase();
          if (engNum != null && engNum.length >= 6 && !_docNumberStopWords.contains(engNum.toLowerCase())) {
            detectedNumber = engNum;
            detected.add('Engine No: $detectedNumber');
          }
        }
      }
    }

    // 4. Detect Dates with contextual expiry / due date prioritization and 2-digit year expansion
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineLower = line.toLowerCase();

      final isExpiryKeyword = lineLower.contains('fitness') ||
          lineLower.contains('regn upto') ||
          lineLower.contains('reg. upto') ||
          lineLower.contains('reg upto') ||
          lineLower.contains('tax upto') ||
          lineLower.contains('valid upto') ||
          lineLower.contains('valid till') ||
          lineLower.contains('valid to') ||
          lineLower.contains('valid until') ||
          lineLower.contains('due') ||
          lineLower.contains('exp') ||
          lineLower.contains('disconnection') ||
          lineLower.contains('pay by') ||
          lineLower.contains('best before') ||
          lineLower.contains('use by');

      final isStartKeyword = lineLower.contains('regn date') ||
          lineLower.contains('date of regn') ||
          lineLower.contains('reg. date') ||
          lineLower.contains('reg date') ||
          lineLower.contains('date of registration') ||
          lineLower.contains('registration date') ||
          lineLower.contains('issue date') ||
          lineLower.contains('date of issue') ||
          lineLower.contains('issue') ||
          lineLower.contains('start') ||
          lineLower.contains('from') ||
          lineLower.contains('bill date') ||
          lineLower.contains('mfg') ||
          lineLower.contains('invoice date') ||
          lineLower.contains('purchase date');

      // Look for text-month, numeric, and month-year dates
      final match = _textMonthDateRegex.firstMatch(line) ??
          _numericDateRegex.firstMatch(line) ??
          _monthYearDateRegex.firstMatch(line);

      DateTime? parsedDate;
      if (match != null) {
        parsedDate = _parseAnyDate(match.group(1)!);
      } else if (i + 1 < lines.length) {
        // Check adjacent line if current line has date label
        if (isExpiryKeyword ||
            isStartKeyword ||
            lineLower.contains('due date') ||
            lineLower.contains('expiry') ||
            lineLower.contains('valid till') ||
            lineLower.contains('bill date') ||
            lineLower.contains('invoice date') ||
            lineLower.contains('fitness') ||
            lineLower.contains('upto') ||
            lineLower.contains('regn')) {
          final nextMatch = _numericDateRegex.firstMatch(lines[i + 1]) ??
              _textMonthDateRegex.firstMatch(lines[i + 1]) ??
              _monthYearDateRegex.firstMatch(lines[i + 1]);
          if (nextMatch != null) {
            parsedDate = _parseAnyDate(nextMatch.group(1)!);
          }
        }
      }

      if (parsedDate != null) {

        if (isExpiryKeyword && detectedExpiry == null) {
          detectedExpiry = parsedDate;
          detected.add('Due / Expiry: ${DateFormat('dd/MM/yyyy').format(parsedDate)}');
        } else if (isStartKeyword && detectedStart == null) {
          detectedStart = parsedDate;
          detected.add('Bill / Start Date: ${DateFormat('dd/MM/yyyy').format(parsedDate)}');
        } else if (detectedExpiry == null) {
          // If future date, prioritize as due/expiry date
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

    // Fallback title from clean first lines if not yet identified
    if (detectedTitle == null && lines.isNotEmpty) {
      for (final line in lines) {
        if (line.length >= 3 &&
            line.length <= 40 &&
            !line.contains(':') &&
            !line.toLowerCase().contains('http') &&
            !RegExp(r'^\d+$').hasMatch(line)) {
          detectedTitle = line;
          break;
        }
      }
    }

    // Fallback provider from lines
    if (detectedProvider == null && lines.length > 1) {
      for (final line in lines.take(5)) {
        if (line != detectedTitle &&
            line.length >= 4 &&
            line.length <= 45 &&
            !line.contains(':') &&
            !line.toLowerCase().contains('payment') &&
            !line.toLowerCase().contains('online') &&
            !line.toLowerCase().contains('please')) {
          detectedProvider = line;
          break;
        }
      }
    }

    if (detectedTitle != null && !detected.any((d) => d.startsWith('Title:'))) {
      detected.insert(0, 'Title: $detectedTitle');
    }
    if (detectedProvider != null && !detected.any((d) => d.startsWith('Provider:'))) {
      detected.insert(1, 'Provider: $detectedProvider');
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
      // Skip action/navigation lines
      if (lineLower.contains('online') && lineLower.contains('payment')) continue;
      if (lineLower.contains('please click')) continue;
      if (lineLower.contains('details')) continue;

      for (final kw in keywords) {
        if (lineLower.contains(kw) && line.length <= 55) {
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
      'dd.MM.yy',
      'd/M/yy',
      'd-M-yy',
      'd.M.yy',
      'dd MMM yyyy',
      'dd-MMM-yyyy',
      'dd MMMM yyyy',
      'd MMM yyyy',
      'd MMMM yyyy',
      'dd MMM yy',
      'dd-MMM-yy',
      'd MMM yy',
      'MMM d yyyy',
      'MMMM d yyyy',
      'MM/yy',
      'MM/yyyy',
    ];

    for (final fmt in formats) {
      try {
        DateTime d = DateFormat(fmt, 'en_US').parseStrict(clean);
        // Correct 2-digit year (e.g. 26 -> 2026, 25 -> 2025)
        if (d.year < 100) {
          final currentYear = DateTime.now().year;
          final currentCentury = (currentYear ~/ 100) * 100;
          final adjustedYear = d.year <= 70 ? currentCentury + d.year : currentCentury - 100 + d.year;
          d = DateTime(adjustedYear, d.month, d.day, d.hour, d.minute);
        }
        return d;
      } catch (_) {}
    }
    return null;
  }
}
