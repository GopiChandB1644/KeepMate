import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepremind/core/database/app_database.dart';
import 'package:keepremind/features/medicine_care/cubit/medicine_cubit.dart';
import 'package:keepremind/features/medicine_care/data/repositories/medicine_repository_impl.dart';
import 'package:keepremind/features/medicine_care/domain/entities/dose_log_entity.dart';
import 'package:keepremind/features/medicine_care/domain/entities/medicine_entity.dart';
import 'package:keepremind/features/medicine_care/presentation/caregiver_contacts_page.dart';
import 'package:keepremind/features/medicine_care/services/medicine_voice_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  Widget buildTestableCaregiverPage() {
    return BlocProvider<MedicineCubit>.value(
      value: cubit,
      child: const MaterialApp(
        home: CaregiverContactsPage(),
      ),
    );
  }

  group('Phase 5: Family Caregiver & Voice Extension Tests', () {
    testWidgets(
        'CaregiverContactsPage displays empty state when no caregivers are linked',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableCaregiverPage());
      await tester.pumpAndSettle();

      expect(find.text('Family & Caregiver Support'), findsOneWidget);
      expect(find.text('No caregivers linked'), findsOneWidget);
      expect(
          find.text(
              'Caregivers receive respectful "Dose not confirmed" notices rather than assuming a dose was missed. Privacy is strictly protected.'),
          findsOneWidget);
    });

    testWidgets(
        'Adding caregiver through dialog saves contact and renders card with grace period',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableCaregiverPage());
      await tester.pumpAndSettle();

      // Tap + button in app bar
      final addBtn = find.byIcon(Icons.person_add_rounded);
      expect(addBtn, findsOneWidget);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      // Check dialog opened
      expect(find.text('Link Caregiver'), findsOneWidget);
      expect(find.text('Grace Period for Alert'), findsOneWidget);

      // Enter name and contact info
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Dr. Sharma');
      await tester.enterText(textFields.at(1), '+91 9988776655');

      // Select 45m grace period
      final chip45m = find.text('45m');
      expect(chip45m, findsOneWidget);
      await tester.tap(chip45m);
      await tester.pumpAndSettle();

      // Save
      await tester.runAsync(() async {
        final saveBtn = find.text('Save Caregiver');
        await tester.tap(saveBtn);
        await Future.delayed(const Duration(milliseconds: 300));
      });
      await tester.pumpAndSettle();

      // Verify contact card appears
      expect(find.text('Dr. Sharma'), findsOneWidget);
      expect(find.textContaining('+91 9988776655'), findsOneWidget);
      expect(find.text('Alerts after 45 mins grace period'), findsOneWidget);
    });

    testWidgets(
        'Unconfirmed doses section renders non-accusatory warning and details',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await tester.runAsync(() async {
        // Save medicine
        await cubit.saveMedicine(
          medicine: MedicinesCompanion(
            id: const drift.Value('med_care_1'),
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
              id: const drift.Value('sched_c1'),
              medicineId: const drift.Value('med_care_1'),
              doseTime: const drift.Value('08:00'),
              daysOfWeek: const drift.Value('1,2,3,4,5,6,7'),
              createdAt: drift.Value(now.toIso8601String()),
            ),
          ],
        );

        // Mark as unconfirmed (grace period elapsed without confirmation)
        await repo.recordDoseAction(
          medicineId: 'med_care_1',
          scheduledTime: '08:00',
          scheduledDate: todayStr,
          status: DoseStatus.unconfirmed,
        );

        await cubit.changeSelectedDate(now);
        await Future.delayed(const Duration(milliseconds: 200));
      });

      await tester.pumpWidget(buildTestableCaregiverPage());
      await tester.pumpAndSettle();

      // Verify unconfirmed dose banner is shown
      expect(find.text('Unconfirmed Doses (1)'), findsOneWidget);
      expect(
          find.text(
              'The following doses passed the grace period without confirmation:'),
          findsOneWidget);
      expect(find.text('Aspirin (08:00)'), findsOneWidget);
      expect(find.text('Dose not confirmed'), findsOneWidget);
    });

    test(
        'MedicineVoiceService provides accurate multilingual text in Telugu, Hindi, English',
        () {
      const voiceService = MedicineVoiceService();

      // Telugu
      final teluguText = voiceService.getReminderSpeechText(
        medicineName: 'Paracetamol',
        dosage: '650 mg',
        instruction: MealInstruction.afterFood,
        language: MedicineVoiceLanguage.telugu,
      );
      expect(teluguText, contains('మందులు వేసుకునే సమయం అయింది'));
      expect(teluguText, contains('Paracetamol 650 mg'));
      expect(teluguText, contains('భోజనం తర్వాత వేసుకోండి'));
      expect(teluguText, contains('దయచేసి డాక్టర్ ప్రిస్క్రిప్షన్ పాటించండి'));

      // Hindi
      final hindiText = voiceService.getReminderSpeechText(
        medicineName: 'Metformin',
        dosage: '500 mg',
        instruction: MealInstruction.beforeFood,
        language: MedicineVoiceLanguage.hindi,
      );
      expect(hindiText, contains('दवाई लेने का समय हो गया है'));
      expect(hindiText, contains('Metformin 500 mg'));
      expect(hindiText, contains('खाने से पहले लें'));
      expect(hindiText, contains('कृपया डॉक्टर की सलाह के अनुसार दवाई लें'));

      // English
      final englishText = voiceService.getReminderSpeechText(
        medicineName: 'Amoxicillin',
        dosage: '250 mg',
        instruction: MealInstruction.afterFood,
        language: MedicineVoiceLanguage.english,
      );
      expect(englishText,
          contains('Time for your medicine: Amoxicillin, 250 mg after food'));
      expect(
          englishText, contains('Please take according to your prescription'));

      // Respectful Caregiver Notice (Non-accusatory)
      final alertMsg = voiceService.getCaregiverAlertMessage(
        personName: 'Father',
        medicineName: 'Telmisartan',
        dosage: '40 mg',
        scheduledTime: '09:00 AM',
        gracePeriodMinutes: 30,
      );
      expect(alertMsg, contains('Medication Update: Dose not confirmed'));
      expect(alertMsg, contains('past 30 mins grace period'));
      expect(alertMsg, contains('Please check gently with Father'));
      expect(
          alertMsg,
          contains(
              'A missed notification is not proof that medicine was not taken'));
    });
  });
}
