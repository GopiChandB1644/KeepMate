import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepremind/core/enums/item_enums.dart';
import 'package:keepremind/features/tracked_items/cubit/items_cubit.dart';
import 'package:keepremind/features/tracked_items/pages/add_edit_item_page.dart';
import 'home_tabbed_flow_test.dart';

void main() {
  late MockTabbedItemRepository repo;
  late ItemsCubit itemsCubit;

  setUp(() {
    repo = MockTabbedItemRepository([]);
    itemsCubit = ItemsCubit(repository: repo);
  });

  tearDown(() {
    itemsCubit.close();
    repo.dispose();
  });

  Widget buildTestableAddPage({
    ItemSubcategory? subcategory,
    String? title,
    StorageLocation? storage,
  }) {
    return BlocProvider<ItemsCubit>.value(
      value: itemsCubit,
      child: MaterialApp(
        home: AddEditItemPage(
          initialSubcategory: subcategory,
          initialTitle: title,
          initialStorageLocation: storage,
        ),
      ),
    );
  }

  group('AddEditItemPage Tailored Type Tests', () {
    testWidgets('Bill flow shows only bill fields and hides unrelated chips and grocery fields', (tester) async {
      await tester.pumpWidget(buildTestableAddPage(subcategory: ItemSubcategory.bill));
      await tester.pumpAndSettle();

      // Tailored AppBar
      expect(find.text('Add Bill / Receipt'), findsOneWidget);
      expect(find.text('Scan bill or enter payment due date'), findsOneWidget);

      // Category & Type badge
      expect(find.text('LIFEPOCKET'), findsOneWidget);
      expect(find.text('Bill'), findsOneWidget);

      // Unrelated 7-chip dump is removed
      expect(find.text('What are you tracking?'), findsNothing);

      // Tailored scan banner
      expect(find.text('Have a bill or receipt?'), findsOneWidget);

      // Tailored form fields for bill
      expect(find.text('Bill Name *'), findsOneWidget);
      expect(find.text('Payment Due Date *'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Account / Service / Consumer Number'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Account / Service / Consumer Number'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Bill Amount (₹)'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Bill Amount (₹)'), findsOneWidget);

      // Grocery-specific fields must NOT be shown
      expect(find.text('Storage Location'), findsNothing);
      expect(find.text('Quantity'), findsNothing);
    });

    testWidgets('Grocery flow shows storage location and quantity and hides bill amount and account number', (tester) async {
      await tester.pumpWidget(buildTestableAddPage(
        subcategory: ItemSubcategory.grocery,
        title: 'Fresh Almond Milk',
        storage: StorageLocation.fridge,
      ));
      await tester.pumpAndSettle();

      // Tailored AppBar
      expect(find.text('Add Food / Grocery'), findsOneWidget);
      expect(find.text('Track food expiry & storage location'), findsOneWidget);

      // Category & Type badge
      expect(find.text('FRESHCHECK'), findsOneWidget);
      expect(find.text('Grocery / Food'), findsOneWidget);

      // Pre-filled Title
      expect(find.text('Fresh Almond Milk'), findsOneWidget);

      // Grocery-specific fields ARE shown
      expect(find.text('Storage Location'), findsOneWidget);
      expect(find.text('Quantity'), findsOneWidget);

      // Bill/doc fields must NOT be shown
      expect(find.text('Account / Service / Consumer Number'), findsNothing);
      expect(find.text('Document / Registration Number'), findsNothing);
      expect(find.text('Amount (₹)'), findsNothing);
      expect(find.text('Bill Amount (₹)'), findsNothing);
    });

    testWidgets('Official Document flow shows registration and issuing authority and hides amount and storage', (tester) async {
      await tester.pumpWidget(buildTestableAddPage(
        subcategory: ItemSubcategory.document,
        title: 'Driving Licence',
      ));
      await tester.pumpAndSettle();

      // Tailored AppBar
      expect(find.text('Add Official Document'), findsOneWidget);

      // Category & Type badge
      expect(find.text('DOCALERT'), findsOneWidget);
      expect(find.text('Official Document'), findsOneWidget);

      // Document fields
      expect(find.text('Document Name *'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Document / Registration Number'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Document / Registration Number'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Issuing Authority / Issuer'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Issuing Authority / Issuer'), findsOneWidget);

      // Irrelevant fields are hidden
      expect(find.text('Storage Location'), findsNothing);
      expect(find.text('Quantity'), findsNothing);
      expect(find.text('Amount (₹)'), findsNothing);
    });
  });
}
