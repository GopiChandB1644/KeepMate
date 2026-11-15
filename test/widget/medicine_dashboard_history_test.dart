import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepremind/core/database/app_database.dart';
import 'package:keepremind/features/medicine_care/cubit/medicine_cubit.dart';
import 'package:keepremind/features/medicine_care/data/repositories/medicine_repository_impl.dart';
import 'package:keepremind/features/medicine_care/domain/entities/dose_log_entity.dart';
import 'package:keepremind/features/medicine_care/domain/repositories/medicine_repository.dart';
import 'package:keepremind/features/medicine_care/presentation/medicine_history_page.dart';
import 'package:keepremind/features/medicine_care/presentation/today_schedule_page.dart';

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

  Widget buildTestableSchedulePage() {
    return BlocProvider<MedicineCubit>.value(
      value: cubit,
      child: const MaterialApp(
        home: TodaySchedulePage(),
      ),
    );
  }

  Widget buildTestableHistoryPage({Future<List<DoseLogEntity>>? future}) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<MedicineRepository>.value(value: repo),
      ],
      child: BlocProvider<MedicineCubit>.value(
        value: cubit,
        child: MaterialApp(
          home: MedicineHistoryPage(historyFuture: future),
        ),
      ),
    );
  }

  group('Phase 4: Daily Dashboard & Dose Log Tests', () {
    testWidgets('TodaySchedulePage displays next dose hero card, counters, and dose items', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await tester.runAsync(() async {
        await cubit.saveMedicine(
          medicine: MedicinesCompanion(
            id: const drift.Value('med_dash_1'),
            name: const drift.Value('Metformin'),
            medicineType: const drift.Value('tablet'),
            dosage: const drift.Value('500 mg'),
            instructions: const drift.Value('after_food'),
            startDate: drift.Value(todayStr),
            createdAt: drift.Value(now.toIso8601String()),
            updatedAt: drift.Value(now.toIso8601String()),
          ),
          schedules: [
            MedicineSchedulesCompanion(
              id: const drift.Value('sched_d1'),
              medicineId: const drift.Value('med_dash_1'),
              doseTime: const drift.Value('23:59'),
              daysOfWeek: const drift.Value('1,2,3,4,5,6,7'),
              createdAt: drift.Value(now.toIso8601String()),
            ),
          ],
        );
      });

      await tester.pumpWidget(buildTestableSchedulePage());
      await tester.pumpAndSettle();

      // Hero banner
      expect(find.text('NEXT DOSE'), findsOneWidget);
      expect(find.text('Metformin'), findsNWidgets(2)); // in hero card and in dose list
      expect(find.text('Mark Taken'), findsOneWidget);

      // Counters strip
      expect(find.text('Taken'), findsNWidgets(2)); // in stats row & in list card header
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Skipped'), findsOneWidget);
      expect(find.text('Unconfirmed'), findsOneWidget);

      // Mark Taken directly via cubit with runAsync for native DB
      await tester.runAsync(() async {
        await cubit.markDoseTaken(cubit.state.nextDose!);
      });
      await tester.pumpAndSettle();

      expect(find.textContaining('Confirmed at'), findsOneWidget);
    });

    testWidgets('Marking dose skipped displays skip reason on schedule card', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await tester.runAsync(() async {
        await cubit.saveMedicine(
          medicine: MedicinesCompanion(
            id: const drift.Value('med_dash_2'),
            name: const drift.Value('Aspirin'),
            medicineType: const drift.Value('tablet'),
            dosage: const drift.Value('75 mg'),
            instructions: const drift.Value('after_food'),
            startDate: drift.Value(todayStr),
            createdAt: drift.Value(now.toIso8601String()),
            updatedAt: drift.Value(now.toIso8601String()),
          ),
          schedules: [
            MedicineSchedulesCompanion(
              id: const drift.Value('sched_d2'),
              medicineId: const drift.Value('med_dash_2'),
              doseTime: const drift.Value('23:59'),
              daysOfWeek: const drift.Value('1,2,3,4,5,6,7'),
              createdAt: drift.Value(now.toIso8601String()),
            ),
          ],
        );
      });

      await tester.pumpWidget(buildTestableSchedulePage());
      await tester.pumpAndSettle();

      // Tap Skip in the dose card and verify dialog
      await tester.tap(find.text('Skip').first);
      await tester.pumpAndSettle();

      // Dialog should be open
      expect(find.text('Skip Dose Reason'), findsOneWidget);
      expect(find.text('Why is Aspirin being skipped?'), findsOneWidget);
      expect(find.text('Fasting'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Mark dose skipped via cubit with reason
      await tester.runAsync(() async {
        await cubit.markDoseSkipped(cubit.state.todayDoses.first, reason: 'Fasting');
      });
      await tester.pumpAndSettle();

      // Verify reason is displayed
      expect(find.text('Reason: Fasting'), findsOneWidget);
    });

    testWidgets('MedicineHistoryPage renders adherence rate and filter chips', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Save medicine & history
      await tester.runAsync(() async {
        await cubit.saveMedicine(
          medicine: MedicinesCompanion(
            id: const drift.Value('med_hist_1'),
            name: const drift.Value('Thyronorm'),
            medicineType: const drift.Value('tablet'),
            dosage: const drift.Value('50 mcg'),
            instructions: const drift.Value('empty_stomach'),
            startDate: drift.Value(todayStr),
            createdAt: drift.Value(now.toIso8601String()),
            updatedAt: drift.Value(now.toIso8601String()),
          ),
          schedules: [
            MedicineSchedulesCompanion(
              id: const drift.Value('sched_h1'),
              medicineId: const drift.Value('med_hist_1'),
              doseTime: const drift.Value('06:30'),
              daysOfWeek: const drift.Value('1,2,3,4,5,6,7'),
              createdAt: drift.Value(now.toIso8601String()),
            ),
          ],
        );

        await repo.recordDoseAction(
          medicineId: 'med_hist_1',
          scheduleId: 'sched_h1',
          scheduledDate: todayStr,
          scheduledTime: '06:30',
          status: DoseStatus.taken,
        );
      });

      late List<DoseLogEntity> historyList;
      await tester.runAsync(() async {
        historyList = await repo.getAllDoseHistory();
      });

      await tester.pumpWidget(buildTestableHistoryPage(future: Future.value(historyList)));
      await tester.pumpAndSettle();

      // Adherence header
      expect(find.text('Medication Adherence'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('1 doses taken • 0 skipped'), findsOneWidget);

      // Filter chips
      expect(find.text('All Records (1)'), findsOneWidget);
      expect(find.text('Taken (1)'), findsOneWidget);
      expect(find.text('Skipped (0)'), findsOneWidget);

      // Dose card
      expect(find.text('Thyronorm'), findsOneWidget);
      expect(find.text('Taken'), findsOneWidget); // in card badge
    });
  });
}
