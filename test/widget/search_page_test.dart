import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:keepremind/app/router/app_routes.dart';
import 'package:keepremind/core/database/app_database.dart';
import 'package:keepremind/core/enums/item_enums.dart';
import 'package:keepremind/core/storage/document_integrity_service.dart';
import 'package:keepremind/core/storage/local_file_storage.dart';
import 'package:keepremind/features/home/pages/home_page.dart';
import 'package:keepremind/features/medicine_care/cubit/medicine_cubit.dart';
import 'package:keepremind/features/medicine_care/data/repositories/medicine_repository_impl.dart';
import 'package:keepremind/features/search/pages/search_page.dart';
import 'package:keepremind/features/settings/cubit/settings_cubit.dart';
import 'package:keepremind/features/settings/pages/settings_page.dart';
import 'package:keepremind/features/tracked_items/cubit/items_cubit.dart';
import 'package:keepremind/features/tracked_items/domain/entities/tracked_item_entity.dart';
import 'package:keepremind/features/tracked_items/domain/repositories/item_repository.dart';

class FakeItemRepository implements ItemRepository {
  final _controller = StreamController<List<TrackedItemEntity>>.broadcast();
  List<TrackedItemEntity> _items;

  FakeItemRepository(this._items) {
    Future.microtask(() => _controller.add(_items));
  }

  void emitItems(List<TrackedItemEntity> items) {
    _items = items;
    _controller.add(_items);
  }

  @override
  Stream<List<TrackedItemEntity>> watchAllItems() => _controller.stream;

  @override
  Future<List<TrackedItemEntity>> getAllItems() async => _items;

  @override
  Stream<List<TrackedItemEntity>> watchItemsByCategory(ItemCategory category) =>
      _controller.stream
          .map((list) => list.where((i) => i.category == category).toList());

  @override
  Future<List<TrackedItemEntity>> getItemsByCategory(
          ItemCategory category) async =>
      _items.where((i) => i.category == category).toList();

  @override
  Future<TrackedItemEntity?> getItemById(String id) async => _items
      .cast<TrackedItemEntity?>()
      .firstWhere((i) => i?.id == id, orElse: () => null);

  @override
  Future<void> addItem({
    required TrackedItemsCompanion item,
    BillDetailsCompanion? bill,
    WarrantyDetailsCompanion? warranty,
    InsuranceDetailsCompanion? insurance,
    SubscriptionDetailsCompanion? subscription,
    PurchaseDetailsCompanion? purchase,
    GroceryDetailsCompanion? grocery,
    DocumentDetailsCompanion? document,
    List<ItemDocumentsCompanion> documents = const [],
    List<int> reminderOffsets = const [],
    String reminderTime = '09:00',
  }) async {}

  @override
  Future<void> updateItem({
    required TrackedItemsCompanion item,
    BillDetailsCompanion? bill,
    WarrantyDetailsCompanion? warranty,
    InsuranceDetailsCompanion? insurance,
    SubscriptionDetailsCompanion? subscription,
    PurchaseDetailsCompanion? purchase,
    GroceryDetailsCompanion? grocery,
    DocumentDetailsCompanion? document,
    List<ItemDocumentsCompanion>? newDocuments,
    List<int>? reminderOffsets,
    String? reminderTime,
  }) async {}

  @override
  Future<void> deleteItem(String id) async {}

  @override
  Future<void> updateItemStatus(String id, ItemStatus status) async {}

  @override
  Future<String> renewItem({
    required String oldItemId,
    required DateTime newExpiryDate,
    DateTime? newStartDate,
    String? newDocumentNumber,
    double? newAmount,
    List<ItemDocumentsCompanion>? newDocuments,
  }) async =>
      'new-item-id';

  @override
  Future<List<TrackedItemEntity>> searchItems(String query) async => _items;

  @override
  Future<List<ItemHistoryData>> getItemHistory(String itemId) async => [];

  void dispose() {
    _controller.close();
  }
}

