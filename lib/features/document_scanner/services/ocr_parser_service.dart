import 'package:intl/intl.dart';
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
    this.confidence = 0.8,
    this.detectedFields = const [],
  });
}

class OcrParserService {
  const OcrParserService();

  static final RegExp _amountRegex = RegExp(
    r'(?:total\s+amount|amount\s+due|total\s+due|total\s+premium|net\s+amount|bill\s+amount|total|amount|premium|fee|inr|rs\.?|₹)\s*[:\-]?\s*([0-9]+(?:,[0-9]{3})*(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );
  static final RegExp _dateRegex = RegExp(r'(\d{1,2}[/\-\.]\d{1,2}[/\-\.]\d{2,4})');
  static final RegExp _policyRegex = RegExp(
    r'(?:policy|certificate|document|dl|acc(?:ount)?)\s*(?:no|num|number)?\s*[:\-]?\s*([A-Z0-9\-\/]{5,20})',
    caseSensitive: false,
  );
  static final RegExp _vehicleRegex = RegExp(r'[A-Z]{2}[0-9]{1,2}[A-Z]{1,2}[0-9]{4}', caseSensitive: false);

  ParsedOcrResult parse({
    required String text,
    ItemSubcategory? expectedSubcategory,
  }) {
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    final detected = <String>[];

    String? detectedTitle;
    String? detectedProvider;
    String? detectedNumber;
    String? detectedVehicle;
    DateTime? detectedStart;
    DateTime? detectedExpiry;
    double? detectedAmount;

    // Detect amounts (ignoring lines containing date words)
    for (final line in lines) {
      if (line.toLowerCase().contains('date')) continue;
      final match = _amountRegex.firstMatch(line);
      if (match != null) {
        final clean = match.group(1)?.replaceAll(',', '');
        if (clean != null) {
          final val = double.tryParse(clean);
          if (val != null) {
            detectedAmount = val;
            detected.add('Amount: ₹$detectedAmount');
            break;
          }
        }
      }
    }

    // Detect policy or document numbers
    final policyMatch = _policyRegex.firstMatch(text);
    if (policyMatch != null) {
      detectedNumber = policyMatch.group(1)?.trim();
      if (detectedNumber != null && detectedNumber.length >= 4) {
        detected.add('Doc / Policy No: $detectedNumber');
      }
    }

    // Detect Indian vehicle registration pattern (e.g. KA01AB1234, DL01C1234)
    final vehicleMatch = _vehicleRegex.firstMatch(text);
    if (vehicleMatch != null) {
      detectedVehicle = vehicleMatch.group(0)?.toUpperCase();
      detected.add('Vehicle: $detectedVehicle');
    }

    // Detect dates with contextual cues
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineLower = line.toLowerCase();

      final dateMatch = _dateRegex.firstMatch(line);
      if (dateMatch != null) {
        final parsedDate = _parseAnyDate(dateMatch.group(1)!);
        if (parsedDate != null) {
          if (lineLower.contains('exp') ||
              lineLower.contains('valid to') ||
              lineLower.contains('valid until') ||
              lineLower.contains('valid till') ||
              lineLower.contains('due') ||
              lineLower.contains('best before') ||
              lineLower.contains('use by')) {
            detectedExpiry = parsedDate;
            detected.add('Expiry / Due: ${DateFormat('yyyy-MM-dd').format(parsedDate)}');
          } else if (lineLower.contains('issue') ||
              lineLower.contains('start') ||
              lineLower.contains('from') ||
              lineLower.contains('bill date')) {
            detectedStart = parsedDate;
            detected.add('Start Date: ${DateFormat('yyyy-MM-dd').format(parsedDate)}');
          } else if (detectedExpiry == null) {
            // Unlabeled date: could be expiry or bill date
            detectedExpiry = parsedDate;
            detected.add('Detected Date: ${DateFormat('yyyy-MM-dd').format(parsedDate)}');
          }
        }
      }
    }

    // If first lines have text, use for title/provider suggestion
    if (lines.isNotEmpty) {
      detectedTitle = lines.first;
      if (lines.length > 1) {
        detectedProvider = lines[1];
      }
    }

    final confidence = detected.isNotEmpty ? (detected.length >= 3 ? 0.9 : 0.7) : 0.3;

    return ParsedOcrResult(
      rawText: text,
      title: detectedTitle,
      providerOrSeller: detectedProvider,
      documentOrPolicyNumber: detectedNumber,
      vehicleNumber: detectedVehicle,
      startDate: detectedStart,
      expiryDate: detectedExpiry,
      amount: detectedAmount,
      confidence: confidence,
      detectedFields: detected,
    );
  }

  DateTime? _parseAnyDate(String str) {
    final formats = [
      'dd/MM/yyyy',
      'dd-MM-yyyy',
      'yyyy-MM-dd',
      'MM/dd/yyyy',
      'dd.MM.yyyy',
      'd/M/yyyy',
      'd-M-yyyy',
    ];
    for (final fmt in formats) {
      try {
        return DateFormat(fmt).parseStrict(str);
      } catch (_) {}
    }
    return null;
  }
}
