import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:keepremind/app/router/app_routes.dart';
import 'package:keepremind/app/shell/main_shell.dart';
import 'package:keepremind/core/database/app_database.dart';
import 'package:keepremind/core/enums/item_enums.dart';
import 'package:keepremind/features/home/pages/home_page.dart';
import 'package:keepremind/features/medicine_care/cubit/medicine_cubit.dart';
import 'package:keepremind/features/medicine_care/data/repositories/medicine_repository_impl.dart';
import 'package:keepremind/features/tracked_items/cubit/items_cubit.dart';
import 'package:keepremind/features/tracked_items/domain/entities/tracked_item_entity.dart';
import 'package:keepremind/features/tracked_items/domain/repositories/item_repository.dart';
import 'package:keepremind/features/tracked_items/pages/add_edit_item_page.dart';

class MockTabbedItemRepository implements ItemRepository {
  final _controller = StreamController<List<TrackedItemEntity>>.broadcast();
  final List<TrackedItemEntity> _items;

  MockTabbedItemRepository(this._items) {
    Future.microtask(() => _controller.add(_items));
  }

  @override
  Stream<List<TrackedItemEntity>> watchAllItems() => _controller.stream;

  @override
  Future<List<TrackedItemEntity>> getAllItems() async => _items;

  @override
  Stream<List<TrackedItemEntity>> watchItemsByCategory(ItemCategory category) =>
      _controller.stream.map((list) => list.where((i) => i.category == category).toList());

  @override
  Future<List<TrackedItemEntity>> getItemsByCategory(ItemCategory category) async =>
      _items.where((i) => i.category == category).toList();

