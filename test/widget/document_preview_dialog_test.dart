import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepremind/core/database/app_database.dart';
import 'package:keepremind/shared/widgets/document_preview_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Renders PDF view mode with Open/Share button', (tester) async {
    final tempPdf = File('${Directory.systemTemp.path}/test_mock_${DateTime.now().millisecondsSinceEpoch}.pdf');
    tempPdf.writeAsStringSync('%PDF-1.4 mock content');

    final mockDoc = ItemDocument(
      id: 'doc-1',
      fileName: 'Invoice_Nov2026.pdf',
      relativePath: 'documents/Invoice_Nov2026.pdf',
      mimeType: 'application/pdf',
      fileSize: 45000,
      checksumSha256: 'abc123sha',
      source: 'upload',
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DocumentPreviewDialog(
              file: tempPdf,
              document: mockDoc,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Invoice_Nov2026.pdf'), findsOneWidget);
      expect(find.text('PDF Document Ready'), findsOneWidget);
      expect(find.text('Open / Share Document'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    } finally {
      if (tempPdf.existsSync()) tempPdf.deleteSync();
    }
  });
}
