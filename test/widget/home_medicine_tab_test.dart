import 'dart:async';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:keepremind/core/database/app_database.dart';
import 'package:keepremind/core/enums/item_enums.dart';
import 'package:keepremind/features/home/pages/home_page.dart';
import 'package:keepremind/features/medicine_care/cubit/medicine_cubit.dart';
import 'package:keepremind/features/medicine_care/data/repositories/medicine_repository_impl.dart';
import 'package:keepremind/features/tracked_items/cubit/items_cubit.dart';
import 'package:keepremind/features/tracked_items/domain/entities/tracked_item_entity.dart';
import 'package:keepremind/features/tracked_items/domain/repositories/item_repository.dart';

class MockTabbedItemRepository implements ItemRepository {
  final _controller = StreamController<List<TrackedItemEntity>>.broadcast();

  MockTabbedItemRepository() {
    Future.microtask(() => _controller.add([]));
  }

  @override
  Stream<List<TrackedItemEntity>> watchAllItems() => _controller.stream;

  @override
  Future<List<TrackedItemEntity>> getAllItems() async => [];

  @override
  Stream<List<TrackedItemEntity>> watchItemsByCategory(ItemCategory category) =>
      _controller.stream
          .map((list) => list.where((i) => i.category == category).toList());

  @override
  Future<List<TrackedItemEntity>> getItemsByCategory(
          ItemCategory category) async =>
      [];

  @override
  Future<TrackedItemEntity?> getItemById(String id) async => null;

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
      'renewed-id';

  @override
  Future<List<TrackedItemEntity>> searchItems(String query) async => [];

  @override
  Future<List<ItemHistoryData>> getItemHistory(String itemId) async => [];

  void dispose() {
    _controller.close();
  }
}

void main() {
  late MockTabbedItemRepository itemsRepo;
  late ItemsCubit itemsCubit;
  late AppDatabase db;
  late MedicineRepositoryImpl medicineRepo;
  late MedicineCubit medicineCubit;

  setUp(() {
    itemsRepo = MockTabbedItemRepository();
    itemsCubit = ItemsCubit(repository: itemsRepo);
    db = AppDatabase(NativeDatabase.memory());
    medicineRepo = MedicineRepositoryImpl(db: db);
    medicineCubit = MedicineCubit(repository: medicineRepo);
  });

  tearDown(() {
    itemsCubit.close();
    medicineCubit.close();
    db.close();
    itemsRepo.dispose();
  });

  Widget buildTestableHome({GoRouter? router}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ItemsCubit>.value(value: itemsCubit),
        BlocProvider<MedicineCubit>.value(value: medicineCubit),
      ],
      child: router != null
          ? MaterialApp.router(routerConfig: router)
          : const MaterialApp(home: HomePage()),
    );
  }

  group('Phase 2: Home Screen Tab Integration Tests', () {
    testWidgets('Top segmented bar renders 4 tabs including MedicineCare',
        (tester) async {
      await tester.pumpWidget(buildTestableHome());
      await tester.pumpAndSettle();

      expect(find.text('LifePocket'), findsNWidgets(2)); // tab + header
      expect(find.text('FreshCheck'), findsOneWidget);
      expect(find.text('DocAlert'), findsOneWidget);
      expect(find.text('MedicineCare'), findsOneWidget);
    });

    testWidgets(
        'Switching to MedicineCare tab updates header, 2x2 cards, counters, and FAB',
        (tester) async {
      await tester.pumpWidget(buildTestableHome());
      await tester.pumpAndSettle();

      // Tap MedicineCare tab
      await tester.tap(find.text('MedicineCare'));
      await tester.pumpAndSettle();

      // Section header should now be MedicineCare
      expect(find.text('MedicineCare'), findsNWidgets(2)); // pill + header
      expect(
          find.text('MEDICINE SCHEDULES & FAMILY REMINDERS'), findsOneWidget);

      // 4 Feature Cards for MedicineCare
      expect(find.text("Today's Doses"), findsOneWidget);
      expect(find.text('Next & pending pills'), findsOneWidget);
      expect(find.text('Add Medicine'), findsOneWidget);
      expect(find.text('Prescription & timings'), findsOneWidget);
      expect(find.text('Dose History'), findsOneWidget);
      expect(find.text('Adherence logs'), findsOneWidget);
      expect(find.text('Family Care'), findsOneWidget);
      expect(find.text('Caregiver alerts'), findsOneWidget);

      // Status counters should be Taken, Pending, Unconfirmed
      expect(find.text('Taken'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Unconfirmed'), findsOneWidget);

      // Dynamic FAB updates to '+ Add Medicine'
      expect(find.text('+ Add Medicine'), findsOneWidget);
    });

    testWidgets(
        'Scheduled dose renders Next Dose Hero Banner and allows one-tap Take Dose',
        (tester) async {
      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Seed a medicine with evening schedule via runAsync for native DB executor
      await tester.runAsync(() async {
        await medicineCubit.saveMedicine(
          medicine: MedicinesCompanion(
            id: const drift.Value('test_med_hero'),
            name: const drift.Value('Paracetamol'),
            medicineType: const drift.Value('tablet'),
            dosage: const drift.Value('650 mg'),
            instructions: const drift.Value('after_food'),
            startDate: drift.Value(todayStr),
            createdAt: drift.Value(now.toIso8601String()),
            updatedAt: drift.Value(now.toIso8601String()),
          ),
          schedules: [
            MedicineSchedulesCompanion(
              id: const drift.Value('sched_hero_1'),
              medicineId: const drift.Value('test_med_hero'),
              doseTime: const drift.Value('23:59'),
              daysOfWeek: const drift.Value('1,2,3,4,5,6,7'),
              createdAt: drift.Value(now.toIso8601String()),
            ),
          ],
        );
      });

      await tester.pumpWidget(buildTestableHome());
      await tester.pumpAndSettle();

      // Switch to MedicineCare tab
      await tester.tap(find.text('MedicineCare'));
      await tester.pumpAndSettle();

      // Scroll until hero card / schedule is visible
      await tester.scrollUntilVisible(
        find.text('UPCOMING DOSE'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      // Next Dose Hero Banner is rendered
      expect(find.text('UPCOMING DOSE'), findsOneWidget);
      expect(find.text('Mark Taken'), findsOneWidget);
      expect(find.text('Snooze 15m'), findsOneWidget);

      // Tap Mark Taken
      await tester.runAsync(() async {
        await medicineCubit.markDoseTaken(medicineCubit.state.nextDose!);
      });
      await tester.pumpAndSettle();

      // Should now be marked as taken
      expect(find.text('✓ Taken'), findsOneWidget);
    });
  });
}
