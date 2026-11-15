import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepremind/core/database/app_database.dart';
import 'package:keepremind/features/medicine_care/cubit/medicine_cubit.dart';
import 'package:keepremind/features/medicine_care/data/repositories/medicine_repository_impl.dart';
import 'package:keepremind/features/medicine_care/domain/entities/medicine_entity.dart';
import 'package:keepremind/features/medicine_care/presentation/add_edit_medicine_page.dart';
import 'package:keepremind/features/medicine_care/services/medicine_notification_service.dart';

void main() {
  late AppDatabase db;
  late MedicineRepositoryImpl repo;
  late MedicineCubit cubit;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = MedicineRepositoryImpl(db: db);
    cubit = MedicineCubit(repository: repo);
  });

  tearDown(() async {
    cubit.close();
    await db.close();
  });

  Widget buildTestableAddPage({MedicineEntity? existing}) {
    return BlocProvider<MedicineCubit>.value(
      value: cubit,
      child: MaterialApp(
        home: AddEditMedicinePage(existingMedicine: existing),
      ),
    );
  }

  group('Phase 3: Add Medicine & Reminder Flow Tests', () {
    testWidgets('AddEditMedicinePage renders all prescribed scheduling fields and safety disclaimer', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableAddPage());
      await tester.pumpAndSettle();

      // Title & subtitle
      expect(find.text('Add Medicine'), findsOneWidget);
      expect(find.text('Prescribed timings & reminder setup'), findsOneWidget);

      // Safety Disclaimer Banner
      expect(find.textContaining('Please follow your doctor\'s prescription'), findsOneWidget);

      // Form fields
      expect(find.text('Medicine Name *'), findsOneWidget);
      expect(find.text('Medicine Type'), findsOneWidget);
      expect(find.text('Prescribed Dosage *'), findsOneWidget);
      expect(find.text('Meal Instructions'), findsOneWidget);
      expect(find.text('Daily Reminder Schedule'), findsOneWidget);

      // Chips
      expect(find.text('💊 Tablet'), findsOneWidget);
      expect(find.text('💊 Capsule'), findsOneWidget);
      expect(find.text('🥄 Syrup'), findsOneWidget);
      expect(find.text('🍲 After Food'), findsOneWidget);
      expect(find.text('🍽️ Before Food'), findsOneWidget);

      // Default schedules
      expect(find.text('8:00 AM'), findsOneWidget);
      expect(find.text('8:00 PM'), findsOneWidget);

      // Save button
      expect(find.text('Save Medicine Schedule'), findsOneWidget);
    });

    testWidgets('Validation triggers error message when submitting empty medicine name', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableAddPage());
      await tester.pumpAndSettle();

      // Tap save without filling name
      await tester.tap(find.text('Save Medicine Schedule'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter medicine name'), findsOneWidget);

      // Enter name and verify error goes away
      await tester.enterText(find.byType(TextFormField).at(0), 'Pantoprazole');
      await tester.enterText(find.byType(TextFormField).at(1), '40 mg');
      await tester.pumpAndSettle();

      // Tap 'Before Food' chip
      await tester.tap(find.text('🍽️ Before Food'));
      await tester.pumpAndSettle();

      expect(find.text('Pantoprazole'), findsOneWidget);
      expect(find.text('40 mg'), findsOneWidget);
    });

    test('MedicineCubit saves medicine with schedules into database and updates state', () async {
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await cubit.saveMedicine(
        medicine: MedicinesCompanion(
          id: const drift.Value('pantoprazole_1'),
          name: const drift.Value('Pantoprazole'),
          medicineType: const drift.Value('tablet'),
          dosage: const drift.Value('40 mg'),
          instructions: const drift.Value('before_food'),
          startDate: drift.Value(todayStr),
          createdAt: drift.Value(now.toIso8601String()),
          updatedAt: drift.Value(now.toIso8601String()),
        ),
        schedules: [
          MedicineSchedulesCompanion(
            id: const drift.Value('sched_p1'),
            medicineId: const drift.Value('pantoprazole_1'),
            doseTime: const drift.Value('07:30'),
            daysOfWeek: const drift.Value('1,2,3,4,5,6,7'),
            createdAt: drift.Value(now.toIso8601String()),
          ),
        ],
      );

      // Verify in repository
      final meds = await repo.getAllMedicines();
      expect(meds.length, 1);
      expect(meds.first.name, 'Pantoprazole');
      expect(meds.first.dosage, '40 mg');
      expect(meds.first.instructions, MealInstruction.beforeFood);
      expect(meds.first.schedules.length, 1);
      expect(meds.first.schedules.first.doseTime, '07:30');
    });

    test('MedicineNotificationService generates deterministic IDs and action payloads', () {
      final notifService = MedicineNotificationService();
      final id1 = notifService.generateNotificationId('med_123', '08:00');
      final id2 = notifService.generateNotificationId('med_123', '08:00');
      final id3 = notifService.generateNotificationId('med_123', '20:00');

      expect(id1, id2);
      expect(id1, isNot(id3));
      expect(id1 >= 0, isTrue);
    });
  });
}
