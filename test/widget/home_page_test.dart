import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepremind/core/database/app_database.dart';
import 'package:keepremind/core/enums/item_enums.dart';
import 'package:keepremind/features/tracked_items/domain/entities/tracked_item_entity.dart';
import 'package:keepremind/shared/widgets/app_cards.dart';
import 'package:keepremind/shared/widgets/status_chip.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('StatusChip renders active status correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusChip(status: ItemStatus.active),
          ),
        ),
      );

      expect(find.text('Safe / Active'), findsOneWidget);
    });

    testWidgets('ItemSummaryCard renders title and tap action works', (tester) async {
      var tapped = false;
      final mockItem = TrackedItemEntity(
        baseItem: TrackedItem(
          id: 'test-1',
          category: 'life_pocket',
          subcategory: 'bill',
          title: 'Electricity Bill',
          dueDate: '2026-12-01',
          expiryDate: '2026-12-01',
          status: 'active',
          metadataJson: '{}',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemSummaryCard(
              item: mockItem,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Electricity Bill'), findsOneWidget);
      expect(find.text('Bill'), findsOneWidget);

      await tester.tap(find.text('Electricity Bill'));
      expect(tapped, isTrue);
    });
  });
}