void main() {
  final now = DateTime.now();
  final testItems = [
    TrackedItemEntity(
      baseItem: TrackedItem(
        id: 'item-1',
        category: 'life_pocket',
        subcategory: 'bill',
        title: 'Electricity Bill - BESCOM',
        description: 'Monthly office utility power bill',
        dueDate:
            now.add(const Duration(days: 2)).toIso8601String().split('T').first,
        status: 'active',
        metadataJson: '{}',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ),
      billDetails: const BillDetail(
        itemId: 'item-1',
        providerName: 'BESCOM Power Corp',
        accountNumber: 'ACC-883311',
        currencyCode: 'INR',
        paymentStatus: 'pending',
      ),
    ),
    TrackedItemEntity(
      baseItem: TrackedItem(
        id: 'item-2',
        category: 'fresh_check',
        subcategory: 'grocery',
        title: 'Organic Almond Milk',
        description: 'Refrigerated pantry dairy item',
        expiryDate:
            now.add(const Duration(days: 5)).toIso8601String().split('T').first,
        status: 'active',
        metadataJson: '{}',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ),
      groceryDetails: const GroceryDetail(
        itemId: 'item-2',
        productName: 'Organic Almond Milk',
        storageLocation: 'fridge',
        quantityRemaining: 1.0,
        quantityUnit: 'carton',
      ),
    ),
    TrackedItemEntity(
      baseItem: TrackedItem(
        id: 'item-3',
        category: 'doc_alert',
        subcategory: 'identity_doc',
        title: 'Driving Licence (DL-9988)',
        description: 'Smart card driving licence',
        expiryDate: now
            .add(const Duration(days: 365))
            .toIso8601String()
            .split('T')
            .first,
        status: 'active',
        metadataJson: '{}',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ),
      documentDetails: const DocumentDetail(
        itemId: 'item-3',
        documentNumber: 'DL-9988-IN-2024',
        issuingAuthority: 'Transport Dept AP',
        documentType: 'Driving Licence',
      ),
    ),
  ];

  late FakeItemRepository repository;
  late ItemsCubit itemsCubit;
  late AppDatabase db;
  late MedicineRepositoryImpl medicineRepo;
  late MedicineCubit medicineCubit;

  setUp(() {
    repository = FakeItemRepository(testItems);
    itemsCubit = ItemsCubit(repository: repository);
    db = AppDatabase(NativeDatabase.memory());
    medicineRepo = MedicineRepositoryImpl(db: db);
    medicineCubit = MedicineCubit(repository: medicineRepo);
  });

  tearDown(() {
    itemsCubit.close();
    medicineCubit.close();
    db.close();
    repository.dispose();
  });

  Widget buildTestableWidget({required Widget child}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ItemsCubit>.value(value: itemsCubit),
        BlocProvider<MedicineCubit>.value(value: medicineCubit),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('HomePage Search Icon & Layout Tests', () {
    testWidgets('HomePage AppBar has search icon and no add button in AppBar',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(child: const HomePage()));
      await tester.pumpAndSettle();

      // Top search icon should be present in AppBar actions
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byTooltip('Search'), findsOneWidget);

      // Floating action button provides tab-aware add action
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('+ Add Bill / Warranty'), findsOneWidget);

      // Embedded search TextField in body should be removed
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Search bills, warranties, groceries...'), findsNothing);

      // 'Everything is Safe!' banner should be removed from HomePage
      expect(find.text('Everything is Safe!'), findsNothing);

      // Core home widgets and feature cards should be cleanly visible
      expect(find.text('KeepRemind'), findsOneWidget);
      expect(find.text('Bills & Receipts'), findsOneWidget);
      expect(find.text('Warranties'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('LifePocket Items (1)'), 100);
      expect(find.text('LifePocket Items (1)'), findsOneWidget);
    });

    testWidgets('Tapping search icon navigates to SearchPage via router',
        (tester) async {
      final router = GoRouter(
        initialLocation: AppRoutes.home,
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.search,
            builder: (context, state) => const SearchPage(),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ItemsCubit>.value(value: itemsCubit),
            BlocProvider<MedicineCubit>.value(value: medicineCubit),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap search icon in AppBar
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();

      // Should now be on SearchPage
      expect(find.text('Find bills, warranties, groceries & docs'),
          findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('All Items'), findsOneWidget);
    });
  });

  group('SearchPage Dedicated Screen Tests', () {
    testWidgets(
        'SearchPage displays back button, search box, and category filters',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(child: const SearchPage()));
      await tester.pumpAndSettle();

      // Back button in AppBar
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Search box with hint
      expect(find.text('Search by item name, provider, or DL/doc number...'),
          findsOneWidget);

      // Filter chips
      expect(find.text('All Items'), findsOneWidget);
      expect(find.text('LifePocket'), findsOneWidget);
      expect(find.text('FreshCheck'), findsOneWidget);
      expect(find.text('DocAlert'), findsOneWidget);
      expect(find.text('Due Soon / Urgent'), findsOneWidget);

      // Initial list shows all 3 items
      expect(find.text('Electricity Bill - BESCOM'), findsOneWidget);
      expect(find.text('Organic Almond Milk'), findsOneWidget);
      expect(find.text('Driving Licence (DL-9988)'), findsOneWidget);
    });

    testWidgets('Searching by text filters results in real time',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(child: const SearchPage()));
      await tester.pumpAndSettle();

      // Enter search query 'Almond'
      await tester.enterText(find.byType(TextField), 'Almond');
      await tester.pumpAndSettle();

      expect(find.text('Organic Almond Milk'), findsOneWidget);
      expect(find.text('Electricity Bill - BESCOM'), findsNothing);
      expect(find.text('Driving Licence (DL-9988)'), findsNothing);
      expect(find.text('1 result for "almond"'), findsOneWidget);

      // Enter doc number 'DL-9988'
      await tester.enterText(find.byType(TextField), 'DL-9988');
      await tester.pumpAndSettle();

      expect(find.text('Driving Licence (DL-9988)'), findsOneWidget);
      expect(find.text('Organic Almond Milk'), findsNothing);
      expect(find.text('Electricity Bill - BESCOM'), findsNothing);
    });

    testWidgets('Category chips filter items correctly', (tester) async {
      await tester.pumpWidget(buildTestableWidget(child: const SearchPage()));
      await tester.pumpAndSettle();

      // Tap 'FreshCheck' filter chip
      await tester.tap(find.text('FreshCheck'));
      await tester.pumpAndSettle();

      expect(find.text('Organic Almond Milk'), findsOneWidget);
      expect(find.text('Electricity Bill - BESCOM'), findsNothing);
      expect(find.text('Driving Licence (DL-9988)'), findsNothing);

      // Tap 'LifePocket' filter chip
      await tester.tap(find.text('LifePocket'));
      await tester.pumpAndSettle();

      expect(find.text('Electricity Bill - BESCOM'), findsOneWidget);
      expect(find.text('Organic Almond Milk'), findsNothing);
      expect(find.text('Driving Licence (DL-9988)'), findsNothing);
    });

    testWidgets(
        'Empty search shows clean EmptyStateView with Clear Search button',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(child: const SearchPage()));
      await tester.pumpAndSettle();

      // Enter unmatched search query
      await tester.enterText(find.byType(TextField), 'NonExistentItem999');
      await tester.pumpAndSettle();

      expect(find.text('No matches found'), findsOneWidget);
      expect(find.text('Clear Search'), findsOneWidget);

      // Tap Clear Search button
      await tester.tap(find.text('Clear Search'));
      await tester.pumpAndSettle();

      // Restores all items
      expect(find.text('Electricity Bill - BESCOM'), findsOneWidget);
      expect(find.text('Organic Almond Milk'), findsOneWidget);
      expect(find.text('Driving Licence (DL-9988)'), findsOneWidget);
    });
  });

  group('SettingsPage Urgency Status Banner Tests', () {
    testWidgets('SettingsPage renders status banner with safe state',
        (tester) async {
      final safeRepo = FakeItemRepository([]);
      final safeCubit = ItemsCubit(repository: safeRepo);
      final db = AppDatabase(NativeDatabase.memory());
      final settingsCubit = SettingsCubit(
        database: db,
        fileStorage: LocalFileStorage(
            integrityService: const DocumentIntegrityService()),
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ItemsCubit>.value(value: safeCubit),
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
          ],
          child: const MaterialApp(
            home: SettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // SettingsPage displays the status banner
      expect(find.text('Everything is Safe!'), findsOneWidget);
      expect(find.text('No bills or products expiring soon.'), findsOneWidget);

      safeCubit.close();
      safeRepo.dispose();
      await settingsCubit.close();
      await db.close();
    });

    testWidgets('SettingsPage renders urgent alert when items need attention',
        (tester) async {
      final urgentItems = [
        TrackedItemEntity(
          baseItem: TrackedItem(
            id: 'urgent-1',
            category: 'life_pocket',
            subcategory: 'bill',
            title: 'Water Bill Due Today',
            dueDate: DateTime.now().toIso8601String().split('T').first,
            status: 'due_today',
            metadataJson: '{}',
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
        ),
      ];

      final urgentRepo = FakeItemRepository(urgentItems);
      final urgentCubit = ItemsCubit(repository: urgentRepo);
      final db = AppDatabase(NativeDatabase.memory());
      final settingsCubit = SettingsCubit(
        database: db,
        fileStorage: LocalFileStorage(
            integrityService: const DocumentIntegrityService()),
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ItemsCubit>.value(value: urgentCubit),
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
          ],
          child: const MaterialApp(
            home: SettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 Items Need Attention'), findsOneWidget);
      expect(find.text('Due today or upcoming in the next 7 days.'),
          findsOneWidget);

      urgentCubit.close();
      urgentRepo.dispose();
      await settingsCubit.close();
      await db.close();
    });
  });
}
