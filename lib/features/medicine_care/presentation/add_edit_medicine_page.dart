import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_text.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../cubit/medicine_cubit.dart';
import '../domain/entities/medicine_entity.dart';

class AddEditMedicinePage extends StatefulWidget {
  final MedicineEntity? existingMedicine;

  const AddEditMedicinePage({super.key, this.existingMedicine});

  @override
  State<AddEditMedicinePage> createState() => _AddEditMedicinePageState();
}

class _AddEditMedicinePageState extends State<AddEditMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _doctorController = TextEditingController();
  final _notesController = TextEditingController();

  MedicineType _selectedType = MedicineType.tablet;
  MealInstruction _mealInstruction = MealInstruction.afterFood;
  MedicineReminderMode _reminderMode = MedicineReminderMode.notification;
  int _snoozeDurationMinutes = 5;
  int _maximumRingingDurationMinutes = 10;
  bool _vibrationEnabled = true;
  String? _alarmSound;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String? _prescriptionPath;

  // Schedule times in "HH:mm" 24h format
  final List<String> _doseTimes = ['08:00', '20:00'];

  @override
  void initState() {
    super.initState();
    if (widget.existingMedicine != null) {
      final m = widget.existingMedicine!;
      _nameController.text = m.name;
      _dosageController.text = m.dosage;
      _doctorController.text = m.doctorName ?? '';
      _notesController.text = m.notes ?? '';
      _selectedType = m.medicineType;
      _mealInstruction = m.instructions;
      _reminderMode = m.reminderMode;
      _snoozeDurationMinutes = m.snoozeDurationMinutes;
      _maximumRingingDurationMinutes = m.maximumRingingDurationMinutes;
      _vibrationEnabled = m.vibrationEnabled;
      _alarmSound = m.alarmSound;
      _prescriptionPath = m.prescriptionPath;
      _startDate = DateTime.tryParse(m.startDate) ?? DateTime.now();
      _endDate = m.endDate != null ? DateTime.tryParse(m.endDate!) : null;

      _doseTimes.clear();
      for (final s in m.schedules) {
        _doseTimes.add(s.doseTime);
      }
      if (_doseTimes.isEmpty) {
        _doseTimes.add('08:00');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _doctorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatTime12Hour(String hhmm) {
    try {
      final parts = hhmm.split(':');
      final time =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:$minute $period';
    } catch (_) {
      return hhmm;
    }
  }

  Future<void> _pickTime(int index) async {
    final current = _doseTimes[index].split(':');
    final initial =
        TimeOfDay(hour: int.parse(current[0]), minute: int.parse(current[1]));
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        _doseTimes[index] = formatted;
        _doseTimes.sort();
      });
    }
  }

  Future<void> _addNewDoseTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 14, minute: 0),
    );
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (!_doseTimes.contains(formatted)) {
        setState(() {
          _doseTimes.add(formatted);
          _doseTimes.sort();
        });
      }
    }
  }

  Future<void> _pickPrescriptionFile() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded,
                    color: AppColors.primary),
                title: const Text('Take Photo of Prescription'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final photo =
                      await picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    setState(() => _prescriptionPath = photo.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: AppColors.safeGreen),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final photo =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (photo != null) {
                    setState(() => _prescriptionPath = photo.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded,
                    color: AppColors.dangerRed),
                title: const Text('Select Prescription PDF'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                  );
                  if (result != null && result.files.single.path != null) {
                    setState(
                        () => _prescriptionPath = result.files.single.path);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_doseTimes.isEmpty) {
      showToast(context, 'Please add at least one dose timing',
          type: ToastType.warning);
      return;
    }

    final id = widget.existingMedicine?.id ?? const Uuid().v4();
    final nowIso = DateTime.now().toIso8601String();
    final startStr = DateFormat('yyyy-MM-dd').format(_startDate);
    final endStr =
        _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null;

    final medCompanion = MedicinesCompanion(
      id: drift.Value(id),
      name: drift.Value(_nameController.text.trim()),
      medicineType: drift.Value(_selectedType.code),
      dosage: drift.Value(_dosageController.text.trim()),
      instructions: drift.Value(_mealInstruction.code),
      doctorName: drift.Value(_doctorController.text.trim().isEmpty
          ? null
          : _doctorController.text.trim()),
      prescriptionPath: drift.Value(_prescriptionPath),
      startDate: drift.Value(startStr),
      endDate: drift.Value(endStr),
      notes: drift.Value(_notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim()),
      isActive: const drift.Value(true),
      reminderMode: drift.Value(_reminderMode.code),
      vibrationEnabled: drift.Value(_vibrationEnabled),
      snoozeDurationMinutes: drift.Value(_snoozeDurationMinutes),
      maximumRingingDurationMinutes:
          drift.Value(_maximumRingingDurationMinutes),
      alarmSound: drift.Value(_alarmSound),
      createdAt: drift.Value(widget.existingMedicine?.createdAt ?? nowIso),
      updatedAt: drift.Value(nowIso),
    );

    final List<MedicineSchedulesCompanion> schedules = [];
    for (int i = 0; i < _doseTimes.length; i++) {
      final time = _doseTimes[i];
      final schedId = const Uuid().v4();
      String label = 'Dose ${i + 1}';
      final hour = int.parse(time.split(':')[0]);
      if (hour >= 5 && hour < 12) {
        label = 'Morning';
      } else if (hour >= 12 && hour < 17) {
        label = 'Afternoon';
      } else if (hour >= 17 && hour < 21) {
        label = 'Evening';
      } else {
        label = 'Night';
      }

      schedules.add(
        MedicineSchedulesCompanion(
          id: drift.Value(schedId),
          medicineId: drift.Value(id),
          doseTime: drift.Value(time),
          doseLabel: drift.Value(label),
          daysOfWeek: const drift.Value('1,2,3,4,5,6,7'),
          reminderEnabled: const drift.Value(true),
          createdAt: drift.Value(nowIso),
        ),
      );
    }

    await context.read<MedicineCubit>().saveMedicine(
          medicine: medCompanion,
          schedules: schedules,
        );

    if (mounted) {
      showToast(
        context,
        widget.existingMedicine == null
            ? 'Medicine schedule added!'
            : 'Medicine updated!',
        type: ToastType.success,
        icon: Icons.check_circle_rounded,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingMedicine != null;

    return Scaffold(
      appBar: KeepRemindAppBar(
        title: isEdit ? 'Edit Medicine' : 'Add Medicine',
        subtitle: 'Prescribed timings & reminder setup',
        showBack: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            // Safety Disclaimer Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.medicineCareColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.medicineCareColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.health_and_safety_rounded,
                    color: AppColors.medicineCareColor,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Please follow your doctor\'s prescription. KeepRemind records your schedule and does not recommend dosages.',
                      style: AppText.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Card 1: Core Medicine Information
            _sectionCard(
              children: [
                Text('Medicine Name *', style: AppText.h3),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Paracetamol, Metformin, Shelcal',
                    prefixIcon: const Icon(
                      Icons.medication_rounded,
                      color: AppColors.medicineCareColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter medicine name'
                      : null,
                ),
                const SizedBox(height: 16),
                Text('Medicine Type', style: AppText.h3),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MedicineType.values.map((type) {
                    final isSel = _selectedType == type;
                    return ChoiceChip(
                      showCheckmark: false,
                      label: Text('${type.icon} ${type.label}'),
                      selected: isSel,
                      selectedColor:
                          AppColors.medicineCareColor.withValues(alpha: 0.15),
                      backgroundColor: context.surfaceColor,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel
                            ? AppColors.medicineCareColor
                            : AppColors.textSecondary,
                      ),
                      side: BorderSide(
                        color: isSel
                            ? AppColors.medicineCareColor
                            : AppColors.cardBorder,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedType = type);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Prescribed Dosage *', style: AppText.h3),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _dosageController,
                  decoration: InputDecoration(
                    hintText: 'e.g. 500 mg, 1 tablet, 5 ml, 2 drops',
                    prefixIcon: Icon(
                      Icons.straighten_rounded,
                      color: AppColors.textMuted,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter prescribed dosage'
                      : null,
                ),
                const SizedBox(height: 16),
                Text('Meal Instructions', style: AppText.h3),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MealInstruction.values.map((inst) {
                    final isSel = _mealInstruction == inst;
                    return ChoiceChip(
                      showCheckmark: false,
                      label: Text('${inst.icon} ${inst.label}'),
                      selected: isSel,
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      backgroundColor: context.surfaceColor,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color:
                            isSel ? AppColors.primary : AppColors.textSecondary,
                      ),
                      side: BorderSide(
                        color: isSel ? AppColors.primary : AppColors.cardBorder,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _mealInstruction = inst);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Card 2: Schedule Timings
            _sectionCard(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Daily Reminder Schedule', style: AppText.h3),
                    TextButton.icon(
                      onPressed: _addNewDoseTime,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Time'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ..._doseTimes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final timeStr = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: context.surfaceRaisedColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.cardBorderColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.alarm_rounded,
                            color: AppColors.medicineCareColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _formatTime12Hour(timeStr),
                            style: AppText.timeDisplay.copyWith(fontSize: 17),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          tooltip: 'Change Time',
                          onPressed: () => _pickTime(index),
                        ),
                        if (_doseTimes.length > 1)
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                size: 20, color: AppColors.dangerRed),
                            tooltip: 'Remove',
                            onPressed: () =>
                                setState(() => _doseTimes.removeAt(index)),
                          ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 14),

                // Start & End Date
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Start Date', style: AppText.label),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                              );
                              if (picked != null) {
                                setState(() => _startDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: context.cardBorderColor),
                                borderRadius: BorderRadius.circular(12),
                                color: context.surfaceColor,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      size: 16, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('dd MMM yyyy')
                                        .format(_startDate),
                                    style: AppText.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('End Date (Optional)', style: AppText.label),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _endDate ??
                                    _startDate.add(const Duration(days: 7)),
                                firstDate: _startDate,
                                lastDate: DateTime(2035),
                              );
                              if (picked != null) {
                                setState(() => _endDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: context.cardBorderColor),
                                borderRadius: BorderRadius.circular(12),
                                color: context.surfaceColor,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.event_available_rounded,
                                      size: 16, color: AppColors.accent),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _endDate != null
                                          ? DateFormat('dd MMM yyyy')
                                              .format(_endDate!)
                                          : 'Ongoing',
                                      style: AppText.bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (_endDate != null)
                                    GestureDetector(
                                      onTap: () =>
                                          setState(() => _endDate = null),
                                      child: Icon(Icons.clear_rounded,
                                          size: 16, color: AppColors.textMuted),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Card 3: Doctor & Prescription
            _sectionCard(
              children: [
                Text('Prescribed By (Doctor)', style: AppText.h3),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _doctorController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Dr. Ramesh Kumar, Cardiologist',
                    prefixIcon: Icon(Icons.person_pin_rounded,
                        color: AppColors.textMuted),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Prescription Copy (Optional)', style: AppText.h3),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickPrescriptionFile,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.surfaceRaisedColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _prescriptionPath != null
                            ? AppColors.safeGreen
                            : context.cardBorderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _prescriptionPath != null
                              ? Icons.check_circle_rounded
                              : Icons.attach_file_rounded,
                          color: _prescriptionPath != null
                              ? AppColors.safeGreen
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _prescriptionPath != null
                                ? 'Attached: ${_prescriptionPath!.split(Platform.pathSeparator).last}'
                                : 'Upload Prescription (Camera, Gallery, or PDF)',
                            style: TextStyle(
                              color: _prescriptionPath != null
                                  ? AppColors.safeGreen
                                  : AppColors.textSecondary,
                              fontWeight: _prescriptionPath != null
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_prescriptionPath != null)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: AppColors.dangerRed, size: 20),
                            onPressed: () =>
                                setState(() => _prescriptionPath = null),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Card 4: Reminder Mode (Notification vs Alarm)
            _sectionCard(
              children: [
                Text('Reminder Type', style: AppText.h3),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() =>
                            _reminderMode = MedicineReminderMode.notification),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _reminderMode ==
                                    MedicineReminderMode.notification
                                ? context.primarySubtleColor
                                : context.surfaceRaisedColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _reminderMode ==
                                      MedicineReminderMode.notification
                                  ? AppColors.primary
                                  : context.cardBorderColor,
                              width: _reminderMode ==
                                      MedicineReminderMode.notification
                                  ? 1.5
                                  : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.notifications_active_outlined,
                                    color: _reminderMode ==
                                            MedicineReminderMode.notification
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    size: 22,
                                  ),
                                  const Spacer(),
                                  if (_reminderMode ==
                                      MedicineReminderMode.notification)
                                    const Icon(Icons.check_circle_rounded,
                                        color: AppColors.primary, size: 18),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Notification',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: _reminderMode ==
                                          MedicineReminderMode.notification
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Normal alert & sound',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(
                            () => _reminderMode = MedicineReminderMode.alarm),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _reminderMode == MedicineReminderMode.alarm
                                ? AppColors.medicineCareColor
                                    .withValues(alpha: 0.12)
                                : context.surfaceRaisedColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _reminderMode == MedicineReminderMode.alarm
                                  ? AppColors.medicineCareColor
                                  : context.cardBorderColor,
                              width: _reminderMode == MedicineReminderMode.alarm
                                  ? 1.5
                                  : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.alarm_rounded,
                                    color: _reminderMode ==
                                            MedicineReminderMode.alarm
                                        ? AppColors.medicineCareColor
                                        : AppColors.textSecondary,
                                    size: 22,
                                  ),
                                  const Spacer(),
                                  if (_reminderMode ==
                                      MedicineReminderMode.alarm)
                                    const Icon(Icons.check_circle_rounded,
                                        color: AppColors.medicineCareColor,
                                        size: 18),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Alarm Mode',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: _reminderMode ==
                                          MedicineReminderMode.alarm
                                      ? AppColors.medicineCareColor
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Continuous ring & full-screen',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_reminderMode == MedicineReminderMode.alarm) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            AppColors.medicineCareColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: AppColors.medicineCareColor, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Alarm Mode rings continuously on lock-screen with Stop, Snooze & Taken controls.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Vibrate during alarm',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                          subtitle: const Text('Rhythmic vibration pattern',
                              style: TextStyle(fontSize: 12)),
                          value: _vibrationEnabled,
                          onChanged: (val) =>
                              setState(() => _vibrationEnabled = val),
                        ),
                        const Divider(height: 20),
                        Text('Snooze Duration', style: AppText.label),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [5, 10, 15].map((mins) {
                            final isSel = _snoozeDurationMinutes == mins;
                            return ChoiceChip(
                              showCheckmark: false,
                              label: Text('$mins mins'),
                              selected: isSel,
                              selectedColor: AppColors.medicineCareColor
                                  .withValues(alpha: 0.15),
                              onSelected: (_) =>
                                  setState(() => _snoozeDurationMinutes = mins),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        Text('Maximum Ringing Duration', style: AppText.label),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [5, 10, 15].map((mins) {
                            final isSel =
                                _maximumRingingDurationMinutes == mins;
                            return ChoiceChip(
                              showCheckmark: false,
                              label: Text('$mins mins'),
                              selected: isSel,
                              selectedColor: AppColors.medicineCareColor
                                  .withValues(alpha: 0.15),
                              onSelected: (_) => setState(
                                  () => _maximumRingingDurationMinutes = mins),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.medicineCareColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.check_rounded, color: Colors.white),
                label: Text(
                  isEdit ? 'Update Medicine' : 'Save Medicine Schedule',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
