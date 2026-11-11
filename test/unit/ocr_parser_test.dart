import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepmate/core/enums/item_enums.dart';
import 'package:keepmate/features/document_scanner/services/ocr_parser_service.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

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

    test('Parses APCPDCL electricity bill from user photo', () {
      const sample = '''
CENTRAL POWER
Distribution Corporation of A.P. Ltd.

Online Electricity Bill Payment

Unique Service Number: 4345324000015
Service Type: SL
Customer Name: BOKKISAM PUTAIAH
Circle Name: PRAKASAM
ERO Code: 434
Arrear Amount: 0.0
Current Demand: 256.0
ACD Amount: 0.0
Reconnection Fee: 0
Bill Date: 10/11/26
Due Date: 25/11/26
Disconnection Date: 11/12/26
Bill Amount: 256.00
''';

      final result = parser.parse(text: sample);
      expect(result.title, equals('Electricity Bill'));
      expect(result.providerOrSeller, contains('CENTRAL POWER'));
      expect(result.documentOrPolicyNumber, equals('4345324000015'));
      expect(result.amount, equals(256.00));
      expect(result.expiryDate?.year, equals(2026));
      expect(result.expiryDate?.month, equals(11));
      expect(result.expiryDate?.day, equals(25));
      expect(result.startDate?.year, equals(2026));
      expect(result.startDate?.month, equals(11));
      expect(result.startDate?.day, equals(10));
      expect(result.detectedSubcategory, equals(ItemSubcategory.bill));
      expect(result.detectedFields.any((f) => f.contains('4345324000015')), isTrue);
      expect(result.detectedFields.any((f) => f.contains('256')), isTrue);
    });

    test('Extracts text from PDF generated via Syncfusion', () async {
      final doc = PdfDocument();
      final page = doc.pages.add();
      page.graphics.drawString(
        'Electricity Bill\nConsumer Number: 9876543210\nBill Date: 01/10/2026\nDue Date: 15/10/2026\nTotal Amount: 2450.00',
        PdfStandardFont(PdfFontFamily.helvetica, 12),
      );
      final bytes = doc.saveSync();
      doc.dispose();

      final tempFile = File('test_temp_bill.pdf');
      await tempFile.writeAsBytes(bytes);

      try {
        final extracted = await OcrParserService.extractTextFromPdf(tempFile);
        expect(extracted, contains('Electricity Bill'));
        expect(extracted, contains('2450.00'));

        final parsed = parser.parse(text: extracted);
        expect(parsed.amount, equals(2450.00));
        expect(parsed.documentOrPolicyNumber, equals('9876543210'));
        expect(parsed.expiryDate?.year, equals(2026));
        expect(parsed.expiryDate?.month, equals(10));
        expect(parsed.expiryDate?.day, equals(15));
      } finally {
        if (tempFile.existsSync()) tempFile.deleteSync();
      }
    });

    test('Parses Vehicle RC (Registration Certificate) front and back scan text', () {
      const rcText = '''
--- PAGE 1 ---
GOVERNMENT OF ANDHRA PRADESH
TRANSPORT DEPARTMENT
CERTIFICATE OF REGISTRATION
FORM 23
Regn. No.: AP 04 TE 1234
Date of Regn: 16/08/2020
Owner Name: GOPICHAND K
S/W/D of: RAMA RAO
Class of Vehicle: MOTOR CYCLE
Maker's Name: HONDA MOTORCYCLE & SCOOTER
Model Name: ACTIVA 6G

--- PAGE 2 ---
Chassis No: ME4JF501234567890
Engine No: JF50E1234567
Fuel Used: PETROL
Regn. Upto: 15/08/2035
Fitness Valid Upto: 15/08/2035
Tax Valid Upto: LIFE TIME
Registering Authority: ONGOLE
''';

      final result = parser.parse(text: rcText);

      expect(result.detectedSubcategory, equals(ItemSubcategory.document));
      expect(result.title, contains('Vehicle RC'));
      expect(result.title, contains('AP04TE1234'));
      expect(result.vehicleNumber, equals('AP04TE1234'));
      expect(result.documentOrPolicyNumber, equals('AP04TE1234'));
      expect(result.providerOrSeller, anyOf(contains('Transport Department'), contains('GOVERNMENT')));
      expect(result.startDate?.day, equals(16));
      expect(result.startDate?.month, equals(8));
      expect(result.startDate?.year, equals(2020));
      expect(result.expiryDate?.day, equals(15));
      expect(result.expiryDate?.month, equals(8));
      expect(result.expiryDate?.year, equals(2035));
      expect(result.confidence, greaterThanOrEqualTo(0.8));
    });

    test('Parses Karnataka Vehicle RC with hyphenated reg number and fitness date', () {
      const karnatakaRc = '''
GOVERNMENT OF KARNATAKA
TRANSPORT DEPARTMENT
REGISTRATION CERTIFICATE
Reg. No: KA-01-AB-1234
Date of Regn: 12-04-2022
Fitness Upto: 11-04-2037
Chassis Number: MA3ERFB1S00123456
''';

      final result = parser.parse(text: karnatakaRc);

      expect(result.detectedSubcategory, equals(ItemSubcategory.document));
      expect(result.vehicleNumber, equals('KA01AB1234'));
      expect(result.title, equals('Vehicle RC (KA01AB1234)'));
      expect(result.startDate?.year, equals(2022));
      expect(result.expiryDate?.year, equals(2037));
      expect(result.documentOrPolicyNumber, equals('KA01AB1234'));
    });

    test('Parses BH Series vehicle registration correctly', () {
      const bhRc = '''
TRANSPORT DEPARTMENT
FORM 23
Registration No: 22 BH 1234 AA
Date of Registration: 01/03/2022
Valid Upto: 28/02/2037
''';

      final result = parser.parse(text: bhRc);

      expect(result.detectedSubcategory, equals(ItemSubcategory.document));
      expect(result.vehicleNumber, equals('22BH1234AA'));
      expect(result.startDate?.year, equals(2022));
      expect(result.expiryDate?.year, equals(2037));
    });
  });
}