  @override
  Future<TrackedItemEntity?> getItemById(String id) async =>
      _items.cast<TrackedItemEntity?>().firstWhere((i) => i?.id == id, orElse: () => null);

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
  }) async => 'renewed-id';

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
  final sampleItems = [
    TrackedItemEntity(
      baseItem: TrackedItem(
        id: 'bill-1',
        category: 'life_pocket',
        subcategory: 'bill',
        title: 'Electricity Bill',
        dueDate: now.add(const Duration(days: 3)).toIso8601String().split('T').first,
        status: 'active',
        metadataJson: '{}',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ),
      billDetails: const BillDetail(
        itemId: 'bill-1',
        providerName: 'BESCOM',
        currencyCode: 'INR',
        paymentStatus: 'pending',
      ),
    ),
    TrackedItemEntity(
      baseItem: TrackedItem(
        id: 'food-1',
        category: 'fresh_check',
        subcategory: 'grocery',
        title: 'Fresh Almond Milk',
        expiryDate: now.add(const Duration(days: 5)).toIso8601String().split('T').first,
        status: 'active',
        metadataJson: '{}',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ),
      groceryDetails: const GroceryDetail(
        itemId: 'food-1',
        productName: 'Fresh Almond Milk',
        storageLocation: 'fridge',
        quantityRemaining: 1.0,
        quantityUnit: 'carton',
      ),
    ),
    TrackedItemEntity(
      baseItem: TrackedItem(
        id: 'doc-1',
        category: 'doc_alert',
        subcategory: 'document',
        title: 'Driving Licence (DL-12345)',
        expiryDate: now.add(const Duration(days: 300)).toIso8601String().split('T').first,
        status: 'active',
        metadataJson: '{}',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ),
      documentDetails: const DocumentDetail(
        itemId: 'doc-1',
        documentNumber: 'DL-12345',
        documentType: 'Driving Licence',
      ),
    ),
  ];

  late MockTabbedItemRepository repo;
  late ItemsCubit itemsCubit;
  late AppDatabase db;
  late MedicineRepositoryImpl medicineRepo;
  late MedicineCubit medicineCubit;

  setUp(() {
    repo = MockTabbedItemRepository(sampleItems);
    itemsCubit = ItemsCubit(repository: repo);
    db = AppDatabase(NativeDatabase.memory());
    medicineRepo = MedicineRepositoryImpl(db: db);
    medicineCubit = MedicineCubit(repository: medicineRepo);
  });

  tearDown(() {
    itemsCubit.close();
    medicineCubit.close();
    db.close();
    repo.dispose();
  });

  Widget buildTestableHome() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ItemsCubit>.value(value: itemsCubit),
        BlocProvider<MedicineCubit>.value(value: medicineCubit),
      ],
      child: const MaterialApp(
        home: HomePage(),
      ),
    );
  }

  group('Home Tabbed Flow & 2x2 Feature Cards Tests', () {
    testWidgets('Home screen defaults to LifePocket tab with 2x2 feature cards and LifePocket FAB', (tester) async {
      await tester.pumpWidget(buildTestableHome());
      await tester.pumpAndSettle();

      // Top segmented pills exist
      expect(find.text('LifePocket'), findsNWidgets(2)); // in pill and section header
      expect(find.text('FreshCheck'), findsOneWidget);
      expect(find.text('DocAlert'), findsOneWidget);

      // Category Header
      expect(find.text('YOUR PERSONAL ORGANIZER'), findsOneWidget);

      // LifePocket 2x2 Feature Cards
      expect(find.text('Bills & Receipts'), findsOneWidget);
      expect(find.text('Purchase records'), findsOneWidget);
      expect(find.text('Warranties'), findsOneWidget);
      expect(find.text('Product protection'), findsOneWidget);
      expect(find.text('Subscriptions'), findsOneWidget);
      expect(find.text('Recurring payments'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);
      expect(find.text('Upcoming dues'), findsOneWidget);

      // Dynamic FAB for LifePocket
      expect(find.text('+ Add Bill / Warranty'), findsOneWidget);

      // Only LifePocket items listed
      await tester.scrollUntilVisible(find.text('Electricity Bill'), 100);
      expect(find.text('Electricity Bill'), findsOneWidget);
      expect(find.text('Fresh Almond Milk'), findsNothing);
      expect(find.text('Driving Licence (DL-12345)'), findsNothing);
    });

    testWidgets('Switching to FreshCheck tab updates feature cards, FAB, and items', (tester) async {
      await tester.pumpWidget(buildTestableHome());
      await tester.pumpAndSettle();

      // Tap 'FreshCheck' segmented pill
      await tester.tap(find.text('FreshCheck'));
      await tester.pumpAndSettle();

      // Category Header for FreshCheck
      expect(find.text('FOOD EXPIRIES & PANTRY ORGANIZER'), findsOneWidget);

      // FreshCheck 2x2 Feature Cards
      expect(find.text('Dairy & Fridge'), findsOneWidget);
      expect(find.text('Milk & perishables'), findsOneWidget);
      expect(find.text('Pantry & Staples'), findsOneWidget);
      expect(find.text('Grains & snacks'), findsOneWidget);
      expect(find.text('Fruits & Veggies'), findsOneWidget);
      expect(find.text('Fresh farm produce'), findsOneWidget);
      expect(find.text('Medicines & Care'), findsOneWidget);
      expect(find.text('Tablets & syrups'), findsOneWidget);

      // Dynamic FAB for FreshCheck
      expect(find.text('+ Add Food / Grocery'), findsOneWidget);

      // Only FreshCheck items listed
      await tester.scrollUntilVisible(find.text('Fresh Almond Milk'), 100);
      expect(find.text('Fresh Almond Milk'), findsOneWidget);
      expect(find.text('Electricity Bill'), findsNothing);
      expect(find.text('Driving Licence (DL-12345)'), findsNothing);
    });

    testWidgets('Switching to DocAlert tab updates feature cards, FAB, and items', (tester) async {
      await tester.pumpWidget(buildTestableHome());
      await tester.pumpAndSettle();

      // Tap 'DocAlert' segmented pill
      await tester.tap(find.text('DocAlert'));
      await tester.pumpAndSettle();

      // Category Header for DocAlert
      expect(find.text('IDENTITY, VEHICLE & OFFICIAL DOCUMENTS'), findsOneWidget);

      // DocAlert 2x2 Feature Cards
      expect(find.text('Driving Licence'), findsOneWidget);
      expect(find.text('DL smart card & info'), findsOneWidget);
      expect(find.text('Vehicle RC & PUC'), findsOneWidget);
      expect(find.text('Registration & emission'), findsOneWidget);
      expect(find.text('Passport & Visa'), findsOneWidget);
      expect(find.text('Travel & official IDs'), findsOneWidget);
      expect(find.text('Identity & Cards'), findsOneWidget);
      expect(find.text('Aadhaar, PAN & certificates'), findsOneWidget);

      // Dynamic FAB for DocAlert
      expect(find.text('+ Add Document'), findsOneWidget);

      // Only DocAlert items listed
      await tester.scrollUntilVisible(find.text('Driving Licence (DL-12345)'), 100);
      expect(find.text('Driving Licence (DL-12345)'), findsOneWidget);
      expect(find.text('Electricity Bill'), findsNothing);
      expect(find.text('Fresh Almond Milk'), findsNothing);
    });

    testWidgets('Tapping feature card navigates to AddEditItemPage with pre-filled metadata', (tester) async {
      String navigatedLocation = '';
      Object? navigatedExtra;

      final router = GoRouter(
        initialLocation: AppRoutes.home,
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.addItem,
            builder: (context, state) {
              navigatedLocation = AppRoutes.addItem;
              navigatedExtra = state.extra;
              final extra = state.extra;
              if (extra is Map<String, dynamic>) {
                return AddEditItemPage(
                  initialSubcategory: extra['subcategory'] as ItemSubcategory?,
                  initialTitle: extra['title'] as String?,
                );
              }
              return const AddEditItemPage();
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ItemsCubit>.value(value: itemsCubit),
            BlocProvider<MedicineCubit>.value(value: medicineCubit),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Bills & Receipts' feature card
      await tester.tap(find.text('Bills & Receipts'));
      await tester.pumpAndSettle();

      expect(navigatedLocation, AppRoutes.addItem);
      expect(navigatedExtra is Map<String, dynamic>, isTrue);
      final extraMap = navigatedExtra as Map<String, dynamic>;
      expect(extraMap['subcategory'], ItemSubcategory.bill);
    });

    testWidgets('Simplified 3-tab Bottom Navbar displays Home, Vault, and Settings', (tester) async {
      final router = GoRouter(
        initialLocation: AppRoutes.home,
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.home,
                    builder: (context, state) => const Text('Home Branch Content'),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.vault,
                    builder: (context, state) => const Text('Vault Branch Content'),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.settings,
                    builder: (context, state) => const Text('Settings Branch Content'),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Bottom navbar items
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Vault'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Redundant 'Categories' tab is not in the bottom navbar
      expect(find.text('Categories'), findsNothing);

      // Tapping Vault switches branch
      await tester.tap(find.text('Vault'));
      await tester.pumpAndSettle();
      expect(find.text('Vault Branch Content'), findsOneWidget);
    });
  });
}
