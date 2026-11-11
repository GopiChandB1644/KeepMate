import 'package:flutter_test/flutter_test.dart';
import 'package:keepmate/core/enums/item_enums.dart';
import 'package:keepmate/features/document_scanner/services/ocr_parser_service.dart';

void main() {
  group('OCR Parser Service Tests', () {
    const parser = OcrParserService();

    test('Parses insurance document text correctly', () {
      const sample = '''
HDFC ERGO General Insurance
Policy Number: POL-9988123
Vehicle Number: KA01AB1234
Valid From: 01/01/2026
Valid Until: 31/12/2026
Total Premium: 4520.00
''';

      final result = parser.parse(text: sample, expectedSubcategory: ItemSubcategory.insurance);

      expect(result.documentOrPolicyNumber, contains('POL-9988123'));
      expect(result.vehicleNumber, equals('KA01AB1234'));
      expect(result.amount, equals(4520.00));
      expect(result.startDate, isNotNull);
      expect(result.expiryDate, isNotNull);
      expect(result.expiryDate?.year, equals(2026));
      expect(result.confidence, greaterThanOrEqualTo(0.7));
    });

    test('Parses utility bill text correctly', () {
      const sample = '''
BESCOM Electricity Bill
Account No: 83921092
Bill Date: 01/11/2026
Due Date: 20/11/2026
Total Due: 1420.50
''';

      final result = parser.parse(text: sample, expectedSubcategory: ItemSubcategory.bill);

      expect(result.amount, equals(1420.50));
      expect(result.expiryDate, isNotNull);
      expect(result.expiryDate?.day, equals(20));
      expect(result.expiryDate?.month, equals(11));
    });

    test('Parses alphanumeric month dates and broadband bills', () {
      const sample = '''
Airtel Broadband
Consumer No: AB129034
Invoice Date: 05 Nov 2026
Payment Due Date: 25 Nov 2026
Total Amount Due: ₹ 1,299.00
''';

      final result = parser.parse(text: sample);

      expect(result.amount, equals(1299.00));
      expect(result.documentOrPolicyNumber, contains('AB129034'));
      expect(result.expiryDate?.day, equals(25));
      expect(result.expiryDate?.month, equals(11));
      expect(result.expiryDate?.year, equals(2026));
      expect(result.detectedSubcategory, equals(ItemSubcategory.bill));
    });
  });
}
