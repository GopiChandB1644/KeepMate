import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepremind/shared/widgets/widgets.dart';

void main() {
  group('KeepRemindAppBar & Toast Widget Tests', () {
    testWidgets('KeepRemindAppBar renders title, subtitle, and action', (tester) async {
      var backTapped = false;
      var actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: KeepRemindAppBar(
              title: 'Add New Item',
              subtitle: 'Enter details or attach document',
              showBack: true,
              onBack: () => backTapped = true,
              actions: [
                CircleIconButton(
                  icon: Icons.check,
                  tooltip: 'Save',
                  onTap: () => actionTapped = true,
                ),
              ],
            ),
            body: const Center(child: Text('Content')),
          ),
        ),
      );

      expect(find.text('Add New Item'), findsOneWidget);
      expect(find.text('Enter details or attach document'), findsOneWidget);
      expect(find.byType(CircleIconButton), findsNWidgets(2)); // Back button + Save action

      await tester.tap(find.byTooltip('Save'));
      expect(actionTapped, isTrue);

      await tester.tap(find.byTooltip('Back'));
      expect(backTapped, isTrue);
    });

    testWidgets('showToast displays floating message at top of screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  showToast(
                    ctx,
                    'Document details extracted successfully!',
                    type: ToastType.success,
                  );
                },
                child: const Text('Show Toast'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Toast'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Document details extracted successfully!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });
}

